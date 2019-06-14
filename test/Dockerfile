FROM jwoo11/drogon:runtime AS trainer

ENV MODELS_DIR /models
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
    (mkdir -p "$MODELS_DIR/es-en" && \
        cd "$MODELS_DIR/es-en" && \
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


FROM trainer AS tester

ENV JOSHUA_SERVER_PORT 5674

WORKDIR "$MODELS_DIR/es-en"

COPY test.sh .

RUN "$JOSHUA/scripts/language-pack/build_lp.sh" es-en 1/tune/joshua.config.final 8g

ENTRYPOINT ["./test.sh"]

CMD ["es"]
