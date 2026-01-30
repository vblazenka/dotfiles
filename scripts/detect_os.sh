#!/bin/bash

# OS Detection Script
# Returns: macos, linux, wsl, or unknown

detect_os() {
    OS_TYPE=""

    case "$(uname -s)" in
        Darwin)
            OS_TYPE="macos"
            ;;
        Linux)
            # Check for WSL
            if grep -qi microsoft /proc/version 2>/dev/null; then
                OS_TYPE="wsl"
            elif [[ -f /etc/os-release ]]; then
                source /etc/os-release
                # Normalize to just "linux" - distro-specific handled in setup
                OS_TYPE="linux"
                LINUX_DISTRO="$ID"  # Available for setup scripts if needed
            else
                OS_TYPE="linux"
            fi
            ;;
        *)
            OS_TYPE="unknown"
            ;;
    esac

    export OS_TYPE
    export LINUX_DISTRO
}
