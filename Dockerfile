FROM quay.io/costoolkit/releases-green:luet-toolchain-0.21.2 AS luet

FROM registry.opensuse.org/isv/rancher/harvester/baseos/main/baseos:latest AS base

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
    selinux/k3s \
    selinux/rancher \
    utils/nerdctl \
    toolchain/yq

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

# k9s
RUN mkdir -p /tmp/k9s && curl -o /tmp/k9s/k9s.tar.gz -sfL https://github.com/derailed/k9s/releases/download/v0.26.7/k9s_Linux_x86_64.tar.gz && tar xzf /tmp/k9s/k9s.tar.gz -C /tmp/k9s && mv /tmp/k9s/k9s /usr/bin && chmod +x /usr/bin/k9s && rm -rf /tmp/k9s

