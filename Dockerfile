# syntax=docker/dockerfile:1.7.0

FROM registry.opensuse.org/isv/rancher/harvester/os/dev/main/baseos:latest AS base

ARG CACHEBUST

# elemental init first
RUN elemental init --force

# Create the folder for journald persistent data
RUN mkdir -p /var/log/journal

# Create necessary cloudconfig folders so that elemental cli won't show warnings during installation
RUN mkdir -p /usr/local/cloud-config
RUN mkdir -p /oem

# Enable /tmp to be on tmpfs
RUN cp /usr/share/systemd/tmp.mount /etc/systemd/system

COPY files/ /

# remove unused 05_network.yaml
RUN rm -f /system/oem/05_network.yaml

# Append more options
COPY os-release /tmp
RUN cat /tmp/os-release >> /usr/lib/os-release && rm -f /tmp/os-release

# Remove /etc/cos/config to use default values
RUN rm -f /etc/cos/config

ARG TARGETPLATFORM

RUN if [ "$TARGETPLATFORM" != "linux/amd64" ] && [ "$TARGETPLATFORM" != "linux/arm64" ]; then \
    echo "Error: Unsupported TARGETPLATFORM: $TARGETPLATFORM" && \
    exit 1; \
    fi

ENV ARCH=${TARGETPLATFORM#linux/}

# Download rancherd
ARG RANCHERD_VERSION=v0.3.0-rc1
RUN curl -o /usr/bin/rancherd -sfL "https://github.com/rancher/rancherd/releases/download/${RANCHERD_VERSION}/rancherd-${ARCH}" && chmod 0755 /usr/bin/rancherd

# Download nerdctl
ARG NERDCTL_VERSION=1.2.1
RUN curl -o ./nerdctl-bin.tar.gz -sfL "https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION}-linux-${ARCH}.tar.gz"
RUN tar -zxvf nerdctl-bin.tar.gz && mv nerdctl /usr/bin/
RUN rm -f nerdctl-bin.tar.gz containerd-rootless-setuptool.sh containerd-rootless.sh
