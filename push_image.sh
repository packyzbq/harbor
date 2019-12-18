#!/bin/bash
echo "$DOCKER_PASSWD"| docker login -u "$DOCKER_USERNAME" --password-stdin
docker images|grep harbor|awk '{print "packyzbq/"$1":"$2}'|xargs docker push 
