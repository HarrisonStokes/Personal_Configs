#!/bin/bash
#
# Package Manager Library v2.0.0
# Cross-platform package management utilities with enhanced compatibility
#
# Usage: source ./package_manager.sh
#
# Functions:
#   pkg_command_exists()            @param [cmd_name]               @desc Checks if command exists
#   pkg_package_exists()            @param [pkg_name]               @desc Checks if package exists
#   pkg_get_package_alternatives()  @param [pkg_name]               @desc Gets alternative package names
#   pkg_cleanup()                   @param []                       @desc Removes unnecessary packages after script is finished
#   pkg_register_cleanup()          @param []                       @desc Enables automatic clean up
#   pkg_create_temp_dir()           @param [dir_name]               @desc Creates temporary directory for files new files created by script
#   pkg_update_cache()              @param []                       @desc Updates cache
#   pkg_install_raw()               @param [pkg_name, retry_count]  @desc Installs package without check if it already exists
#   pkg_install_package()           @param [pkg_name, force]        @desc Installs package checking if it already exists
#   pkg_install_for_command()       @param [pkg_name, force]        @desc Installs command checking if it already exists and using alternatives
#   pkg_install_dependencies()      @param [req_pkgs, opt_pkgs]     @desc Installs dependency packages including required and optional
#   pkg_install_manual()            @param [url]                    @desc Installs package using url install link
#   pkg_remove_package()            @param [pkg_name]               @desc Uninstall package
#   pkg_set_config()                @param [option, value]          @desc Set package manager configuration options with a value
#   pkg_get_config()                @param [option]                 @desc Gets option value
#   pkg_search_package()            @param [pkg_name]               @desc Looks for package in cache
#   pkg_list_installed()            @param []                       @desc Lists all packages installed
#   pkg_show_info()                 @param [pkg_name]               @desc Lists package info 
#   pkg_init()                      @param []                       @desc Initializes package manager
#   pkg_show_status()               @param []                       @desc Prints package manager library configuration info
#   pkg_show_supported_managers()   @param []                       @desc Prints all supported package manager by library

# ============================================================================
# LIBRARY INITIALIZATION
# ============================================================================

# Prevent multiple loading
[[ "${_PKG_MANAGER_LOADED:-}" == "true" ]] && return 0
readonly _PKG_MANAGER_LOADED=true

declare -g PKG_LIB_VERSION="1.0.0"
declare -g PKG_LIB_NAME="package_manager"

_load_scripts() {
    source "./logger.sh"
    LOG_PREFIX="$PKG_LIB_NAME"
    source "./system.sh"
}
_load_scripts

# ============================================================================
# CONFIGURATION & GLOBALS
# ============================================================================

# Runtime tracking
declare -ga TEMP_DIRS=()
declare -ga INSTALLED_PACKAGES=()
declare -g PKG_LIB_INITIALIZED=false
declare -g PKG_LIB_CLEANUP_REGISTERED=false

# Configuration options (can be overridden)
declare -g PKG_VERBOSE=${PKG_VERBOSE:-false}
declare -g PKG_DRY_RUN=${PKG_DRY_RUN:-false}
declare -g PKG_AUTO_CLEANUP=${PKG_AUTO_CLEANUP:-true}
declare -g PKG_UPDATE_CACHE=${PKG_UPDATE_CACHE:-true}
declare -g PKG_RETRY_COUNT=${PKG_RETRY_COUNT:-2}
declare -g PKG_TIMEOUT=${PKG_TIMEOUT:-300}
declare -g PKG_PREFER_SYSTEM_PACKAGES=${PKG_PREFER_SYSTEM_PACKAGES:-true}

