#!/bin/bash

# Contains all system related functions

OS=""
ARCH=""
SHELL_NAME=""
PACKAGE_MANAGER=""

detect_system() {
    detect_arch
    detect_os
    detect_shell
    detect_pkg_manager
}

detect_arch() {
    local ARCH=""
    case "$(uname -m)" in
        x86_64|amd64) ARCH="x86_64" ;;
        arm64|aarch64) ARCH="arm64" ;;
        armv7l) ARCH="armv7" ;;
        i386|i686) ARCH="i386" ;;
        *) ARCH="unknown" ;;
    esac
}

detect_os() {
    case "$(uname -s)" in
        Linux*)
            if [[ -n "$WSL_DISTRO_NAME" ]] || [[ -n "$WSLENV" ]] || [[ -f /proc/version && $(grep -i microsoft /proc/version) ]]; then
                OS="WSL"
            else
                OS="Linux"
            fi
            ;;
        Darwin*) OS="macOS" ;;
        CYGWIN*|MINGW*|MSYS*) OS="Windows" ;;
        FreeBSD*) OS="FreeBSD" ;;
        *) OS="Unknown" ;;
    esac
}

detect_shell() {
    if [[ -n "$ZSH_VERSION" ]]; then
        SHELL_NAME="zsh"
    elif [[ -n "$BASH_VERSION" ]]; then
        SHELL_NAME="bash"
    elif [[ -n "$FISH_VERSION" ]]; then
        SHELL_NAME="fish"
    else
        SHELL_NAME=$(basename "$SHELL" 2>/dev/null || echo "bash")
    fi
}

detect_pkg_manager() {
    local managers=("apt" "brew" "dnf" "yum" "pacman" "zypper" "apk" "pkg" "choco" "scoop" "winget")
    for mgr in "${managers[@]}"; do
        if command_exists "$mgr"; then
            [[ "$mgr" == "pkg" && "$OS" != "FreeBSD" ]] && continue
            PACKAGE_MANAGER="$mgr"
            break
        fi
    done
    [[ -z "$PACKAGE_MANAGER" ]] && PACKAGE_MANAGER="none"
}
