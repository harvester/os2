FROM registry.opensuse.org/isv/rancher/harvester/os/v1.9/main/baseos-headers:v1.9

RUN \
	zypper -n ar --refresh --gpgcheck --priority 100 --enable 'https://public-dl.suse.com/SUSE/Products/SLE-BCI/16.0/$basearch/product/' SLE_BCI && \
	zypper -n ar --refresh --gpgcheck --priority 100 --disable 'https://public-dl.suse.com/SUSE/Products/SLE-BCI/16.0/$basearch/product_debug/' SLE_BCI_debug && \
	zypper -n ar --refresh --gpgcheck --priority 100 --disable 'https://public-dl.suse.com/SUSE/Products/SLE-BCI/16.0/$basearch/product_source/' SLE_BCI_source

CMD ["/bin/bash"]
