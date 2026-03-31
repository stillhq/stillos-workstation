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
dnf swap -y gnome-shell https://download.copr.fedorainfracloud.org/results/still/stillos-alma/alma+epel-10-x86_64_v2/10280318-gnome-shell/gnome-shell-47.4-3.el10.still.1.x86_64_v2.rpm
dnf swap -y mutter https://download.copr.fedorainfracloud.org/results/still/stillos-alma/alma+epel-10-x86_64_v2/10280356-mutter/mutter-47.5-8.el10.x86_64_v2.rpm
dnf swap -y gnome-session-wayland-session stillos-session
dnf swap -y ptyxis still-terminal

echo "Installing all system packages..."
dnf install -y \
    https://kojipkgs.fedoraproject.org//packages/gnome-shell-extension-just-perfection/35.0/1.el10_2/noarch/gnome-shell-extension-just-perfection-35.0-1.el10_2.noarch.rpm \
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
    qemu-kvm \
    libvirt \
    libvirt-client \
    virt-install \
    virt-top \
    bridge-utils \
    libguestfs-tools \
    virt-manager \
    epiphany

# Removing Unused Software
dnf remove -y gnome-software gnome-tour gnome-extensions-app
dnf remove firefox -y
dnf config-manager --save --setopt=exclude=firefox
dnf autoremove
