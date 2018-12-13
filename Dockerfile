FROM alpine:latest

MAINTAINER BlueBoxDev <thanakorn.vsalab@gmail.com>

ENV VERSION=1.5.4 \
    DOWNLOAD_SHA256=5fd7f3454fd6d286645d032bc07f44a1c8583cec02ef2422c9eb32e0a89a9b2f \
    GPG_KEYS=A0D6EEA1DCAE49A635A3B2F0779B22DFB3E717B7

# Install packages Broker
RUN apk --no-cache add --virtual build-deps \
        build-base \
        cmake \
        gnupg \
        util-linux-dev \
        openssl-dev && \
    wget https://mosquitto.org/files/source/mosquitto-1.5.4.tar.gz -O /tmp/mosq.tar.gz && \
    echo "5fd7f3454fd6d286645d032bc07f44a1c8583cec02ef2422c9eb32e0a89a9b2f  /tmp/mosq.tar.gz" | sha256sum -c - && \
    wget https://mosquitto.org/files/source/mosquitto-1.5.4.tar.gz.asc -O /tmp/mosq.tar.gz.asc && \
    export GNUPGHOME="$(mktemp -d)" && \
    found=''; \
    for server in \
        ha.pool.sks-keyservers.net \
        hkp://keyserver.ubuntu.com:80 \
        hkp://p80.pool.sks-keyservers.net:80 \
        pgp.mit.edu \
    ; do \
        echo "Fetching GPG key $GPG_KEYS from $server"; \
        gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "A0D6EEA1DCAE49A635A3B2F0779B22DFB3E717B7" && found=yes && break; \
    done; \
    test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
    gpg --batch --verify /tmp/mosq.tar.gz.asc /tmp/mosq.tar.gz && \
    gpgconf --kill all && \
    rm -rf "$GNUPGHOME" /tmp/mosq.tar.gz.asc && \
    mkdir -p /build/mosq && \
    tar --strip=1 -xf /tmp/mosq.tar.gz -C /build/mosq && \
    rm /tmp/mosq.tar.gz && \
    make -C /build/mosq -j "$(nproc)" && \
    addgroup -S mosquitto 2>/dev/null && \
    adduser -S -D -H -h /var/empty -s /sbin/nologin -G mosquitto -g mosquitto mosquitto 2>/dev/null && \
    mkdir -p /mosquitto/config /mosquitto/data /mosquitto/log && \
    install -d /usr/sbin/ && \
    install -s -m755 /build/mosq/src/mosquitto /usr/sbin/mosquitto && \
    install -s -m755 /build/mosq/src/mosquitto_passwd /usr/bin/mosquitto_passwd && \
    install -m644 /build/mosq/mosquitto.conf /mosquitto/config/mosquitto.conf && \
    chown -R mosquitto:mosquitto /mosquitto && \
    apk --no-cache add \
    libuuid && \
    apk del build-deps && \
    apk --no-cache add --virtual build-deps \
        build-base \
        cmake \
        gnupg \
        util-linux-dev \
        libressl-dev \
        mosquitto-dev \
        mysql-dev \
        openssl \
        git && \
    git clone https://github.com/jpmens/mosquitto-auth-plug.git && \
    cd mosquitto-auth-plug/ && wget https://raw.githubusercontent.com/bluebox-dev/MQTT-Auth/master/config.mk && \
    make && mv auth-plug.so  /mosquitto/config/ && cd / && rm -rf mosquitto-auth-plug && \
    apk --no-cache add \
    libuuid && \
    apk del build-deps && \
    apk --no-cache add util-linux-dev \
        libressl-dev \
        mosquitto-dev \
        mysql-dev \
        openssl && \
    rm -rf /build

# MQTT Dir Config
VOLUME ["/mosquitto/log","/mosquitto/data"]

# Expose MQTT port
EXPOSE 1883

#Default Command
CMD [ "mosquitto","-c","/mosquitto/config/mosquitto.conf" ]
