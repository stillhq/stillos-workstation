#!/usr/bin/env bash

set -xeuo pipefail

if [[ -z "${VARIANT}" ]]; then
    echo "Building base variant (no additional packages)"

    # Enable RPM Fusion repositories without installing NVIDIA packages.
    dnf install --nogpgcheck -y \
        https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm \
        https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm

else
    echo "Unknown variant: ${VARIANT}"
    exit 1

fi
