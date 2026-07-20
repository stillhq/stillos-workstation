#!/usr/bin/env bash

set -xeuo pipefail

[[ "${VARIANT}" == "nvidia" ]] || exit 0

readonly script_dir=$(realpath "$(dirname "$0")")

# Keep this in sync with nvidia.sh.  The AlmaLinux release RPM cannot remain
# installed in the final image, so unpack its repository definition and key.
work_dir=$(mktemp -d /tmp/stillos-nvidia-build.XXXXXX)
cleanup_nvidia_build() {
    rm -rf -- "${work_dir}"
}
trap cleanup_nvidia_build EXIT

dnf --disablerepo=nvidia-container-toolkit download \
    --destdir "${work_dir}" almalinux-release-nvidia-driver

release_rpm=$(find "${work_dir}" -maxdepth 1 -type f \
    -name 'almalinux-release-nvidia-driver-*.rpm' -print -quit)
if [[ -z "${release_rpm}" ]]; then
    echo "Could not download almalinux-release-nvidia-driver." >&2
    exit 1
fi

mkdir "${work_dir}/release"
rpm2cpio "${release_rpm}" | cpio -idmD "${work_dir}/release"

repo_source=${work_dir}/release/etc/yum.repos.d/almalinux-nvidia.repo
key_source=${work_dir}/release/etc/pki/rpm-gpg/RPM-GPG-KEY-NVIDIA-CUDA-10
if [[ ! -f "${repo_source}" || ! -f "${key_source}" ]]; then
    echo "The release RPM did not contain the expected NVIDIA repository files." >&2
    exit 1
fi

install -D -m 0644 "${repo_source}" /etc/yum.repos.d/almalinux-nvidia.repo
install -D -m 0644 "${key_source}" \
    /etc/pki/rpm-gpg/RPM-GPG-KEY-NVIDIA-CUDA-10

dnf --enablerepo=almalinux-nvidia makecache

# The host supplies the driver, CUDA driver libraries, and container injection
# tooling. CUDA application runtimes and compilers stay inside CUDA containers;
# installing cuda-toolkit on the host would place it under /usr/local, which
# this bootc image intentionally relocates into mutable /var.
dnf install -y \
    kmod-nvidia-open \
    nvidia-driver \
    nvidia-driver-cuda-libs \
    nvidia-container-toolkit \
    nvidia-settings \
    libva-nvidia-driver

# Match the useful NVIDIA host integration supplied by Bazzite while using
# AlmaLinux's RHEL kernel packages: PRIME render offload, hybrid-GPU discovery,
# fine-grained runtime power management, and boot-time CDI generation.
install -D -m 0755 "${script_dir}/nvidia/prime-run" /usr/bin/prime-run
install -D -m 0644 "${script_dir}/nvidia/stillos-nvidia.conf" \
    /usr/lib/modprobe.d/stillos-nvidia.conf
install -D -m 0644 "${script_dir}/nvidia/stillos-nvidia-cdi.service" \
    /usr/lib/systemd/system/stillos-nvidia-cdi.service
install -D -m 0644 "${script_dir}/nvidia/99-nvidia.conf" \
    /etc/environment.d/99-nvidia.conf

systemctl enable switcheroo-control.service stillos-nvidia-cdi.service

command -v nvidia-ctk
command -v nvidia-container-cli
command -v nvidia-settings
command -v switcherooctl
command -v prime-run
ldconfig -p | grep -q 'libcuda\.so\.1'
rpm -q libva-nvidia-driver
test -e /usr/share/glvnd/egl_vendor.d/10_nvidia.json
test -e /usr/share/vulkan/implicit_layer.d/nvidia_layers.json
test -e /usr/share/vulkan/icd.d/nvidia_icd.x86_64.json

trap - EXIT
cleanup_nvidia_build
