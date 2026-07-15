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
dnf swap -y gnome-shell https://download.copr.fedorainfracloud.org/results/still/stillos-alma/rhel+epel-10-x86_64/10712244-gnome-shell/gnome-shell-49.4-4.el10.still.1.x86_64.rpm
dnf install -y https://download.copr.fedorainfracloud.org/results/still/stillos-alma/rhel+epel-10-x86_64/10711911-mutter/mutter-common-49.4-7.el10.stillos.1.noarch.rpm
dnf swap -y mutter https://download.copr.fedorainfracloud.org/results/still/stillos-alma/rhel+epel-10-x86_64/10711911-mutter/mutter-49.4-7.el10.stillos.1.x86_64.rpm
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
    still-gnome-extension \
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
    webkit2gtk4.1 \
    nautilus-folder-icons \
    nautilus-my-computer 

# Removing Unused Software
dnf remove -y gnome-software gnome-tour gnome-extensions-app
dnf remove firefox -y
dnf config-manager --save --setopt=exclude=firefox
dnf autoremove
