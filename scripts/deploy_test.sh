#!/usr/bin/env bash
set -e

if [ "$#" -ne 1 ]; then
    echo "usage: deploy_test.sh DROGON_HOME"
    exit 1
fi

drogon_home="$1"
docker_user=jwoo11

cd "$drogon_home"

docker build -t drogon:test -f test/Dockerfile test/
docker run drogon:test
docker tag drogon:test "$docker_user/drogon:test"
docker push "$docker_user/drogon:test"
