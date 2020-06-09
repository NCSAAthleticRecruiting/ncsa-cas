#!/usr/bin/env bash
set -e # Fail fast on error
shopt -s extglob # support regexp in case matcher

export DEPLOY_TARGET
DEPLOY_TARGET=$1
export BRANCH
BRANCH=$2
export environment
environment=$3
export REPOSITORY=$(<REPOSITORY)
export release_image

# Set DEPLOY_TAG vars
echo "Remove spaces and slashes from tag or branch value"
export TAG
TAG="$(sed 's/\///g; s/ *//g' <<< $BRANCH)"
# Use the SHA in the branch tag so we don't push the same build image over and over again
export SHA
SHA=$(git rev-parse HEAD | cut -c 1-7)
echo "DEPLOY_TARGET: $DEPLOY_TARGET"

export RAILS_ENV="$environment"
export RELEASE_TAG="$TAG-$SHA"
echo "RELEASE_TAG: $RELEASE_TAG"

echo "*** login to AWS docker repository ***"
export AWS_PROFILE=jenkins
$(aws ecr get-login --no-include-email)

export DEPLOY_TAG
# DEPLOY_TAG="$TAG-$SHA-$RAILS_ENV"
# eg DEPLOY_TAG=feature-ecs-deploy-9f3b563-preprod
DEPLOY_TAG="$RELEASE_TAG-$environment"
echo "DEPLOY_TAG: $DEPLOY_TAG"
cp script/Dockerfile tmp/Dockerfile
cp /var/lib/jenkins/.keystore tmp/.keystore
cp /var/lib/jenkins/deploy.yml ./deploy.yml
echo "Deploy to NCSA Target: $DEPLOY_TARGET; DEPLOY_TAG: $DEPLOY_TAG"

#Build the docker release image from environment
./script/release.sh
release_image="${REPOSITORY}:${DEPLOY_TAG}"

#Deploy to servers
echo "target=$DEPLOY_TARGET env=$environment release_image=$release_image"

ansible-playbook ./deploy.yml  -i /etc/ansible/cas_hosts --extra-vars "target=$DEPLOY_TARGET env=$environment release_image=$release_image"

# always return explicit exit code
exit 0
