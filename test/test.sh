#!/usr/bin/env bash
set -e

if [ "$1" = 'es' ]; then

    cd "$MODELS_DIR/es-en"

    for release in releases/apache-joshua-*; do
        # start HTTP server
        "$JOSHUA/bin/joshua" -m 8g -server-port "$JOSHUA_SERVER_PORT" -server-type http -c 1/tune/joshua.config.final \
            -top-n 1 -output-format "%S" -mark-oovs false -lower-case true -project-case true &

        # wait until the server is up
        until curl "localhost:$JOSHUA_SERVER_PORT/translate?q=yo+quiero+taco+bell"; do
            sleep 1
        done

        # run queries
        "$JOSHUA/scripts/support/query_http.py" -s localhost -p "$JOSHUA_SERVER_PORT" 1/data/test/test.es
    done

else

    exec "$@"

fi
