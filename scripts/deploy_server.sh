#!/usr/bin/env bash
set -e

if [ "$#" -ne 1 ]; then
    echo "usage: deploy_server.sh SERVER_HOME"
    exit 1
fi

server_home="$1"
docker_user=jwoo11

cd "$server_home"

# build server tag
docker build -t drogon:nginx -f nginx/Dockerfile nginx/
docker build -t drogon:server -f Dockerfile .

# unit test server tag
docker run drogon:server pytest

# create es-en volume
docker run -v es-en:/models drogon:test echo

# test endpoint within a container
docker run -v es-en:/models drogon:server es-test

# test endpoint from host machine
docker stack deploy -c docker-compose.yml drogon
sleep 7
curl localhost:9080/translate/english -H "Content-Type: application/json" -X POST -d '{"inputLanguage": "spanish", "inputText": "los pollos hermanos"}'
docker stack rm drogon

tags=(nginx server)

for tag in ${tags[*]}; do
    docker tag "drogon:$tag" "$docker_user/drogon:$tag"
done

for tag in ${tags[*]}; do
    docker push "$docker_user/drogon:$tag"
done
