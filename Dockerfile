FROM debian:stretch-slim

RUN for i in $(seq 1 8); do mkdir -p "/usr/share/man/man${i}"; done \
    && apt-get update && apt-get -y --quiet --allow-remove-essential upgrade \
    && apt-get install -y --quiet --no-install-recommends gnupg2 wget curl git cmake automake autoconf libtool libtool-bin build-essential pkg-config ca-certificates  \
    && apt-get update \
    && wget  --no-check-certificate  -O - https://files.freeswitch.org/repo/deb/freeswitch-1.8/fsstretch-archive-keyring.asc | apt-key add - \
    && echo "deb http://files.freeswitch.org/repo/deb/freeswitch-1.8/ stretch main" > /etc/apt/sources.list.d/freeswitch.list \
    && echo "deb-src http://files.freeswitch.org/repo/deb/freeswitch-1.8/ stretch main" >> /etc/apt/sources.list.d/freeswitch.list \
    && apt-get update \
    && apt-get -y --quiet --no-install-recommends build-dep freeswitch \
    && cd /usr/local/src \
    && git clone https://github.com/signalwire/freeswitch.git -b v1.10.1 freeswitch \
    && git clone https://github.com/davehorton/drachtio-freeswitch-modules.git -b master \
    && cd /usr/local/src/freeswitch/libs \
    && git clone https://github.com/warmcat/libwebsockets.git -b v3.2.0 \
    && cd libwebsockets && mkdir -p build && cd build && cmake .. && make && make install \
    && cd /usr/local/src/freeswitch/libs \
    && git clone https://github.com/dpirch/libfvad.git \
    && cd libfvad && autoreconf -i && ./configure && make && make install \
    && cd /usr/local/src/freeswitch/libs \
    && git clone https://github.com/grpc/grpc -b v1.24.2 \
    && cd grpc && git submodule update --init --recursive && cd third_party/protobuf && ./autogen.sh && ./configure && make install \
    && cd /usr/local/src/freeswitch/libs/grpc \
    && LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH make && make install \
    && cd /usr/local/src/freeswitch/libs \
    && git clone https://github.com/davehorton/googleapis -b dialogflow-v2-support \
    && cd googleapis && LANGUAGE=cpp make 

RUN cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_audio_fork /usr/local/src/freeswitch/src/mod/applications/mod_audio_fork \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_dialogflow /usr/local/src/freeswitch/src/mod/applications/mod_dialogflow \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_google_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_google_transcribe \
    && cp -r /usr/local/src/drachtio-freeswitch-modules/modules/mod_google_tts /usr/local/src/freeswitch/src/mod/applications/mod_google_tts 

COPY ./*.patch /
COPY ./*.grpc /
COPY ./vars_diff.xml /
COPY ./mod_yandex_transcribe /usr/local/src/freeswitch/src/mod/applications/mod_yandex_transcribe 

RUN cd /usr/local/src/freeswitch \
    && mv /configure.ac.patch . \
    && mv /configure.ac.grpc.patch . \
    && mv /Makefile.am.patch . \
    && mv /Makefile.am.grpc.patch . \
    && mv /modules.conf.in.patch  ./build/ \
    && mv /modules.conf.in.grpc.patch  ./build/ \
    && mv /modules.conf.vanilla.xml.grpc ./conf/vanilla/autoload_configs/modules.conf.xml \
    && mv /mod_opusfile.c.patch ./src/mod/formats/mod_opusfile \
    && patch < configure.ac.patch \
    && patch < configure.ac.grpc.patch \
    && patch < Makefile.am.patch \
    && patch Makefile.am.grpc.patch \
    && cd build \
    && patch < modules.conf.in.patch \
    && patch < modules.conf.in.grpc.patch \
    && cd ../src/mod/formats/mod_opusfile \
    && patch < mod_opusfile.c.patch

RUN cd /usr/local/src/freeswitch \
    && ./bootstrap.sh -j \
    && ./configure --with-lws=yes --with-grpc=yes

#RUN cd /usr/local/src/freeswitch \
#    && make && make install && make cd-sounds-install cd-moh-install
