FROM jwoo11/drogon:runtime AS train

ENV JOSHUA_SERVER_PORT 5674
ENV SPANISH "$HOME/git/fisher-callhome-corpus"

WORKDIR "$HOME"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
        unzip \
        less && \
    (mkdir git && \
        cd git && \
        curl -o fisher-callhome-corpus.zip https://codeload.github.com/joshua-decoder/fisher-callhome-corpus/legacy.zip/master && \
        unzip fisher-callhome-corpus.zip && \
        mv joshua-decoder-*/ fisher-callhome-corpus) && \
    (mkdir -p expts/joshua && \
        cd expts/joshua && \
        "$JOSHUA/bin/pipeline.pl" \
            --type hiero \
            --rundir 1 \
            --readme "Baseline Hiero run" \
            --source es \
            --target en \
            --witten-bell \
            --corpus "$SPANISH/corpus/asr/callhome_train" \
            --corpus "$SPANISH/corpus/asr/fisher_train" \
            --tune "$SPANISH/corpus/asr/fisher_dev" \
            --test "$SPANISH/corpus/asr/callhome_devtest" \
            --lm-order 3)
            
            
FROM train AS test

WORKDIR "$HOME"

RUN (cd expts/joshua && \
        "$JOSHUA/scripts/language-pack/build_lp.sh" es-en 1/tune/joshua.config.final 8g && \
        for release in releases/apache-joshua-*; do \
            "$JOSHUA/bin/joshua" -m 8g -server-port "$JOSHUA_SERVER_PORT" -server-type http -c 1/tune/joshua.config.final \
                -top-n 1 -output-format "%S" -mark-oovs false -lower-case true -project-case true & \
            until curl "localhost:$JOSHUA_SERVER_PORT/translate?q=yo+quiero+taco+bell"; do \
                sleep 1; \
            done; \
        done)
