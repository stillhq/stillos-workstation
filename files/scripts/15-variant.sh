#!/usr/bin/env bash

set -xeuo pipefail

if [[ -z "${VARIANT}" ]]; then
    echo "Building base variant (no additional packages)"
    # No additional packages for base variant

elif [[ "${VARIANT}" == "nvidia" ]]; then
    echo "Building nvidia variant"
    
    # Install RPM Fusion repositories (required for NVIDIA packages)
    dnf install --nogpgcheck -y \
        https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm
    
    # Install NVIDIA drivers and related packages
    dnf install -y \
        akmod-nvidia \
        xorg-x11-drv-nvidia-cuda

    # Fix boot environmental variable
    echo "GSK_RENDERER=ngl" >> /etc/environment

else
    echo "Unknown variant: ${VARIANT}"
    exit 1

fi
