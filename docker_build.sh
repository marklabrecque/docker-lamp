#!/bin/bash

echo "This script is supposed to be run by Jenkins build job."

IMAGE=web-php71-drupal

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

# build and push using the 'latest' tag
docker build --pull -t nexus.fcvhost.com:5000/php/$IMAGE:latest .

ret=$?
if [ $ret -ne 0 ]; then
  echo "Build exit code = $ret"
  exit $ret
fi

docker push nexus.fcvhost.com:5000/php/$IMAGE:latest

# tag and push using other tags given
if [ "$1" != "" ]; then
  for tag in "$@"
  do
    # tagging & pushing
    docker tag nexus.fcvhost.com:5000/php/$IMAGE:latest nexus.fcvhost.com:5000/php/$IMAGE:$tag
    docker push nexus.fcvhost.com:5000/php/$IMAGE:$tag
  done
fi
