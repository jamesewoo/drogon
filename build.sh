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

# build and push runtime tag
docker build -t drogon:runtime -f src/Dockerfile src/
docker tag drogon:runtime "$docker_user/drogon:runtime"
docker push "$docker_user/drogon:runtime"

# build and run test tag
docker build -t drogon:test -f test/Dockerfile test/
docker run drogon:test

cd "$server_home"

# build server tag
docker build -t drogon:nginx -f nginx/Dockerfile nginx/
docker build -t drogon:server -f Dockerfile .

# unit test server tag
docker run drogon:server pytest

# test endpoint within a container
docker volume inspect es-en
if [ "$?" -ne 0 ]; then
    # create volume if necessary
    docker run -v es-en:/models drogon:test echo
fi
docker run -v es-en:/models drogon:server es-test

# test endpoint from host machine
docker stack deploy -c docker-compose.yml drogon
sleep 5
curl localhost:8080/translate/english -H "Content-Type: application/json" -X POST -d '{"inputLanguage": "spanish", "inputText": "los pollos hermanos"}'
docker stack rm drogon

tags=(test nginx server)

for tag in ${tags[*]}; do
    docker tag "drogon:$tag" "$docker_user/drogon:$tag"
done

for tag in ${tags[*]}; do
    docker push "$docker_user/drogon:$tag"
done

docker tag drogon:runtime drogon:latest
docker tag drogon:runtime "$docker_user/drogon:latest"
docker push "$docker_user/drogon:latest"
