#!/bin/bash

# OS Detection Script
# Detects the operating system and sets global variables

detect_os() {
    OS_TYPE=""
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f /etc/os-release ]]; then
            source /etc/os-release
            case "$ID" in
                "linuxmint")
                    OS_TYPE="linux_mint"
                    ;;
                "ubuntu")
                    OS_TYPE="ubuntu"
                    ;;
                "arch")
                    OS_TYPE="arch"
                    ;;
                "fedora")
                    OS_TYPE="fedora"
                    ;;
                *)
                    OS_TYPE="linux_unknown"
                    ;;
            esac
        else
            OS_TYPE="linux_unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS_TYPE="macos"
    else
        OS_TYPE="unknown"
    fi
}
