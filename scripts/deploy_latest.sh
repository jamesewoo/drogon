#!/usr/bin/env bash
set -e

docker_user=jwoo11

docker tag drogon:runtime drogon:latest
docker tag drogon:runtime "$docker_user/drogon:latest"
docker push "$docker_user/drogon:latest"
