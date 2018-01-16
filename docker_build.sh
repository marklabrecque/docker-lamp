#!/bin/bash


echo "DO NOT USE UNTIL UPDATED: I'VE NOT DONE THIS... exiting."
exit;



echo "This script is supposed to be run by Jenkins build job."

if [ -z "$DRUPAL_GIT_COMMIT" ]; then
  echo "env: \$DRUPAL_GIT_COMMIT is expected (the commit hash from ctc/corporate-d8 repo)"
  GIT_COMMIT=`git rev-parse --short --verify HEAD`
  exit 1
else
  echo "Getting DRUPAL_GIT_COMMIT from env: $DRUPAL_GIT_COMMIT"
fi

IMAGE=corporate-d8

PROJECT=https://nexus.fcvhost.com/repository/raw-ctc/ci/corporate/$DRUPAL_GIT_COMMIT/project.tgz

# you can add user / pass like:
#  -u jenkins:******
# We assume you have already logged into Nexus at least once and the login
# has been saved in ~/.docker/config.json
# However, CURL cannot read the docker file so we put the pass in a local file
# and read it (so we don't need to save it in source control)
PWFILE=~/.docker/nexus_jenkins_pass.txt
if [ ! -f ~/.docker/nexus_jenkins_pass.txt ]; then
    echo "~/.docker/nexus_jenkins_pass.txt file not found!"
    exit 1
fi
JENKINS_PW=`cat $PWFILE`

docker login -u jenkins -p $JENKINS_PW nexus.fcvhost.com:5001
ret=$?
if [ $ret -ne 0 ]; then
  echo "Error: docker login exit code = $ret"
  exit $ret
fi

# build and push using the 'latest' tag
# Note that on jenkins.halifax.ca the networking is complicated, you need to use
# --network host
# otherwise it won't build

# https://forums.docker.com/t/is-it-possible-to-specify-network-for-docker-build-command/26319/6
docker build --pull -t nexus.fcvhost.com:5001/ci/$IMAGE:latest \
  --build-arg project_artifact=$PROJECT \
  --build-arg NEXUS_USER=jenkins \
  --build-arg NEXUS_PASS=$JENKINS_PW \
  --network host \
  .

ret=$?
if [ $ret -ne 0 ]; then
  echo "Error: docker build exit code = $ret"
  exit $ret
fi

docker push nexus.fcvhost.com:5001/ci/$IMAGE:latest

ret=$?
if [ $ret -ne 0 ]; then
  echo "Error: docker push exit code = $ret"
  exit $ret
fi

# tag and push using the upstream Drupal project GIT COMMIT tag
if [ "$DRUPAL_GIT_COMMIT" != "" ]; then
    # tagging & pushing
    docker tag nexus.fcvhost.com:5001/ci/$IMAGE:latest nexus.fcvhost.com:5001/ci/$IMAGE:$DRUPAL_GIT_COMMIT
    docker push nexus.fcvhost.com:5001/ci/$IMAGE:$DRUPAL_GIT_COMMIT

    ret=$?
    if [ $ret -ne 0 ]; then
      echo "Error: docker push tag $DRUPAL_GIT_COMMIT exit code = $ret"
      exit $ret
    fi

fi
