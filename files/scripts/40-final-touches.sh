#!/usr/bin/env bash

set -xeuo pipefail

# Enable Network Autoconnections
cat > /etc/NetworkManager/conf.d/99-autoconnect-everything.conf << 'EOF'
[main]
# Force NM to create default connections for ALL interfaces
no-auto-default=*

[connection]
# Ensure those generated connections actually start up
connection.autoconnect=yes
EOF

# Disable Timezone and Network Spokes
mkdir -p /etc/anaconda/conf.d
cat > /etc/anaconda/conf.d/99-hide-spokes.conf << 'EOF'
[UI]
hidden_spokes =
    NetworkSpoke
    TimezoneSpoke
EOF

# Disable Command Not Found PackageKit
sed -i -e 's/^SoftwareSourceSearch=true/SoftwareSourceSearch=false/' /etc/PackageKit/CommandNotFound.conf

# Turn on ZSH
sed -i 's|^SHELL=.*|SHELL=/bin/zsh|' /etc/default/useradd

# Disable Countme and SystemD apply updates to use our own services
systemctl disable rpm-ostree-countme.service
rm -rf /etc/systemd/system/bootc-fetch-apply-updates.service.d
systemctl enable stillcount.service
systemctl enable sam.service
