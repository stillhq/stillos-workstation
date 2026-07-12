#!/usr/bin/env bash

set -xeuo pipefail

# Ensure NetworkManager creates DHCP profiles for previously unseen Ethernet
# devices. An empty value overrides any server-oriented no-auto-default policy.
cat > /etc/NetworkManager/conf.d/99-autoconnect-everything.conf << 'EOF'
[main]
no-auto-default=
EOF

# Also provide a hardware-independent fallback profile. multi-connect=3 allows
# the same profile to activate on every Ethernet adapter in the machine.
mkdir -p /etc/NetworkManager/system-connections
cat > /etc/NetworkManager/system-connections/stillos-wired.nmconnection << 'EOF'
[connection]
id=stillOS Wired
uuid=ff39089e-5f18-4ce9-b99f-66c763230fd1
type=ethernet
autoconnect=true
multi-connect=3

[ethernet]

[ipv4]
method=auto

[ipv6]
addr-gen-mode=default
method=auto

[proxy]
EOF
chmod 600 /etc/NetworkManager/system-connections/stillos-wired.nmconnection

# Disable Command Not Found PackageKit
sed -i -e 's/^SoftwareSourceSearch=true/SoftwareSourceSearch=false/' /etc/PackageKit/CommandNotFound.conf

# Add ZSH Config to Skel
curl -fsSL https://gitlab.com/stillhq/stillOS/still-zsh/-/raw/master/skel/.zshrc \
    -o /etc/skel/.zshrc

sed -i 's|^SHELL=.*|SHELL=/bin/zsh|' /etc/default/useradd

# Disable Countme and SystemD apply updates to use our own services
systemctl disable rpm-ostree-countme.service
rm -rf /etc/systemd/system/bootc-fetch-apply-updates.service.d
systemctl enable stillcount.service
systemctl enable sam.service

# Remove RHEL branding
rm /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.rhel.gschema.override

# GTK 4 defaults to its Vulkan renderer, but the NVK driver in AlmaLinux 10's
# Mesa can lose the nouveau device while GNOME Initial Setup renders its time
# zone page (Fedora bug 2359799). Keep the workaround scoped to the setup
# wizard; the regular desktop and applications can continue to use Vulkan.
sed -i \
    's|^Exec=/usr/libexec/gnome-initial-setup|Exec=/usr/bin/env GSK_RENDERER=gl /usr/libexec/gnome-initial-setup|' \
    /usr/share/applications/gnome-initial-setup.desktop \
    /etc/xdg/autostart/gnome-initial-setup-first-login.desktop
grep -q '^Exec=/usr/bin/env GSK_RENDERER=gl /usr/libexec/gnome-initial-setup' \
    /usr/share/applications/gnome-initial-setup.desktop
grep -q '^Exec=/usr/bin/env GSK_RENDERER=gl /usr/libexec/gnome-initial-setup' \
    /etc/xdg/autostart/gnome-initial-setup-first-login.desktop

# Use BGRT Plymouth Screen
sed -i 's/^Theme=.*/Theme=bgrt/' /etc/plymouth/plymouthd.conf
plymouth-set-default-theme -R bgrt
