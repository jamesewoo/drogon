#!/usr/bin/env bash
set -e

if [ "$#" -ne 1 ]; then
    echo "usage: deploy_runtime.sh DROGON_HOME"
    exit 1
fi

drogon_home="$1"
docker_user=jwoo11

cd "$drogon_home"

docker build -t drogon:runtime -f src/Dockerfile src/
docker tag drogon:runtime "$docker_user/drogon:runtime"
docker push "$docker_user/drogon:runtime"
