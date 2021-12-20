ARG LUET_VERSION=0.16.7
FROM quay.io/luet/base:$LUET_VERSION AS luet

FROM opensuse/leap:15.3 AS base

# Copy luet from the official images
COPY --from=luet /usr/bin/luet /usr/bin/luet

ARG ARCH=amd64
ENV ARCH=${ARCH}
RUN zypper mr --disable repo-non-oss repo-update-non-oss
RUN zypper --no-gpg-checks ref
RUN zypper update -y
COPY files/etc/luet/luet.yaml /etc/luet/luet.yaml

FROM base as tools
ENV LUET_NOLOCK=true
RUN zypper in -y docker squashfs xorriso
COPY tools /
RUN luet install -y toolchain/luet-makeiso

FROM base
ARG RANCHERD_VERSION=v0.0.1-alpha07
RUN zypper in -y \
    bash-completion \
    conntrack-tools \
    coreutils \
    curl \
    device-mapper \
    dosfstools \
    dracut \
    e2fsprogs \
    findutils \
    gawk \
    gptfdisk \
    grub2-i386-pc \
    grub2-x86_64-efi \
    haveged \
    iproute2 \
    iptables \
    iputils \
    issue-generator \
    jq \
    kernel-default \
    kernel-firmware-bnx2 \
    kernel-firmware-i915 \
    kernel-firmware-intel \
    kernel-firmware-iwlwifi \
    kernel-firmware-mellanox \
    kernel-firmware-network \
    kernel-firmware-platform \
    kernel-firmware-realtek \
    less \
    lsscsi \
    lvm2 \
    mdadm \
    multipath-tools \
    nano \
    nfs-utils \
    open-iscsi \
    open-vm-tools \
    parted \
    pigz \
    policycoreutils \
    procps \
    python-azure-agent \
    qemu-guest-agent \
    rng-tools \
    rsync \
    squashfs \
    strace \
    systemd \
    systemd-sysvinit \
    tar \
    timezone \
    vim \
    which \
    lshw

# Additional firmware packages
RUN zypper in -y kernel-firmware-chelsio \
    kernel-firmware-liquidio \
    kernel-firmware-mediatek \
    kernel-firmware-marvell \
    kernel-firmware-qlogic \
    kernel-firmware-usb-network \
    kernel-firmware-amdgpu kernel-firmware-nvidia kernel-firmware-radeon \
    ucode-intel ucode-amd

# Harvester needs these packages
RUN zypper in -y apparmor-parser \
    zstd \
    nginx

# Additional useful packages
RUN zypper in -y traceroute \
    tcpdump \
    lsof \
    sysstat \
    iotop \
    hdparm \
    pciutils \
    ethtool \
    dmidecode \
    numactl \
    ipmitool \
    kdump

RUN zypper clean

ARG CACHEBUST
RUN luet install -y \
    toolchain/yip \
    toolchain/luet \
    utils/installer@0.21.3 \
    system/cos-setup@0.5 \
    system/immutable-rootfs@0.2.0-12 \
    system/grub2-config \
    selinux/k3s \
    selinux/rancher \
    utils/k9s \
    utils/nerdctl \
    toolchain/yq

# Download rancherd binary to pin the version
RUN curl -o /usr/bin/rancherd -sfL "https://github.com/rancher/rancherd/releases/download/${RANCHERD_VERSION}/rancherd-amd64" && chmod 0755 /usr/bin/rancherd

# Create the folder for journald persistent data
RUN mkdir -p /var/log/journal

COPY files/ /
RUN mkinitrd

COPY os-release /usr/lib/os-release
