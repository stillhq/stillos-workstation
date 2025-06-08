#!/usr/bin/env bash

set -xeuo pipefail

# Swap almalinux-release for stillos-release. We do this early because it contains EPEL
## Delete EULA folder to replace it from the stillos-release
echo "Swapping OS release files"
rm -rf /usr/share/almalinux-release 

dnf swap -y almalinux-release stillos-release
dnf swap -y almalinux-repos stillos-repos
dnf install -y stillos-gpg-keys

# Branding
dnf swap -y almalinux-logos stillos-logos
dnf swap -y almalinux-backgrounds stillos-backgrounds

# Flatpak
mkdir -p /etc/flatpak/remotes.d
curl \
    --retry 3 \
    -o /etc/flatpak/remotes.d/flathub.flatpakrepo \
    https://dl.flathub.org/repo/flathub.flatpakrepo