# Package name mappings for different systems
if [[ "${BASH_VERSINFO[0]:-0}" -ge 4 ]]; then
    declare -gA PKG_COMMAND_MAP=(
        ["python3"]="python3-dev python3.12 python3.11 python3.10 python3.9 python3"
        ["python"]="python3-dev python3.12 python3.11 python3.10 python3 python python-dev"
        ["node"]="nodejs node"
        ["npm"]="npm nodejs"
        ["docker"]="docker.io docker-ce docker docker-engine"
        ["git"]="git-core git"
        ["make"]="build-essential make gmake"
        ["gcc"]="build-essential gcc"
        ["g++"]="build-essential g++"
        ["pip3"]="python3-pip"
        ["pip"]="python3-pip python-pip"
        ["vim"]="vim vim-tiny neovim"
        ["vi"]="vim vim-tiny vi"
        ["curl"]="curl"
        ["wget"]="wget"
        ["unzip"]="unzip"
        ["tar"]="tar gtar"
        ["jq"]="jq"
        ["htop"]="htop"
        ["tree"]="tree"
        ["ssh"]="openssh-client openssh"
        ["rsync"]="rsync"
        ["nano"]="nano"
        ["emacs"]="emacs"
        ["tmux"]="tmux"
        ["screen"]="screen"
        ["zsh"]="zsh"
        ["fish"]="fish"
        ["bash"]="bash"
        ["ruby"]="ruby ruby-dev"
        ["perl"]="perl"
        ["java"]="openjdk-11-jdk openjdk-8-jdk default-jdk java"
        ["go"]="golang go"
        ["rust"]="rustc cargo"
        ["cmake"]="cmake"
        ["autotools"]="autotools-dev autoconf automake"
        ["pkg-config"]="pkg-config pkgconf"
    )
    _PKG_USE_COMMAND_MAP=true
else
    _PKG_USE_COMMAND_MAP=false
fi

# Auto-initialize when sourced (can be disabled by setting PKG_NO_AUTO_INIT=true)
if [[ "${PKG_NO_AUTO_INIT:-false}" != "true" ]]; then
    pkg_init
fi

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

pkg_command_exists() {
    command -v "$1" >/dev/null 2>&1
}

pkg_package_exists() {
    local package="$1"
    [[ -z "$package" ]] && return 1
    
    case "$PACKAGE_MANAGER" in
        apt) 
            dpkg -l "$package" >/dev/null 2>&1 || 
            dpkg-query -W "$package" >/dev/null 2>&1
            ;;
        dnf|yum) 
            rpm -q "$package" >/dev/null 2>&1 ||
            dnf list installed "$package" >/dev/null 2>&1 ||
            yum list installed "$package" >/dev/null 2>&1
            ;;
        pacman) 
            pacman -Q "$package" >/dev/null 2>&1 ||
            pacman -Qi "$package" >/dev/null 2>&1
            ;;
        brew) 
            brew list "$package" >/dev/null 2>&1 ||
            brew list --formula "$package" >/dev/null 2>&1 ||
            brew list --cask "$package" >/dev/null 2>&1
            ;;
        pkg) 
            pkg info "$package" >/dev/null 2>&1 ||
            pkg query "%n" "$package" >/dev/null 2>&1
            ;;
        pkgin) 
            pkgin list | grep -q "^$package" ||
            pkgin show-deps "$package" >/dev/null 2>&1
            ;;
        pkg_add) 
            pkg_info -e "$package" >/dev/null 2>&1 ||
            pkg_info "$package" >/dev/null 2>&1
            ;;
        portage) 
            qlist -I "$package" >/dev/null 2>&1 ||
            equery list "$package" >/dev/null 2>&1
            ;;
        nix) 
            nix-env -q "$package" >/dev/null 2>&1 ||
            nix-env -qa "$package" >/dev/null 2>&1
            ;;
        guix)
            guix package -I | grep -q "$package"
            ;;
        snap) 
            snap list "$package" >/dev/null 2>&1
            ;;
        flatpak) 
            flatpak list | grep -q "$package" ||
            flatpak info "$package" >/dev/null 2>&1
            ;;
        xbps)
            xbps-query -l | grep -q "$package" ||
            xbps-query "$package" >/dev/null 2>&1
            ;;
        slackpkg)
            ls /var/log/packages/ | grep -q "^$package-" ||
            slackpkg search "$package" | grep -q "installed"
            ;;
        swupd)
            swupd bundle-list | grep -q "$package"
            ;;
        eopkg)
            eopkg list-installed | grep -q "$package"
            ;;
        urpmi)
            rpm -q "$package" >/dev/null 2>&1
            ;;
        emerge-webrsync)
            qlist -I "$package" >/dev/null 2>&1
            ;;
        *) return 1 ;;
    esac
}

