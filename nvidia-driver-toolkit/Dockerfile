FROM registry.opensuse.org/isv/rancher/harvester/os/v1.7/main/baseos-headers:v1.7

ARG TARGETARCH
RUN VERSION=$(curl -k -L -s https://dl.k8s.io/release/stable.txt) && \
    DOWNLOAD_URL="https://dl.k8s.io/release/${VERSION}/bin/linux/${TARGETARCH}/kubectl" && \
    curl -k -L -sSfLO "${DOWNLOAD_URL}" && \
    EXPECTED_HASH=$(curl -k -L -sSfL "${DOWNLOAD_URL}.sha256") && \
    echo "${EXPECTED_HASH}  kubectl" | sha256sum -c - && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

COPY entrypoint.sh /bin/entrypoint.sh
ENTRYPOINT ["/bin/entrypoint.sh"]
