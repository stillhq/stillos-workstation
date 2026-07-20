#!/usr/bin/env bash

set -xeuo pipefail

[[ "${VARIANT}" == "nvidia" ]] || exit 0

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

# The toolkit repository shipped by the base image currently points at an
# obsolete key location. Store the current key in the immutable image.
container_key=/etc/pki/rpm-gpg/RPM-GPG-KEY-NVIDIA-CONTAINER-TOOLKIT
curl --fail --location --silent --show-error \
    https://nvidia.github.io/libnvidia-container/gpgkey \
    --output "${container_key}"
chmod 0644 "${container_key}"
if [[ -f /etc/yum.repos.d/nvidia-container-toolkit.repo ]]; then
    sed -i "s|^gpgkey=.*|gpgkey=file://${container_key}|" \
        /etc/yum.repos.d/nvidia-container-toolkit.repo
fi

dnf --disablerepo=nvidia-container-toolkit \
    --enablerepo=almalinux-nvidia makecache

# Explicit cuda-libs selection supplies libcuda.so.1 and avoids
# cuda-driver-devel's /usr/local layout, which is incompatible with bootc.
dnf install -y \
    kmod-nvidia-open \
    nvidia-driver \
    nvidia-driver-cuda-libs

trap - EXIT
cleanup_nvidia_build
