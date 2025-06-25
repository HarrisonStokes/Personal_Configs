#!/bin/bash
#
# System Detection Library
#

[[ "${_SYSTEM_LOADED:-}" == "true" ]] && return 0
readonly _SYSTEM_LOADED=true

declare -g OS="" ARCH="" SHELL_NAME="" PACKAGE_MANAGER=""
declare -g DISTRO="" DISTRO_VERSION="" CONTAINER="" VIRTUALIZATION=""
declare -g SYSTEM_DETECTED=false

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

_system_log() {
    local level="$1"
    shift
    if [[ "${SYSTEM_DEBUG:-false}" == "true" ]]; then
        echo "[SYSTEM:$level] $*" >&2
    fi
}

detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64) ARCH="x86_64" ;;
        arm64|aarch64|armv8*) ARCH="arm64" ;;
        armv7*) ARCH="armv7" ;;
        armv6*) ARCH="armv6" ;;
        arm*) ARCH="arm" ;;
        i386|i686|i?86) ARCH="i386" ;;
        *) ARCH="$(uname -m)" ;;
    esac
    export ARCH
    _system_log debug "Architecture: $ARCH"
}

detect_os() {
    case "$(uname -s)" in
        Linux*)
            # Check for WSL
            if [[ -n "${WSL_DISTRO_NAME:-}" ]] || [[ -n "${WSLENV:-}" ]] || \
               [[ -f /proc/version && $(grep -i microsoft /proc/version 2>/dev/null) ]]; then
                OS="WSL"
            else
                OS="Linux"
            fi
            detect_linux_distro
            ;;
        Darwin*) 
            OS="macOS"
            DISTRO="macos"
            DISTRO_VERSION="$(sw_vers -productVersion 2>/dev/null || uname -r)"
            ;;
        FreeBSD*) 
            OS="FreeBSD"
            DISTRO="freebsd"
            DISTRO_VERSION="$(uname -r)"
            ;;
        *) 
            OS="$(uname -s)"
            DISTRO="unknown"
            DISTRO_VERSION="$(uname -r)"
            ;;
    esac
    export OS DISTRO DISTRO_VERSION
    _system_log debug "OS: $OS, Distro: $DISTRO $DISTRO_VERSION"
}

detect_linux_distro() {
    # Try /etc/os-release first
    if [[ -f /etc/os-release ]]; then
        _system_log debug "Using /etc/os-release"
        local id
        id="$(grep '^ID=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' | head -1)"
        local version_id
        version_id="$(grep '^VERSION_ID=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"' | head -1)"
        DISTRO="${id:-unknown}"
        DISTRO_VERSION="${version_id:-unknown}"
        
    elif [[ -f /etc/lsb-release ]]; then
        _system_log debug "Using /etc/lsb-release"
        local distrib_id
        distrib_id="$(grep '^DISTRIB_ID=' /etc/lsb-release 2>/dev/null | cut -d= -f2 | tr -d '"')"
        local distrib_release
        distrib_release="$(grep '^DISTRIB_RELEASE=' /etc/lsb-release 2>/dev/null | cut -d= -f2 | tr -d '"')"
        DISTRO="${distrib_id,,}"
        DISTRO_VERSION="$distrib_release"
        
    elif [[ -f /etc/debian_version ]]; then
        DISTRO="debian"
        DISTRO_VERSION="$(cat /etc/debian_version 2>/dev/null)"
        
    elif [[ -f /etc/redhat-release ]]; then
        DISTRO="redhat"
        DISTRO_VERSION="$(cat /etc/redhat-release 2>/dev/null)"
        
    else
        DISTRO="linux"
        DISTRO_VERSION="unknown"
    fi
    
    _system_log debug "Linux distro: $DISTRO $DISTRO_VERSION"
}

detect_shell() {
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        SHELL_NAME="zsh"
    elif [[ -n "${BASH_VERSION:-}" ]]; then
        SHELL_NAME="bash"
    elif [[ -n "${FISH_VERSION:-}" ]]; then
        SHELL_NAME="fish"
    else
        SHELL_NAME="$(basename "${SHELL:-sh}" 2>/dev/null)"
    fi
    export SHELL_NAME
    _system_log debug "Shell: $SHELL_NAME"
}

detect_pkg_manager() {
    local managers=("apt-get:apt" "brew:brew" "dnf:dnf" "yum:yum" "pacman:pacman" "zypper:zypper" "apk:apk" "pkg:pkg")
    
    PACKAGE_MANAGER="none"
    for entry in "${managers[@]}"; do
        local cmd="${entry%:*}"
        local name="${entry#*:}"
        
        if command_exists "$cmd"; then
            PACKAGE_MANAGER="$name"
            break
        fi
    done
    
    export PACKAGE_MANAGER
    _system_log debug "Package manager: $PACKAGE_MANAGER"
}

detect_container() {
    CONTAINER="none"
    if [[ -f /.dockerenv ]]; then
        CONTAINER="docker"
    elif [[ -f /run/.containerenv ]]; then
        CONTAINER="podman"
    elif [[ -f /proc/1/cgroup ]] && grep -q "docker\|lxc\|kubepods" /proc/1/cgroup 2>/dev/null; then
        CONTAINER="container"
    fi
    export CONTAINER
    _system_log debug "Container: $CONTAINER"
}

detect_virtualization() {
    VIRTUALIZATION="none"
    if command_exists systemd-detect-virt; then
        local virt
        virt="$(systemd-detect-virt 2>/dev/null)"
        [[ "$virt" != "none" && -n "$virt" ]] && VIRTUALIZATION="$virt"
    elif [[ -f /proc/cpuinfo ]] && grep -q "hypervisor" /proc/cpuinfo 2>/dev/null; then
        VIRTUALIZATION="vm"
    fi
    export VIRTUALIZATION
    _system_log debug "Virtualization: $VIRTUALIZATION"
}

detect_system() {
    [[ "$SYSTEM_DETECTED" == "true" ]] && return 0
    
    _system_log debug "Starting system detection"
    
    detect_arch
    detect_os  
    detect_shell
    detect_pkg_manager
    detect_container
    detect_virtualization
    
    SYSTEM_DETECTED=true
    export SYSTEM_DETECTED
    
    _system_log debug "Detection complete: $OS/$ARCH, $SHELL_NAME, $PACKAGE_MANAGER"
}

show_system_info() {
    [[ "$SYSTEM_DETECTED" != "true" ]] && detect_system
    
    echo "System Information:"
    printf "%-18s %s\n" "Operating System:" "$OS"
    [[ "$DISTRO" != "unknown" ]] && printf "%-18s %s %s\n" "Distribution:" "$DISTRO" "$DISTRO_VERSION"
    printf "%-18s %s\n" "Architecture:" "$ARCH"
    printf "%-18s %s\n" "Shell:" "$SHELL_NAME"
    printf "%-18s %s\n" "Package Manager:" "$PACKAGE_MANAGER"
    [[ "$CONTAINER" != "none" ]] && printf "%-18s %s\n" "Container:" "$CONTAINER"
    [[ "$VIRTUALIZATION" != "none" ]] && printf "%-18s %s\n" "Virtualization:" "$VIRTUALIZATION"
}

# Compatibility functions
is_linux() { [[ "$OS" == "Linux" || "$OS" == "WSL" ]]; }
is_macos() { [[ "$OS" == "macOS" ]]; }
is_container() { [[ "$CONTAINER" != "none" ]]; }

# Auto-detect unless disabled
if [[ "${SYSTEM_NO_AUTO_DETECT:-false}" != "true" ]]; then
    detect_system
fi