pkg_get_package_alternatives() {
    local command="$1"
    
    if [[ "$_PKG_USE_COMMAND_MAP" == "true" ]] && [[ -n "${PKG_COMMAND_MAP[$command]:-}" ]]; then
        echo "${PKG_COMMAND_MAP[$command]}"
    else
        case "$command" in
            python3) echo "python3-dev python3.12 python3.11 python3.10 python3.9 python3" ;;
            python) echo "python3-dev python3.12 python3.11 python3.10 python3 python python-dev" ;;
            node) echo "nodejs node" ;;
            npm) echo "npm nodejs" ;;
            docker) echo "docker.io docker-ce docker docker-engine" ;;
            git) echo "git-core git" ;;
            make) echo "build-essential make gmake" ;;
            gcc) echo "build-essential gcc" ;;
            g++) echo "build-essential g++" ;;
            pip3) echo "python3-pip" ;;
            pip) echo "python3-pip python-pip" ;;
            vim) echo "vim vim-tiny neovim" ;;
            vi) echo "vim vim-tiny vi" ;;
            curl) echo "curl" ;;
            wget) echo "wget" ;;
            ssh) echo "openssh-client openssh" ;;
            java) echo "openjdk-11-jdk openjdk-8-jdk default-jdk java" ;;
            go) echo "golang go" ;;
            rust) echo "rustc cargo" ;;
            *) echo "$command" ;;
        esac
    fi
}


# ============================================================================
# CLEANUP MANAGEMENT
# ============================================================================

pkg_cleanup() {
    local exit_code="$?"
    
    log_info "Running cleanup..."
    
    # Clean temporary directories
    for temp_dir in "${TEMP_DIRS[@]}"; do
        if [[ -d "$temp_dir" ]]; then
            log_info "Removing temp directory: $temp_dir"
            rm -rf "$temp_dir" || log_warn "Failed to remove $temp_dir"
        fi
    done
    
    # Remove packages that were installed by this script
    if [[ "$PKG_AUTO_CLEANUP" == "true" ]] && [[ ${#INSTALLED_PACKAGES[@]} -gt 0 ]]; then
        log_info "Cleaning up installed packages..."
        for package in "${INSTALLED_PACKAGES[@]}"; do
            pkg_remove_package "$package" || log_warn "Failed to remove $package"
        done
    fi
    
    exit $exit_code
}

pkg_register_cleanup() {
    if [[ "$PKG_LIB_CLEANUP_REGISTERED" == "true" ]]; then
        return 0
    fi
    
    trap pkg_cleanup EXIT INT TERM
    PKG_LIB_CLEANUP_REGISTERED=true
    log_debug "Cleanup handler registered"
}

pkg_create_temp_dir() {
    local name="${1:-pkg_temp}"
    local temp_dir
    
    temp_dir=$(mktemp -d -t "${name}.XXXXXX") || {
        log_error "Failed to create temporary directory"
        return 1
    }
    
    TEMP_DIRS+=("$temp_dir")
    log_debug "Created temp directory: $temp_dir"
    echo "$temp_dir"
}

# ============================================================================
# CORE PACKAGE OPERATIONS
# ============================================================================

pkg_update_cache() {
    [[ "$PKG_UPDATE_CACHE" != "true" ]] && return 0
    
    log_info "Updating package cache..."
    
    if [[ "$PKG_DRY_RUN" == "true" ]]; then
        log_info "DRY RUN: Would update package cache"
        return 0
    fi
    
    case "$PACKAGE_MANAGER" in
        apt) 
            sudo apt-get update -qq 
            ;;
        dnf) 
            sudo dnf check-update >/dev/null 2>&1 || true 
            ;;
        yum) 
            sudo yum check-update >/dev/null 2>&1 || true 
            ;;
        pacman) 
            sudo pacman -Sy --noconfirm 
            ;;
        zypper) 
            sudo zypper refresh 
            ;;
        apk) 
            sudo apk update 
            ;;
        xbps)
            sudo xbps-install -S
            ;;
        brew) 
            brew update >/dev/null 2>&1 
            ;;
        portage) 
            sudo emerge --sync >/dev/null 2>&1 
            ;;
        slackpkg)
            sudo slackpkg update
            ;;
        swupd)
            sudo swupd update --download
            ;;
        eopkg)
            sudo eopkg update-repo
            ;;
        urpmi)
            sudo urpmi.update -a
            ;;
        *) 
            log_debug "Cache update not needed for $PACKAGE_MANAGER" 
            ;;
    esac
}

