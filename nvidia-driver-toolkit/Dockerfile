FROM registry.opensuse.org/isv/rancher/harvester/os/dev/main/baseos-headers:latest

RUN zypper update -y && \
    zypper install -y libopenssl1_1-hmac

COPY entrypoint.sh /bin/entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]