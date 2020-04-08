#!/usr/bin/env bash
set -e # Fail fast on error

export SHA=$(git rev-parse HEAD | cut -c 1-7)
export REPOSITORY=$(<REPOSITORY)

#Copy config files
rm -rf tmp
mkdir -p tmp

if [ ! -f build/libs/cas.war ]; then
  echo "cas.war absent, building war file"
  docker run --rm -v "$PWD":/home/gradle/project -w /home/gradle/project gradle:6.3.0-jdk11 gradle build
fi

sudo chown -Rf jenkins:jenkins *
#Copy war file
cp build/libs/cas.war tmp/cas.war
