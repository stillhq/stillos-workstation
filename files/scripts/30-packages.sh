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

dnf -y --refresh distro-sync --allowerasing --best \
  gdm gnome-shell mutter gnome-control-center gnome-session \
  gnome-settings-daemon gnome-initial-setup gnome-remote-desktop \
  xdg-desktop-portal xdg-desktop-portal-gnome gvfs \
  evolution-data-server gnome-online-accounts libgweather \
  pipewire wireplumber xorg-x11-server-Xwayland upower \
  iio-sensor-proxy switcheroo-control

echo "Installing all system packages..."
dnf install -y \
    https://kojipkgs.fedoraproject.org//packages/gnome-shell-extension-just-perfection/36.0/1.fc45/noarch/gnome-shell-extension-just-perfection-36.0-1.fc45.noarch.rpm \
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
    epiphany \
    broadcom-wl \
    webkit2gtk4.1

# Disabling broadcom WiFi drivers
ln -sf /dev/null /etc/modprobe.d/broadcom-wl-blacklist.conf
bash -c 'echo "blacklist wl" > /etc/modprobe.d/default-disable-broadcom-wl.conf'

# Removing Unused Software
dnf remove -y gnome-software gnome-tour gnome-extensions-app
dnf remove firefox -y
dnf config-manager --save --setopt=exclude=firefox
dnf autoremove
