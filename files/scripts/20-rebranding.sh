#!/usr/bin/env bash

set -xeuo pipefail

# Swap almalinux-release for stillos-release. We do this early because it contains EPEL
## Delete EULA folder to replace it from the stillos-release
# echo "Swapping OS release files"
# rm -rf /usr/share/almalinux-release 

# Branding
dnf swap -y almalinux-logos stillos-logos
dnf swap -y almalinux-backgrounds stillos-backgrounds-1000
dnf swap -y plymouth-theme-spinner https://download.copr.fedorainfracloud.org/results/still/stillos-alma/alma+epel-10-x86_64_v2/10461721-plymouth-theme-still-spinner/plymouth-theme-still-spinner-0.9.5-6.el10.noarch.rpm
# Flatpak
mkdir -p /etc/flatpak/remotes.d
curl \
    --retry 3 \
    -o /etc/flatpak/remotes.d/flathub.flatpakrepo \
    https://dl.flathub.org/repo/flathub.flatpakrepo

# Enable sudo password bubbles
echo 'Defaults pwfeedback' | tee /etc/sudoers.d/pwfeedback
