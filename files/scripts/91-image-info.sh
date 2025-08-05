#!/usr/bin/env bash

# DO NOT MODIFY THIS FILE UNLESS YOU KNOW WHAT YOU ARE DOING

set -xeuo pipefail

cat << 'EOF' > /etc/os-release
NAME="stillOS"
VERSION="10 Preview 2 (The Becoming)"
ID="stillos"
ID_LIKE="almalinux rhel centos fedora"
VERSION_ID="10"
PLATFORM_ID="platform:el10"
PRETTY_NAME="stillOS 10 Preview (The Becoming)"
ANSI_COLOR="0;34"
LOGO="fedora-logo-icon"
CPE_NAME="cpe:/o:almalinux:almalinux:10::baseos"
HOME_URL="https://almalinux.org/"
DOCUMENTATION_URL="https://wiki.almalinux.org/"
VENDOR_NAME="AlmaLinux"
VENDOR_URL="https://almalinux.org/"
BUG_REPORT_URL="https://bugs.almalinux.org/"

ALMALINUX_MANTISBT_PROJECT="AlmaLinux-10"
ALMALINUX_MANTISBT_PROJECT_VERSION="10"
REDHAT_SUPPORT_PRODUCT="AlmaLinux"
REDHAT_SUPPORT_PRODUCT_VERSION="10"
EOF