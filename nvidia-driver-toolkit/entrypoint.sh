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

install_nvidia_driver() {
    local driver_location="$1"
    
    if [ -n "$driver_location" ]; then
        echo "Installing nvidia driver from $driver_location"
        curl -o /tmp/NVIDIA.run -k "$driver_location"
        chmod +x /tmp/NVIDIA.run
        /tmp/NVIDIA.run -q --ui=none --no-systemd
    else
        echo "No driver location specified. Skipping driver installation..."
    fi
}

get_nvidia_driver_version() {
  local driver_location="$DRIVER_LOCATION"  # Default driver location
  local annotation_key="sriovgpu.harvesterhci.io/custom-driver"
  local node_name="$NODE_NAME"
  local custom_driver=$(kubectl get node "$node_name" -o json | jq -r ".metadata.annotations[\"$annotation_key\"] // empty")

  if [ -n "$custom_driver" ]; then
    echo >&2 "Found custom driver annotation: $annotation_key=$custom_driver"
    driver_location="$custom_driver"
  else
    echo >&2 "No custom driver annotation found. Using default driver location."
  fi

  echo $driver_location
}

driver_location=$(get_nvidia_driver_version)
echo "Driver location: $driver_location"
install_nvidia_driver "$driver_location"

echo "running nvidia vgpud"
create_dev_char_directory
/usr/bin/nvidia-vgpud
/usr/bin/nvidia-vgpu-mgr

echo "driver ready" > /tmp/ready

tail -f /dev/null
