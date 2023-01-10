FROM quay.io/costoolkit/releases-teal:luet-toolchain-0.33.0-2 AS luet

FROM registry.opensuse.org/isv/rancher/harvester/baseos53/main/baseos:latest AS base

COPY --from=luet /usr/bin/luet /usr/bin/luet
COPY files/etc/luet/luet.yaml /etc/luet/luet.yaml

# Necessary for luet to run
RUN mkdir -p /run/lock

ARG CACHEBUST
RUN luet install -y \
    toolchain/yip \
    system/cos-setup \
    system/immutable-rootfs \
    system/grub2-config \
    system/grub2-efi-image \
    system/grub2-artifacts \
    selinux/k3s \
    selinux/rancher \
    utils/nerdctl \
    toolchain/yq \
    utils/k9s \
    toolchain/elemental-cli

# Create the folder for journald persistent data
RUN mkdir -p /var/log/journal

# Create necessary cloudconfig folders so that elemental cli won't show warnings during installation
RUN mkdir -p /usr/local/cloud-config
RUN mkdir -p /oem

COPY files/ /
RUN mkinitrd

# Append more options
COPY os-release /tmp
RUN cat /tmp/os-release >> /usr/lib/os-release && rm -f /tmp/os-release

# Remove /etc/cos/config to use default values
RUN rm -f /etc/cos/config

# Download rancherd
ARG RANCHERD_VERSION=v0.0.1-alpha14
RUN curl -o /usr/bin/rancherd -sfL "https://github.com/rancher/rancherd/releases/download/${RANCHERD_VERSION}/rancherd-amd64" && chmod 0755 /usr/bin/rancherd
