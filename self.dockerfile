FROM alpine:edge

ARG INSTALL_FFMPEG=false

WORKDIR /opt/alist/

RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache bash ca-certificates su-exec tzdata; \
    [ "$INSTALL_FFMPEG" = "true" ] && apk add --no-cache ffmpeg; \
    rm -rf /var/cache/apk/*

ADD ./bin/alist-linux-amd64 ./alist
