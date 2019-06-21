FROM jwoo11/drogon:runtime AS trainer

ENV SPANISH "$HOME/git/fisher-callhome-corpus"

WORKDIR "$HOME"

RUN (mkdir -p git/fisher-callhome-corpus && \
        cd git && \
        curl -SL https://codeload.github.com/joshua-decoder/fisher-callhome-corpus/tar.gz/master | \
        tar --strip-components=1 -xzC fisher-callhome-corpus) && \
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
