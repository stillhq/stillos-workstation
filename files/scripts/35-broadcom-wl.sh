#!/usr/bin/env bash

set -xeuo pipefail

# Broadcom's proprietary source and RPM Fusion's complete compatibility patch
# set are embedded in this exact akmod RPM. Pinning the NEVRA and embedded SRPM
# checksum prevents a repository update from silently changing either input.
readonly wl_version=6.30.223.271
readonly akmod_release=62.el10
readonly broadcom_release=26.el10
readonly wl_srpm_sha256=fb8c555169f429259c8881564412700c816682d4822e52862fcc182cb58ef8f6
readonly script_dir=$(realpath "$(dirname "$0")")

mapfile -t kernel_releases < <(
    find /usr/lib/modules -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
)
if [[ ${#kernel_releases[@]} -ne 1 ]]; then
    echo "Expected exactly one installed kernel, found: ${kernel_releases[*]:-(none)}" >&2
    exit 1
fi
readonly kernel_release=${kernel_releases[0]}

echo "Building Broadcom wl for ${kernel_release}"

# kernel-devel-uname-r is an exact virtual provide. This deliberately follows
# the kernel selected by 10-base.sh's dnf upgrade instead of uname -r, which is
# the image builder host's kernel inside a container build.
dnf install -y \
    "kernel-devel-uname-r = ${kernel_release}" \
    "akmod-wl-${wl_version}-${akmod_release}" \
    "broadcom-wl-${wl_version}-${broadcom_release}"

test -e "/usr/lib/modules/${kernel_release}/build/Makefile"

work_dir=$(mktemp -d /tmp/stillos-wl-build.XXXXXX)
cleanup_wl_build() {
    rm -rf -- "${work_dir}"
}
trap cleanup_wl_build EXIT

readonly packaged_srpm="/usr/src/akmods/wl-kmod-${wl_version}-${akmod_release}.src.rpm"
echo "${wl_srpm_sha256}  ${packaged_srpm}" | sha256sum --check --strict

mkdir -p "${work_dir}/SOURCES" "${work_dir}/SPECS" \
    "${work_dir}/BUILD" "${work_dir}/BUILDROOT" \
    "${work_dir}/RPMS" "${work_dir}/SRPMS"
(
    cd "${work_dir}/SOURCES"
    rpm2cpio "${packaged_srpm}" | cpio -idm
)
mv "${work_dir}/SOURCES/wl-kmod.spec" "${work_dir}/SPECS/wl-kmod.spec"

# RPM Fusion 62 handles upstream kernels through 7.1, but its EL10 condition
# does not account for RHEL 10.2's backport of the 6.17 cfg80211 radio-index
# API. Apply the repository-pinned spec patch before producing our source RPM.
patch --directory="${work_dir}/SPECS" --fuzz=0 -p1 \
    < "${script_dir}/patches/wl-kmod-62-rhel-10.2-radio-index.patch"
sed -i 's/^Release:[[:space:]]*62%{?dist}$/Release:    62.stillos.1%{?dist}/' \
    "${work_dir}/SPECS/wl-kmod.spec"
grep -q '^Release:[[:space:]]*62\.stillos\.1%{?dist}$' \
    "${work_dir}/SPECS/wl-kmod.spec"

rpmbuild -bs \
    --define "_topdir ${work_dir}" \
    "${work_dir}/SPECS/wl-kmod.spec"

readonly stillos_srpm=$(find "${work_dir}/SRPMS" -maxdepth 1 -type f \
    -name 'wl-kmod-*.src.rpm' -print -quit)
test -n "${stillos_srpm}"

rpmbuild --rebuild --with kmod \
    --define "_topdir ${work_dir}" \
    --define "kernels ${kernel_release}" \
    "${stillos_srpm}"

readonly kmod_rpm=$(find "${work_dir}/RPMS" -type f \
    -name 'kmod-wl-*.rpm' -print -quit)
test -n "${kmod_rpm}"

echo "Installing Broadcom wl"
dnf install -y "${kmod_rpm}"
depmod -a "${kernel_release}"

echo "Verifying Broadcom wl for ${kernel_release}"
modinfo -k "${kernel_release}" wl
readonly module_path=$(modinfo -k "${kernel_release}" -n wl)
readonly canonical_module_path=$(realpath "${module_path}")
grep -q "^/usr/lib/modules/${kernel_release}/" <<<"${canonical_module_path}"
rpm -qf "${module_path}"

# The image intentionally retains its development tool groups. Remove the
# Broadcom-specific source tree, build cache, akmods boot service, and exact
# kernel development tree; the compiled, RPM-owned module and runtime config
# from broadcom-wl remain.
dnf remove -y \
    "akmod-wl-${wl_version}-${akmod_release}" \
    akmods \
    "kernel-devel-${kernel_release}" \
    "kernel-devel-matched-${kernel_release}"
dnf autoremove -y
rm -rf /usr/src/akmods/wl-kmod* /var/cache/akmods/wl /var/log/akmods /run/akmods
if getent passwd akmods >/dev/null; then
    userdel akmods
fi
if getent group akmods >/dev/null; then
    groupdel akmods
fi

if [[ -e "/usr/lib/modules/${kernel_release}/build/Makefile" ]]; then
    echo "Broadcom build-only kernel tree remains installed." >&2
    exit 1
fi
if systemctl is-enabled akmods.service >/dev/null 2>&1; then
    echo "Broadcom build-only akmods service remains enabled." >&2
    exit 1
fi

# Verify again after build-dependency removal; do not load the module here.
modinfo -k "${kernel_release}" wl
test "$(realpath "$(modinfo -k "${kernel_release}" -n wl)")" = \
    "${canonical_module_path}"
rpm -qf "${module_path}"

trap - EXIT
cleanup_wl_build
