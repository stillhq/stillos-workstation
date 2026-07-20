#!/usr/bin/env bash

set -xeuo pipefail

case "${VARIANT}" in
    "")
        echo "Building base variant (no additional packages)"
        ;;
    nvidia)
        echo "Building NVIDIA variant"
        ;;
    *)
        echo "Unknown variant: ${VARIANT}"
        exit 1
        ;;
esac
