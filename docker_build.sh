#!/bin/bash

echo "Currently not working. Please use docker_local_build.sh"
exit

IMAGE=drupal

docker login --username marklabrecque --password $DOCKER_HUB_PASSWORD

# build and push using the 'latest' tag
docker build --pull -t marklabrecque/$IMAGE:latest .

ret=$?
if [ $ret -ne 0 ]; then
  echo "Build exit code = $ret"
  exit $ret
fi

docker push marklabrecque/$IMAGE:latest

echo "Drupal Docker image was successfuly updated."