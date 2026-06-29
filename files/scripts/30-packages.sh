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
dnf swap -y gnome-session-wayland-session stillos-session
dnf swap -y ptyxis still-terminal

echo "Installing all system packages..."
dnf install -y \
    https://kojipkgs.fedoraproject.org//packages/micro/2.0.11/10.fc41/x86_64/micro-2.0.11-10.fc41.x86_64.rpm \
    rsms-inter-fonts \
    rsms-inter-vf-fonts \
    still-control \
    still-terminal-nautilus \
    stillcenter \
    swai \
    swai-inst \
    stillcount-client \
    adw-gtk3-theme \
    gnome-shell-extension-desktop-icons-ng \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-just-perfection \
    stillexplore \
    quick-setup \
    still-zsh \
    git \
    lorax \
    distrobox \
    fuse \
    xdg-utils \
    glib2-devel \
    ntfs-3g \
    exfatprogs \
    wireguard-tools \
    NetworkManager-openvpn-gnome \
    lldb \
    gdb \
    epiphany \
    broadcom-wl \
    webkit2gtk4.1

swai-inst install https://gitlab.com/stillhq/stillOS/saDB-repo/-/raw/main/swai_apps/io-stillhq-forums.swai --share-directory /var/usrlocal/share

# Disabling broadcom WiFi drivers
ln -sf /dev/null /etc/modprobe.d/broadcom-wl-blacklist.conf
bash -c 'echo "blacklist wl" > /etc/modprobe.d/default-disable-broadcom-wl.conf'

# Removing Unused Software
dnf remove -y gnome-software gnome-tour gnome-extensions-app
dnf remove firefox -y
dnf config-manager --save --setopt=exclude=firefox
dnf autoremove
