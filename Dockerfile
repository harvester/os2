# syntax=docker/dockerfile:1.7.0

FROM registry.opensuse.org/isv/rancher/harvester/os/v1.8/main/baseos:v1.8 AS base

ARG CACHEBUST

# elemental init first
RUN elemental init --force

# Fix https://github.com/harvester/harvester/issues/5945
RUN chmod 644 /usr/lib/systemd/system/elemental*{service,timer} /usr/lib/dracut/modules.d/*elemental*/*service

# Create the folder for journald persistent data
RUN mkdir -p /var/log/journal

# Create necessary cloudconfig folders so that elemental cli won't show warnings during installation
RUN mkdir -p /usr/local/cloud-config
RUN mkdir -p /oem

# Enable /tmp to be on tmpfs (was /usr/share/systemd/tmp.mount previously)
RUN cp /usr/lib/systemd/system/tmp.mount /etc/systemd/system

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
ARG RANCHERD_VERSION=v0.7.0-rc2
RUN curl -o /usr/bin/rancherd -sfL "https://github.com/harvester/rancherd/releases/download/${RANCHERD_VERSION}/rancherd-${ARCH}" && chmod 0755 /usr/bin/rancherd

# Download nerdctl
ARG NERDCTL_VERSION=1.2.1
RUN curl -o ./nerdctl-bin.tar.gz -sfL "https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/nerdctl-${NERDCTL_VERSION}-linux-${ARCH}.tar.gz"
RUN tar -zxvf nerdctl-bin.tar.gz && mv nerdctl /usr/bin/
RUN rm -f nerdctl-bin.tar.gz containerd-rootless-setuptool.sh containerd-rootless.sh

# Remove files that need to be unique on each host.
# These will be generated automatically at runtime.
# See https://github.com/harvester/harvester/issues/6911 for details
RUN rm -f /etc/machine-id /etc/iscsi/initiatorname.iscsi /etc/nvme/hostid /etc/nvme/hostnqn

# NetworkManager should already be enabled by default when it's installed,
# but adding it here anyway to make it explicit.  NetworkManager-dispatcher
# is also enabled, even though we're not currently taking advantage of any
# dispatcher scripts, but rather just to get rid of a whole lot of annoying
# errors in the journal along the lines of "Activation via systemd failed
# for unit 'dbus-org.freedesktop.nm-dispatcher.service'")
RUN systemctl enable NetworkManager.service && \
    systemctl enable NetworkManager-dispatcher.service
