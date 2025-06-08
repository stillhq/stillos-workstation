#!/usr/bin/env bash

set -xeuo pipefail

# Example of how you start customizing the image

dnf install -y 'dnf-command(config-manager)'
dnf config-manager --set-enabled crb

dnf config-manager --add-repo https://gitlab.com/stillhq/stillOS/packages/stillos-release-final/-/raw/a10/stillos-alma.repo
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

