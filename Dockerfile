FROM ubuntu:bionic as devel

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV JOSHUA /opt/joshua

WORKDIR "$JOSHUA"

COPY joshua .
COPY kenlm ext/kenlm/
COPY berkeleylm ext/berkeleylm/
COPY thrax thrax/
COPY giza-pp ext/giza-pp/
COPY symal ext/symal/
COPY berkeleyaligner ext/berkeleyaligner/

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
        openjdk-8-jdk-headless \
        build-essential \
        libboost-all-dev \
        cmake \
        zlib1g-dev \
        libbz2-dev \
        liblzma-dev \
        python-minimal \
        python-pip \
        maven \
        ant-optional && \
    rm -rf /var/lib/apt/lists/* && \
    mvn clean package && \
    ./jni/build_kenlm.sh && \
    (cd ext/berkeleylm; ant) && \
    (cd thrax; ant) && \
    make -j -C ext/giza-pp all install && \
    make -j -C ext/symal all && \
    (cd ext/berkeleyaligner; ant)


FROM ubuntu:bionic AS runtime

ENV HADOOP_HOME /opt/hadoop
ENV HOME /root
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV JOSHUA /opt/joshua
ENV USER root

WORKDIR "$JOSHUA"

COPY --from=devel "$JOSHUA" .

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
        openjdk-8-jdk-headless \
        libboost-program-options-dev \
        libboost-system-dev \
        libboost-thread-dev \
        file \
        perl \
        build-essential \
        ssh \
        rsync \
        curl && \
    HADOOP_VERSION=2.9.2 && \
    curl -O "http://apache.mirrors.hoobly.com/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" && \
    tar xzf "hadoop-${HADOOP_VERSION}.tar.gz" && \
    rm "hadoop-${HADOOP_VERSION}.tar.gz" && \
    mv "hadoop-$HADOOP_VERSION" "$HADOOP_HOME" && \
    export PATH="$PATH:$HADOOP_HOME/bin"


FROM runtime AS debug

ENV SPANISH "$HOME/git/fisher-callhome-corpus"

WORKDIR "$HOME"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
        unzip \
        less \
        gdb && \
    (mkdir "$HOME/git" && \
        cd "$HOME/git" && \
        curl -o fisher-callhome-corpus.zip https://codeload.github.com/joshua-decoder/fisher-callhome-corpus/legacy.zip/master && \
        unzip fisher-callhome-corpus.zip && \
        mv joshua-decoder-*/ fisher-callhome-corpus)

RUN (mkdir -p "$HOME/expts/joshua" && \
        cd "$HOME/expts/joshua" && \
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