pkg_install_raw() {
    local package="$1"
    local retry_count="${PKG_RETRY_COUNT:-2}"
    
    [[ -z "$package" ]] && return 1
    
    if [[ "$PKG_DRY_RUN" == "true" ]]; then
        log_info "DRY RUN: Would install package: $package"
        return 0
    fi
    
    log_info "Installing package: $package"
    
    # Try installation with retries
    local attempt=1
    while [[ $attempt -le $((retry_count + 1)) ]]; do
        if [[ $attempt -gt 1 ]]; then
            log_warn "Installation attempt $attempt for $package"
            sleep $((attempt - 1))
        fi
        
        local install_cmd=""
        case "$PACKAGE_MANAGER" in
            apt)
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} apt-get install -y '$package'"
                ;;
            brew) 
                install_cmd="timeout ${PKG_TIMEOUT:-300} brew install '$package'"
                ;;
            dnf) 
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} dnf install -y '$package'"
                ;;
            yum) 
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} yum install -y '$package'"
                ;;
            pacman) 
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} pacman -S --noconfirm '$package'"
                ;;
            zypper) 
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} zypper install -y '$package'"
                ;;
            apk) 
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} apk add '$package'"
                ;;
            xbps)
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} xbps-install -y '$package'"
                ;;
            pkg) 
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} pkg install -y '$package'"
                ;;
            dports)
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} pkg install -y '$package'"
                ;;
            pkgin)
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} pkgin -y install '$package'"
                ;;
            pkg_add)
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} pkg_add '$package'"
                ;;
            portage)
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} emerge '$package'"
                ;;
            slackpkg)
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} slackpkg install '$package'"
                ;;
            swupd)
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} swupd bundle-add '$package'"
                ;;
            eopkg)
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} eopkg install '$package'"
                ;;
            urpmi)
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} urpmi '$package'"
                ;;
            nix)
                install_cmd="timeout ${PKG_TIMEOUT:-300} nix-env -i '$package'"
                ;;
            guix)
                install_cmd="timeout ${PKG_TIMEOUT:-300} guix install '$package'"
                ;;
            snap)
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} snap install '$package'"
                ;;
            flatpak)
                install_cmd="timeout ${PKG_TIMEOUT:-300} flatpak install -y '$package'"
                ;;
            choco) 
                install_cmd="timeout ${PKG_TIMEOUT:-300} choco install -y '$package'"
                ;;
            scoop) 
                install_cmd="timeout ${PKG_TIMEOUT:-300} scoop install '$package'"
                ;;
            winget) 
                install_cmd="timeout ${PKG_TIMEOUT:-300} winget install '$package'"
                ;;
            macports)
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} port install '$package'"
                ;;
            pkgutil)
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} pkgutil -i '$package'"
                ;;
            solaris_pkg)
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} pkg install '$package'"
                ;;
            installp)
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} installp -a '$package'"
                ;;
            rpm_aix)
                install_cmd="sudo timeout ${PKG_TIMEOUT:-300} rpm -i '$package'"
                ;;
            *) 
                log_error "Unsupported package manager: $PACKAGE_MANAGER"
                return 1 
                ;;
        esac
        
        # Execute the installation command
        if eval "$install_cmd"; then
            return 0
        fi
        
        ((attempt++))
    done
    
    log_error "Failed to install $package after $((retry_count + 1)) attempts"
    return 1
}

pkg_install_package() {
    local package="$1"
    local force="${2:-false}"
    
    [[ -z "$package" ]] && {
        log_error "Package name required"
        return 1
    }
    
    # Check if already installed (unless forced)
    if [[ "$force" != "true" ]] && pkg_package_exists "$package"; then
        log_info "Package already installed: $package"
        return 0
    fi
    
    # Update cache if needed
    pkg_update_cache
    
    # Try installation
    if pkg_install_raw "$package"; then
        INSTALLED_PACKAGES+=("$package")
        log_info "Successfully installed: $package"
        return 0
    else
        log_error "Failed to install: $package"
        return 1
    fi
}

