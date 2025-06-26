#!/bin/bash
#
# System Detection Library
#
# Usage: source ./system.sh
#
# Functions:
#   detect_arch()               @desc Detects what architecture is being used.
#   detect_os()                 @desc Detects what operating system is being used.
#   detect_linux_distro()       @desc Detects what linux distribution is being used.
#   detect_shell()              @desc Detects what shell is being.
#   detect_pkg_manager()        @desc Detects what package manager is supported.
#   detect_container()          @desc Detects container currently active.
#   detect_virtualization()     @desc Detects if in a virtual environment.
#   detect_system()             @desc Runs all detection functions.
#   show_system_info()          @desc Prints system information.
#   is_linux()                  @desc Determines if operating system is linux.
#   is_macos()                  @desc Determines if operating system is macOS.
#   is_container()              @desc Detemines if in a container.
#

[[ "${_SYSTEM_LOADED:-}" == "true" ]] && return 0
readonly _SYSTEM_LOADED=true

_load_scripts() {
    source ./logger.sh
    log_set_prefix "System"
}
_load_scripts

OS="" ARCH="" SHELL_NAME="" PACKAGE_MANAGER=""
DISTRO="" DISTRO_VERSION="" CONTAINER="" VIRTUALIZATION=""
SYSTEM_DETECTED=false

is_linux() { [[ "$OS" == "Linux" || "$OS" == "WSL" ]]; }
is_macos() { [[ "$OS" == "macOS" ]]; }
is_container() { [[ "$CONTAINER" != "none" ]]; }

# Auto-detect unless disabled
if [[ "${SYSTEM_NO_AUTO_DETECT:-false}" != "true" ]]; then
    detect_system
fi

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
    log_debug "Architecture: $ARCH"
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
    log_debug "OS: $OS, Distro: $DISTRO $DISTRO_VERSION"
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
    
    log_debug "Linux distro: $DISTRO $DISTRO_VERSION"
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
    log_debug "Shell: $SHELL_NAME"
}

detect_pkg_manager() {
    if [[ -n "${PACKAGE_MANAGER:-}" ]] && [[ "$PACKAGE_MANAGER" != "none" ]]; then
        log_debug "Using package manager: $PACKAGE_MANAGER"
        return 0
    fi
    
    local detected_os="${OS:-$(uname -s)}"
    local detected_arch="${ARCH:-$(uname -m)}"
    
    log_debug "Detecting package manager for $detected_os on $detected_arch"
    
    case "$detected_os" in
        "Linux"|"WSL")
            if pkg_command_exists apt-get; then
                PACKAGE_MANAGER="apt"
            elif pkg_command_exists dnf; then
                PACKAGE_MANAGER="dnf"
            elif pkg_command_exists yum; then
                PACKAGE_MANAGER="yum"
            elif pkg_command_exists pacman; then
                PACKAGE_MANAGER="pacman"
            elif pkg_command_exists zypper; then
                PACKAGE_MANAGER="zypper"
            elif pkg_command_exists apk; then
                PACKAGE_MANAGER="apk"
            elif pkg_command_exists xbps-install; then
                PACKAGE_MANAGER="xbps"
            elif pkg_command_exists emerge; then
                PACKAGE_MANAGER="portage"
            elif pkg_command_exists slackpkg; then
                PACKAGE_MANAGER="slackpkg"
            elif pkg_command_exists swupd; then
                PACKAGE_MANAGER="swupd"
            elif pkg_command_exists eopkg; then
                PACKAGE_MANAGER="eopkg"
            elif pkg_command_exists urpmi; then
                PACKAGE_MANAGER="urpmi"
            elif pkg_command_exists nix-env; then
                PACKAGE_MANAGER="nix"
            elif pkg_command_exists guix; then
                PACKAGE_MANAGER="guix"
            fi
            ;;
        "Darwin"|"macOS")
            if pkg_command_exists brew; then
                PACKAGE_MANAGER="brew"
            elif pkg_command_exists port; then
                PACKAGE_MANAGER="macports"
            elif pkg_command_exists nix-env; then
                PACKAGE_MANAGER="nix"
            fi
            ;;
        "FreeBSD")
            if pkg_command_exists pkg; then
                PACKAGE_MANAGER="pkg"
            fi
            ;;
        "NetBSD")
            if pkg_command_exists pkgin; then
                PACKAGE_MANAGER="pkgin"
            elif pkg_command_exists pkg_add; then
                PACKAGE_MANAGER="pkg_add"
            fi
            ;;
        "OpenBSD")
            if pkg_command_exists pkg_add; then
                PACKAGE_MANAGER="pkg_add"
            fi
            ;;
        "DragonFly"|"DragonFlyBSD")
            if pkg_command_exists pkg; then
                PACKAGE_MANAGER="dports"
            fi
            ;;
        "SunOS"|"Solaris")
            if pkg_command_exists pkgutil; then
                PACKAGE_MANAGER="pkgutil"
            elif pkg_command_exists pkg; then
                PACKAGE_MANAGER="solaris_pkg"
            fi
            ;;
        "AIX")
            if pkg_command_exists installp; then
                PACKAGE_MANAGER="installp"
            elif pkg_command_exists rpm; then
                PACKAGE_MANAGER="rpm_aix"
            fi
            ;;
        *"Windows"*|"CYGWIN"*|"MINGW"*|"MSYS"*)
            if pkg_command_exists choco; then
                PACKAGE_MANAGER="choco"
            elif pkg_command_exists scoop; then
                PACKAGE_MANAGER="scoop"
            elif pkg_command_exists winget; then
                PACKAGE_MANAGER="winget"
            fi
            ;;
    esac
    
    # Universal package managers (try last to prefer system packages)
    if [[ -z "$PACKAGE_MANAGER" ]] || [[ "$PKG_PREFER_SYSTEM_PACKAGES" != "true" ]]; then
        if pkg_command_exists snap; then
            PACKAGE_MANAGER="snap"
        elif pkg_command_exists flatpak; then
            PACKAGE_MANAGER="flatpak"
        elif pkg_command_exists nix-env; then
            PACKAGE_MANAGER="nix"
        elif pkg_command_exists guix; then
            PACKAGE_MANAGER="guix"
        fi
    fi
    
    if [[ -z "$PACKAGE_MANAGER" ]]; then
        PACKAGE_MANAGER="none"
        log_error "No supported package manager found on $detected_os"
        return 1
    fi
    
    export PACKAGE_MANAGER
    log_info "Detected package manager: $PACKAGE_MANAGER"
    return 0
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
    log_debug "Container: $CONTAINER"
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
    log_debug "Virtualization: $VIRTUALIZATION"
}

detect_system() {
    [[ "$SYSTEM_DETECTED" == "true" ]] && return 0
    
    log_debug "Starting system detection"
    
    detect_arch
    detect_os  
    detect_shell
    detect_pkg_manager
    detect_container
    detect_virtualization
    
    SYSTEM_DETECTED=true
    export SYSTEM_DETECTED
    
    log_debug "Detection complete: $OS/$ARCH, $SHELL_NAME, $PACKAGE_MANAGER"
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
