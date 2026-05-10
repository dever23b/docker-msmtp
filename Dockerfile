# syntax=docker/dockerfile:1

ARG MSMTP_VERSION=1.8.32
ARG ALPINE_VERSION=3.22

FROM --platform=$BUILDPLATFORM tonistiigi/xx AS xx
FROM --platform=$BUILDPLATFORM alpine:${ALPINE_VERSION} AS base
COPY --from=xx / /
RUN apk --update --no-cache add git make
ARG MSMTP_VERSION
WORKDIR /src
RUN git clone --depth 1 --branch "msmtp-${MSMTP_VERSION}" "http://git.marlam.de/git/msmtp.git"

FROM base AS builder
ARG TARGETPLATFORM
RUN xx-apk --no-cache --no-scripts add autoconf automake clang libgsasl-dev libtool libsecret-dev gettext gettext-dev texinfo pkgconf gnutls-dev
RUN <<EOT
  set -ex
  cd /src/msmtp
  autoreconf -fi
  CC=xx-clang CXX=xx-clang++ ./configure --host=$(xx-clang --print-target-triple) --prefix=/usr --sysconfdir=/etc --localstatedir=/var
  make -j$(nproc)
  make install
  xx-verify /usr/bin/msmtp
  xx-verify /usr/bin/msmtpd
EOT

FROM ghcr.io/linuxserver/baseimage-alpine:${ALPINE_VERSION}

RUN \
  apk --update --no-cache add \
  gnutls \
  libidn2 \
  libgsasl \
  libsecret \
  mailx \
  && ln -sf /usr/bin/msmtp /usr/sbin/sendmail \
  && rm -rf /tmp/*

COPY --from=builder /usr/bin/msmtp* /usr/bin
COPY root /

EXPOSE 25

HEALTHCHECK --interval=10s --timeout=5s --start-period=5s --retries=3 \
  CMD /app/healthcheck