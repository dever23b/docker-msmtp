ARG VARIANT="noble"
FROM buildpack-deps:${VARIANT}-curl

LABEL dev.containers.features="common"

ARG VARIANT

RUN if [ "${VARIANT}" = "noble" ]; then \
  if id "ubuntu" &> /dev/null; then \
  echo "Deleting user 'ubuntu' for $VARIANT" && userdel -f -r ubuntu || echo "Failed to delete ubuntu user for $VARIANT"; \
  else \
  echo "User 'ubuntu' does not exist for $VARIANT"; \
  fi; \
  fi

ARG DEBIAN_FRONTEND="noninteractive"

RUN <<EOT
  apt update
  apt install -y --no-install-recommends \
    acl \
    dnsutils \
    inetutils-ping \
    inetutils-traceroute \
    msmtp \
    msmtp-mta \
    netcat-traditional
  apt update
  apt upgrade
  apt clean
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EOT