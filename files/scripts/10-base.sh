set -xeuo pipefail

dnf upgrade -y

dnf install -y 'dnf-command(config-manager)'
dnf config-manager --set-enabled crb
dnf config-manager --save --setopt=exclude=PackageKit,PackageKit-command-not-found,rootfiles

dnf config-manager --add-repo https://gitlab.com/stillhq/stillOS/packages/stillos-release-final/-/raw/a10/stillos-alma.repo
dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm

dnf install -y --nogpgcheck https://dl.fedoraproject.org/pub/epel/epel-release-latest-$(rpm -E %rhel).noarch.rpm
dnf install -y --nogpgcheck https://mirrors.rpmfusion.org/free/el/rpmfusion-free-release-$(rpm -E %rhel).noarch.rpm https://mirrors.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-$(rpm -E %rhel).noarch.rpm

crb enable

dnf install -y shim-x64