pkg_install_for_command() {
    local command="$1"
    local force="${2:-false}"
    
    [[ -z "$command" ]] && {
        log_error "Command name required"
        return 1
    }
    
    if [[ "$force" != "true" ]] && pkg_command_exists "$command"; then
        log_info "Command already available: $command"
        return 0
    fi
    
    # Try mapped package names first
    local alternatives="$(pkg_get_package_alternatives "$command")"
    log_info "Trying packages for command '$command': $alternatives"
    
    for package in $alternatives; do
        if pkg_install_package "$package" "$force"; then
            if pkg_command_exists "$command"; then
                log_info "Command now available: $command (via $package)"
                return 0
            fi
        fi
    done
    
    log_error "Failed to make command available: $command"
    return 1
}

pkg_install_dependencies() {
    local -n required_ref=$1
    local -n optional_ref=$2
    
    log_info "Installing required dependencies..."
    
    local failed_deps=()
    
    # Install required dependencies
    for tool in "${required_ref[@]}"; do
        if ! pkg_install_for_command "$tool"; then
            failed_deps+=("$tool")
        fi
    done
    
    # Check for failures
    if [[ ${#failed_deps[@]} -gt 0 ]]; then
        log_error "Failed to install required dependencies: ${failed_deps[*]}"
        return 1
    fi
    
    # Install optional dependencies (don't fail on errors)
    log_info "Installing optional dependencies..."
    for tool in "${optional_ref[@]}"; do
        pkg_install_for_command "$tool" || 
            log_warn "Could not install optional dependency: $tool"
    done
    
    return 0
}

pkg_install_manual() {
    local url="$1"
    [[ -z "$url" ]] && return 1
    
    if [[ "$PKG_DRY_RUN" == "true" ]]; then
        log_info "DRY RUN: Would install from URL: $url"
        return 0
    fi
    
    log_info "Installing from URL: $url"
    
    if pkg_command_exists "curl"; then
        curl -fsSL "$url" | bash
    elif pkg_command_exists "wget"; then
        local temp_file
        temp_file=$(mktemp) || return 1
        if wget -qO "$temp_file" "$url"; then
            bash "$temp_file"
            local result=$?
            rm -f "$temp_file"
            return $result
        else
            rm -f "$temp_file"
            return 1
        fi
    else
        log_error "Neither curl nor wget available for manual installation"
        return 1
    fi
}

# ============================================================================
# PACKAGE REMOVAL
# ============================================================================

pkg_remove_package() {
    local package="$1"
    [[ -z "$package" ]] && return 1
    
    if [[ "$PKG_DRY_RUN" == "true" ]]; then
        log_info "DRY RUN: Would remove package: $package"
        return 0
    fi
    
    log_info "Removing package: $package"
    
    case "$PACKAGE_MANAGER" in
        apt) sudo apt-get remove -y "$package" ;;
        dnf) sudo dnf remove -y "$package" ;;
        yum) sudo yum remove -y "$package" ;;
        pacman) sudo pacman -R --noconfirm "$package" ;;
        zypper) sudo zypper remove -y "$package" ;;
        apk) sudo apk del "$package" ;;
        xbps) sudo xbps-remove -y "$package" ;;
        brew) brew uninstall "$package" ;;
        pkg|dports) sudo pkg delete -y "$package" ;;
        pkgin) sudo pkgin -y remove "$package" ;;
        pkg_add) sudo pkg_delete "$package" ;;
        portage) sudo emerge --unmerge "$package" ;;
        slackpkg) sudo slackpkg remove "$package" ;;
        swupd) sudo swupd bundle-remove "$package" ;;
        eopkg) sudo eopkg remove "$package" ;;
        urpmi) sudo urpme "$package" ;;
        nix) nix-env -e "$package" ;;
        guix) guix remove "$package" ;;
        snap) sudo snap remove "$package" ;;
        flatpak) flatpak uninstall -y "$package" ;;
        macports) sudo port uninstall "$package" ;;
        *) return 0 ;;
    esac
}

