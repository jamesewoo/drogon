#!/usr/bin/env bash
set -e

if [ "$#" -ne 2 ]; then
    echo "usage: build.sh DROGON_HOME SERVER_HOME"
    exit 1
fi

drogon_home="$1"
server_home="$2"
docker_user=jwoo11

cd "$drogon_home"

docker build -t drogon:runtime -f src/Dockerfile src/
# other builds depend on runtime
docker tag drogon:runtime "$docker_user/drogon:runtime"
docker push "$docker_user/drogon:runtime"

docker build -t drogon:test -f test/Dockerfile test/

cd "$server_home"

docker build -t drogon:nginx -f nginx/Dockerfile nginx/
docker build -t drogon:server -f Dockerfile .

tags=(test nginx server)

for tag in ${tags[*]}; do
    docker tag "drogon:$tag" "$docker_user/drogon:$tag"
done

for tag in ${tags[*]}; do
    docker push "$docker_user/drogon:$tag"
done

docker tag drogon:runtime "$docker_user/drogon:latest"
docker push "$docker_user/drogon:latest"
