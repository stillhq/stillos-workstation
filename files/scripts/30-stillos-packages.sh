#!/usr/bin/env bash

set -xeuo pipefail

echo "Installing extra package groups"
dnf install -y --nobest  \
    @development \
    @legacy-unix \
    @rpm-development-tools \
    @system-tools


echo "Swapping GNOME"
dnf remove -y gnome-shell-extension-background-logo
dnf swap -y gnome-shell https://download.copr.fedorainfracloud.org/results/still/stillos-alma/epel-10-x86_64/09147899-gnome-shell/gnome-shell-47.4-2.el10.still.2.x86_64.rpm

echo "Installing stillOS Packages"
dnf install -y https://kojipkgs.fedoraproject.org//packages/gnome-shell-extension-just-perfection/34.0/1.el10_1/noarch/gnome-shell-extension-just-perfection-34.0-1.el10_1.noarch.rpm
dnf install -y still-control stillcenter swai swai-inst stillcount-client adw-gtk3-theme gnome-shell-extension-desktop-icons-ng

echo "Installing misc packages..."
dnf install -y git lorax \
    distrobox \
    fuse

systemctl disable rpm-ostree-countme.service
systemctl enable stillcount.service
systemctl enable sam.service