# ============================================================================
# CONFIGURATION FUNCTIONS
# ============================================================================

pkg_set_config() {
    local key="$1"
    local value="$2"
    
    case "$key" in
        verbose) PKG_VERBOSE="$value" ;;
        dry_run) PKG_DRY_RUN="$value" ;;
        auto_cleanup) PKG_AUTO_CLEANUP="$value" ;;
        update_cache) PKG_UPDATE_CACHE="$value" ;;
        retry_count) PKG_RETRY_COUNT="$value" ;;
        timeout) PKG_TIMEOUT="$value" ;;
        prefer_system_packages) PKG_PREFER_SYSTEM_PACKAGES="$value" ;;
        *) 
            log_error "Unknown configuration key: $key"
            return 1 
            ;;
    esac
    
    log_debug "Configuration set: $key=$value"
}

pkg_get_config() {
    local key="$1"
    
    case "$key" in
        verbose) echo "$PKG_VERBOSE" ;;
        dry_run) echo "$PKG_DRY_RUN" ;;
        auto_cleanup) echo "$PKG_AUTO_CLEANUP" ;;
        update_cache) echo "$PKG_UPDATE_CACHE" ;;
        retry_count) echo "$PKG_RETRY_COUNT" ;;
        timeout) echo "$PKG_TIMEOUT" ;;
        prefer_system_packages) echo "$PKG_PREFER_SYSTEM_PACKAGES" ;;
        version) echo "$PKG_LIB_VERSION" ;;
        package_manager) echo "$PACKAGE_MANAGER" ;;
        *) return 1 ;;
    esac
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

pkg_search_package() {
    local query="$1"
    [[ -z "$query" ]] && return 1
    
    log_info "Searching for packages matching: $query"
    
    case "$PACKAGE_MANAGER" in
        apt) apt-cache search "$query" ;;
        dnf) dnf search "$query" ;;
        yum) yum search "$query" ;;
        pacman) pacman -Ss "$query" ;;
        zypper) zypper search "$query" ;;
        apk) apk search "$query" ;;
        xbps) xbps-query -Rs "$query" ;;
        brew) brew search "$query" ;;
        pkg|dports) pkg search "$query" ;;
        pkgin) pkgin search "$query" ;;
        portage) emerge --search "$query" ;;
        slackpkg) slackpkg search "$query" ;;
        swupd) swupd search "$query" ;;
        eopkg) eopkg search "$query" ;;
        urpmi) urpmq "$query" ;;
        nix) nix-env -qa "$query" ;;
        guix) guix search "$query" ;;
        snap) snap find "$query" ;;
        flatpak) flatpak search "$query" ;;
        macports) port search "$query" ;;
        *) 
            log_warn "Search not supported for $PACKAGE_MANAGER"
            return 1
            ;;
    esac
}

pkg_list_installed() {
    log_info "Listing installed packages..."
    
    case "$PACKAGE_MANAGER" in
        apt) dpkg -l ;;
        dnf|yum) rpm -qa ;;
        pacman) pacman -Q ;;
        zypper) zypper se --installed-only ;;
        apk) apk info ;;
        xbps) xbps-query -l ;;
        brew) brew list ;;
        pkg|dports) pkg info ;;
        pkgin) pkgin list ;;
        portage) qlist -I ;;
        slackpkg) ls /var/log/packages/ ;;
        swupd) swupd bundle-list ;;
        eopkg) eopkg list-installed ;;
        urpmi) rpm -qa ;;
        nix) nix-env -q ;;
        guix) guix package -I ;;
        snap) snap list ;;
        flatpak) flatpak list ;;
        macports) port installed ;;
        *) 
            log_warn "List not supported for $PACKAGE_MANAGER"
            return 1
            ;;
    esac
}

