FROM ubuntu:bionic as devel

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV JOSHUA /opt/joshua

WORKDIR $JOSHUA

COPY joshua .
COPY kenlm ext/kenlm/
COPY berkeleylm ext/berkeleylm/
COPY thrax thrax/
COPY giza-pp ext/giza-pp/
COPY symal ext/symal/
COPY berkeleyaligner ext/berkeleyaligner/

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
    (cd ext/berkeleylm; ant) && \
    (cd thrax; ant) && \
    make -j4 -C ext/giza-pp all install && \
    make -C ext/symal all && \
    (cd ext/berkeleyaligner; ant)


FROM ubuntu:bionic AS runtime

ENV JAVA_HOME /usr/lib/jvm/java-1.8.0-openjdk-amd64
ENV JOSHUA /opt/joshua

WORKDIR $JOSHUA

COPY --from=devel $JOSHUA .

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    openjdk-8-jdk-headless \
    libboost-program-options-dev \
    libboost-system-dev \
    libboost-thread-dev

