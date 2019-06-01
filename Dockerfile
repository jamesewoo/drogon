FROM ubuntu:bionic

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
    build-essential \
    python-minimal \
    python-pip \
    maven \
    ant \
    libz-dev \
    libbz2-dev \
    liblzma-dev \
    libboost-all-dev && \
    rm -rf /var/lib/apt/lists/* && \
    pip install argparse \
        cmake && \
    mvn clean package
RUN ./jni/build_kenlm.sh && \
    $(cd $JOSHUA/ext/berkeleylm; ant) && \
    $(cd $JOSHUA/thrax; ant) && \
    make -j4 -C ext/giza-pp all install && \
    make -C ext/symal all && \
    $(cd $JOSHUA/ext/berkeleyaligner; ant)
    