pkg_show_info() {
    local package="$1"
    [[ -z "$package" ]] && return 1
    
    case "$PACKAGE_MANAGER" in
        apt) apt-cache show "$package" ;;
        dnf) dnf info "$package" ;;
        yum) yum info "$package" ;;
        pacman) pacman -Si "$package" ;;
        zypper) zypper info "$package" ;;
        apk) apk info "$package" ;;
        xbps) xbps-query -R "$package" ;;
        brew) brew info "$package" ;;
        pkg|dports) pkg info "$package" ;;
        pkgin) pkgin show-deps "$package" ;;
        portage) emerge --info "$package" ;;
        slackpkg) slackpkg info "$package" ;;
        swupd) swupd bundle-info "$package" ;;
        eopkg) eopkg info "$package" ;;
        urpmi) urpmq -i "$package" ;;
        nix) nix-env -qa --description "$package" ;;
        guix) guix show "$package" ;;
        snap) snap info "$package" ;;
        flatpak) flatpak info "$package" ;;
        macports) port info "$package" ;;
        *) 
            log_warn "Info not supported for $PACKAGE_MANAGER"
            return 1
            ;;
    esac
}

# ============================================================================
# INITIALIZATION
# ============================================================================

pkg_init() {
    if [[ "$PKG_LIB_INITIALIZED" == "true" ]]; then
        return 0
    fi
    
    log_info "Initializing package manager library v$PKG_LIB_VERSION"
    
    # Detect package manager
    detect_pkg_manager || return 1
    
    # Register cleanup if auto-cleanup is enabled
    if [[ "$PKG_AUTO_CLEANUP" == "true" ]]; then
        pkg_register_cleanup
    fi
    
    PKG_LIB_INITIALIZED=true
    log_info "Package manager library initialized successfully"
    return 0
}

# ============================================================================
# INFORMATION DISPLAY
# ============================================================================

pkg_show_status() {
    log_info "Package Manager Library Status:"
    log_info "  Version: $(pkg_get_config version)"
    log_info "  Package Manager: $(pkg_get_config package_manager)"
    log_info "  Verbose: $(pkg_get_config verbose)"
    log_info "  Dry Run: $(pkg_get_config dry_run)"
    log_info "  Auto Cleanup: $(pkg_get_config auto_cleanup)"
    log_info "  Update Cache: $(pkg_get_config update_cache)"
    log_info "  Retry Count: $(pkg_get_config retry_count)"
    log_info "  Timeout: $(pkg_get_config timeout)"
    log_info "  Prefer System Packages: $(pkg_get_config prefer_system_packages)"
    
    if [[ ${#INSTALLED_PACKAGES[@]} -gt 0 ]]; then
        log_info "  Installed Packages: ${INSTALLED_PACKAGES[*]}"
    fi
    
    if [[ ${#TEMP_DIRS[@]} -gt 0 ]]; then
        log_info "  Temp Directories: ${TEMP_DIRS[*]}"
    fi
}

pkg_show_supported_managers() {
    echo "Supported Package Managers:"
    echo "=========================="
    echo "Linux:"
    echo "  • apt (Ubuntu/Debian)"
    echo "  • dnf (Fedora/RHEL 8+)"
    echo "  • yum (RHEL/CentOS)"
    echo "  • pacman (Arch Linux)"
    echo "  • zypper (openSUSE)"
    echo "  • apk (Alpine Linux)"
    echo "  • xbps (Void Linux)"
    echo "  • portage (Gentoo)"
    echo "  • slackpkg (Slackware)"
    echo "  • swupd (Clear Linux)"
    echo "  • eopkg (Solus)"
    echo "  • urpmi (Mageia)"
    echo ""
    echo "Unix/BSD:"
    echo "  • pkg (FreeBSD/DragonFlyBSD)"
    echo "  • pkgin (NetBSD)"
    echo "  • pkg_add (OpenBSD)"
    echo "  • pkgutil (Solaris)"
    echo "  • installp (AIX)"
    echo ""
    echo "macOS:"
    echo "  • brew (Homebrew)"
    echo "  • macports (MacPorts)"
    echo ""
    echo "Windows:"
    echo "  • choco (Chocolatey)"
    echo "  • scoop (Scoop)"
    echo "  • winget (Windows Package Manager)"
    echo ""
    echo "Universal:"
    echo "  • nix (Nix)"
    echo "  • guix (GNU Guix)"
    echo "  • snap (Snapcraft)"
    echo "  • flatpak (Flatpak)"
}
