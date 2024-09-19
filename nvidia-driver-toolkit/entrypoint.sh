#!/bin/bash

set -e

if [ -f /tmp/ready ]
then
  rm /tmp/ready
fi

# fix from: https://gitlab.com/nvidia/container-images/driver/-/commit/94324dc6dbaff191b72a734b7734710110d82198
# Create /dev/char directory if it doesn't exist inside the container.
# Without this directory, nvidia-vgpu-mgr will fail to create symlinks
# under /dev/char for new devices nodes.
create_dev_char_directory() {
	if [ ! -d "/dev/char" ]; then
		echo "Creating '/dev/char' directory"
		mkdir -p /dev/char
	fi
}


if [ -n "${DRIVER_LOCATION}" ]
then
    echo "Installing nvidia driver from ${DRIVER_LOCATION}"
    curl -o /tmp/NVIDIA.run -k $DRIVER_LOCATION
    chmod +x /tmp/NVIDIA.run
    /tmp/NVIDIA.run -q --ui=none --no-systemd
else
    echo "No DRIVER_LOCATION specified. skipping..."
fi

# update nvidia driver firmware search path
# /run/nvidia/driver/lib/firmware is mount under /lib/firmware in the container 
# by the daemonset manifests
EXISTS=$(grep '/run/nvidia/driver/lib/firmware' /sys/module/firmware_class/parameters/path)
if [ -z "${EXISTS}" ]
then
    echo "Adding firmware search path to /sys/module/firmware_class/parameters/path"
    echo  '/run/nvidia/driver/lib/firmware' > /sys/module/firmware_class/parameters/path
fi

echo "running nvidia vgpud"
create_dev_char_directory
/usr/bin/nvidia-vgpud
/usr/bin/nvidia-vgpu-mgr

echo "driver ready" > /tmp/ready

tail -f /dev/null
