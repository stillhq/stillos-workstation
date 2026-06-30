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

# Install Nautilus extensions system-wide
mkdir -p /usr/share/nautilus-python/extensions /usr/share/glib-2.0/schemas
curl -fsSL https://raw.githubusercontent.com/yannmasoch/nautilus-my-computer/dev/nautilus-my-computer.py \
    -o /usr/share/nautilus-python/extensions/nautilus-my-computer.py
curl -fsSL https://raw.githubusercontent.com/yannmasoch/nautilus-my-computer/dev/io.github.yannmasoch.nautilus-my-computer.gschema.xml \
    -o /usr/share/glib-2.0/schemas/io.github.yannmasoch.nautilus-my-computer.gschema.xml
curl -fsSL https://raw.githubusercontent.com/MacTavishAO/nautilus-admin-gtk4/refs/heads/master/extension/nautilus-admin.py \
    -o /usr/share/nautilus-python/extensions/nautilus-admin.py
sed -i \
    -e 's|@NAUTILUS_PATH@|/usr/bin/nautilus|g' \
    -e 's|@CMAKE_INSTALL_PREFIX@|/usr|g' \
    /usr/share/nautilus-python/extensions/nautilus-admin.py
glib-compile-schemas /usr/share/glib-2.0/schemas

# Disable Command Not Found PackageKit
sed -i -e 's/^SoftwareSourceSearch=true/SoftwareSourceSearch=false/' /etc/PackageKit/CommandNotFound.conf

# Turn on ZSH
curl -fsSL https://gitlab.com/stillhq/stillOS/still-zsh/-/raw/master/skel/.zshrc?ref_type=heads \
    -o /etc/skel/.zshrc
cp /etc/skel/.zshrc /var/roothome/.zshrc

sed -i 's|^SHELL=.*|SHELL=/bin/zsh|' /etc/default/useradd

# Disable Countme and SystemD apply updates to use our own services
systemctl disable rpm-ostree-countme.service
rm -rf /etc/systemd/system/bootc-fetch-apply-updates.service.d
systemctl enable stillcount.service
systemctl enable sam.service

# Remove RHEL branding
rm /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.rhel.gschema.override
