FROM ubuntu:bionic

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV JOSHUA /opt/joshua

COPY joshua $JOSHUA
COPY kenlm $JOSHUA/ext/kenlm/
COPY berkeleylm $JOSHUA/ext/berkeleylm/
COPY thrax $JOSHUA/thrax/
COPY giza-pp $JOSHUA/ext/giza-pp/
COPY symal $JOSHUA/ext/symal/
COPY berkeleyaligner $JOSHUA/ext/berkeleyaligner/

WORKDIR $JOSHUA

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
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
    (cd $JOSHUA/ext/berkeleylm; ant) && \
    (cd $JOSHUA/thrax; ant) && \
    make -j4 -C ext/giza-pp all install && \
    make -C ext/symal all && \
    (cd $JOSHUA/ext/berkeleyaligner; ant)

