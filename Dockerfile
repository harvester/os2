FROM quay.io/costoolkit/releases-teal:luet-toolchain-0.33.0-2 AS luet

FROM registry.opensuse.org/isv/rancher/harvester/os/dev/main/baseos:latest AS base

COPY --from=luet /usr/bin/luet /usr/bin/luet
COPY files/etc/luet/luet.yaml /etc/luet/luet.yaml

# Necessary for luet to run
RUN mkdir -p /run/lock

ARG CACHEBUST
RUN luet install -y \
    system/cos-setup \
    system/immutable-rootfs \
    system/grub2-config \
    system/grub2-efi-image \
    system/grub2-artifacts \
    selinux/k3s \
    selinux/rancher \
    toolchain/yq \
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

# Download virtctl
ARG VIRTCTL_VERSION=v0.55.2
RUN curl -o /usr/bin/virtctl -sfL "https://github.com/kubevirt/kubevirt/releases/download/${VIRTCTL_VERSION}/virtctl-${VIRTCTL_VERSION}-linux-amd64" && chmod 0755 /usr/bin/virtctl

# Download yip
ARG YIP_VERSION=v1.0.0
RUN curl -o /usr/bin/yip -sfL "https://github.com/mudler/yip/releases/download/${YIP_VERSION}/yip-${YIP_VERSION}-linux-amd64" && chmod 0755 /usr/bin/yip

# Download nerdctl
ARG NERDCTL_VERSION=1.2.1
RUN curl -o ./nerdctl-bin.tar.gz -sfL "https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION}-linux-amd64.tar.gz"
RUN tar -zxvf nerdctl-bin.tar.gz && mv nerdctl /usr/bin/
RUN rm -f nerdctl-bin.tar.gz containerd-rootless-setuptool.sh containerd-rootless.sh