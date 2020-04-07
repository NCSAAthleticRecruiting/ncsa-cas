#!/usr/bin/env bash
set -u # Fail if variable referenced does not exist
set -e # Fail fast on error

export REPOSITORY=$(<REPOSITORY)
if [ ! -f build/libs/cas.war ]; then
./script/build.sh
fi

echo "release.sh RAILS_ENV & RELEASE_TAG Environment value for docker image: "
echo "$RAILS_ENV"
echo "$RELEASE_TAG"

# Copy env specific config files
cp config/"$RAILS_ENV"/* tmp/


echo "Creating release image with tag: $RELEASE_TAG"
cd tmp/
docker build -t "$REPOSITORY:$RELEASE_TAG" -f Dockerfile  \
  --build-arg build_env="$RAILS_ENV" .

docker tag "$REPOSITORY:$RELEASE_TAG" "$REPOSITORY:$DEPLOY_TAG"
docker push ${REPOSITORY}:${DEPLOY_TAG}
