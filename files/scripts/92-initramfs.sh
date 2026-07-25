set -xeuo pipefail

mapfile -t kernel_releases < <(
    rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-core
)
if [[ ${#kernel_releases[@]} -ne 1 ]]; then
    echo "Expected exactly one installed kernel-core, found: ${kernel_releases[*]:-(none)}" >&2
    exit 1
fi
readonly kernel_release=${kernel_releases[0]}

dracut -vf \
    "/usr/lib/modules/${kernel_release}/initramfs.img" \
    "${kernel_release}"
