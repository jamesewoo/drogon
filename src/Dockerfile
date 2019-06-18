FROM debian:stretch-slim as builder

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

RUN mkdir -p /usr/share/man/man1 && \
    apt-get update && \
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
        maven \
        ant-optional && \
    rm -rf /var/lib/apt/lists/* && \
    mvn clean package && \
    rm -rf src/test target/joshua-*-src* target/test-classes && \
    ./jni/build_kenlm.sh && \
    (cd ext/berkeleylm; ant) && \
    (cd thrax; ant) && \
    make -j -C ext/giza-pp all install && \
    make -j -C ext/symal all && \
    (cd ext/berkeleyaligner; ant)


FROM nginx AS runtime

ENV HADOOP_HOME /opt/hadoop
ENV HOME /root
ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV JOSHUA /opt/joshua
ENV PATH "${HADOOP_HOME}/bin:${PATH}"
ENV USER root

WORKDIR "$JOSHUA"

COPY --from=builder "$JOSHUA" .

RUN mkdir -p /usr/share/man/man1 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install --no-install-recommends -y \
        openjdk-8-jdk-headless \
        libboost-program-options-dev \
        libboost-system-dev \
        libboost-thread-dev \
        libboost-test-dev \
        file \
        perl \
        build-essential \
        ssh \
        rsync \
        curl \
        python && \
    rm -rf /var/lib/apt/lists/* && \
    HADOOP_VERSION=2.9.2 && \
    curl -SL "http://apache.mirrors.hoobly.com/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz" | \
    tar -xz && \
    mv "hadoop-$HADOOP_VERSION" "$HADOOP_HOME"

ENV MODELS_DIR /models
