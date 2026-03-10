FROM registry.opensuse.org/isv/rancher/harvester/os/v1.9/main/baseos-headers:v1.9

ARG TARGETARCH
RUN VERSION=$(curl -sSfL "https://dl.k8s.io/release/stable.txt") && \
    DOWNLOAD_URL="https://dl.k8s.io/release/${VERSION}/bin/linux/${TARGETARCH}/kubectl" && \
    curl -sSfLO "${DOWNLOAD_URL}" && \
    EXPECTED_HASH=$(curl -sSfL "${DOWNLOAD_URL}.sha256") && \
    echo "${EXPECTED_HASH}  kubectl" | sha256sum -c - && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

COPY entrypoint.sh /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]
