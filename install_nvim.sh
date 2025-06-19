#!/bin/bash

# Cross-Platform NeoVim Installation Script
# Supports: Linux, macOS, Windows (WSL/MSYS2/Cygwin), FreeBSD

# Color definitions
if [[ -t 1 ]]; then
    readonly GREEN="\033[1;32m"
    readonly RED="\033[1;31m"
    readonly YELLOW="\033[1;33m"
    readonly BLUE="\033[1;34m"
    readonly RESET="\033[0m"
else
    readonly GREEN="" RED="" YELLOW="" BLUE="" RESET=""
fi

# Global variables
OS=""
ARCH=""
SHELL_NAME=""
PACKAGE_MANAGER=""
NVIM_VERSION="stable"
INSTALL_DIR=""
BIN_DIR=""
CONFIG_DIR=""
TEMP_DIRS=()
INSTALLED_PACKAGES=()

# Utility functions
log_info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${RESET} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${RESET} $1"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $1"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

cleanup() {
    local exit_code=$?
    for temp_dir in "${TEMP_DIRS[@]}"; do
        [[ -d "$temp_dir" ]] && rm -rf "$temp_dir"
    done
    
    # Remove packages that were installed by this script
    if [[ ${#INSTALLED_PACKAGES[@]} -gt 0 ]]; then
        log_info "Cleaning up installed packages..."
        for package in "${INSTALLED_PACKAGES[@]}"; do
            remove_package "$package" || log_warn "Failed to remove $package"
        done
    fi
    
    exit $exit_code
}

create_temp_dir() {
    local temp_dir
    temp_dir=$(mktemp -d -t nvim_install.XXXXXX)
    TEMP_DIRS+=("$temp_dir")
    echo "$temp_dir"
}

detect_system() {
    # Detect OS
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
    
    # Detect architecture
    case "$(uname -m)" in
        x86_64|amd64) ARCH="x86_64" ;;
        arm64|aarch64) ARCH="arm64" ;;
        armv7l) ARCH="armv7" ;;
        i386|i686) ARCH="i386" ;;
        *) ARCH="unknown" ;;
    esac
    
    # Detect shell
    if [[ -n "$ZSH_VERSION" ]]; then
        SHELL_NAME="zsh"
    elif [[ -n "$BASH_VERSION" ]]; then
        SHELL_NAME="bash"
    elif [[ -n "$FISH_VERSION" ]]; then
        SHELL_NAME="fish"
    else
        SHELL_NAME=$(basename "$SHELL" 2>/dev/null || echo "bash")
    fi
    
    # Detect package manager
    local managers=("apt" "brew" "dnf" "yum" "pacman" "zypper" "apk" "pkg" "choco" "scoop" "winget")
    for mgr in "${managers[@]}"; do
        if command_exists "$mgr"; then
            [[ "$mgr" == "pkg" && "$OS" != "FreeBSD" ]] && continue
            PACKAGE_MANAGER="$mgr"
            break
        fi
    done
    [[ -z "$PACKAGE_MANAGER" ]] && PACKAGE_MANAGER="none"
    
    log_info "Architecture: $ARCH"
    log_info "OS: $OS"
    log_info "Shell: $SHELL_NAME"
    log_info "Package Manager: $PACKAGE_MANAGER"
}

set_directories() {
    case "$OS" in
        Linux|WSL|FreeBSD)
            INSTALL_DIR="/opt"
            BIN_DIR="/usr/local/bin"
            CONFIG_DIR="$HOME/.config"
            ;;
        macOS)
            if [[ -d "/opt/homebrew" ]]; then
                INSTALL_DIR="/opt/homebrew"
                BIN_DIR="/opt/homebrew/bin"
            else
                INSTALL_DIR="/usr/local"
                BIN_DIR="/usr/local/bin"
            fi
            CONFIG_DIR="$HOME/.config"
            ;;
        Windows)
            INSTALL_DIR="$HOME/AppData/Local"
            BIN_DIR="$HOME/AppData/Local/bin"
            CONFIG_DIR="$HOME/AppData/Local"
            mkdir -p "$BIN_DIR"
            ;;
    esac
}

try_install_package() {
    local package="$1"
    local was_installed=false
    
    # Check if package is already installed
    case "$PACKAGE_MANAGER" in
        apt) dpkg -l "$package" &>/dev/null && was_installed=true ;;
        dnf|yum) rpm -q "$package" &>/dev/null && was_installed=true ;;
        pacman) pacman -Q "$package" &>/dev/null && was_installed=true ;;
        brew) brew list "$package" &>/dev/null && was_installed=true ;;
        pkg) pkg info "$package" &>/dev/null && was_installed=true ;;
        *) was_installed=true ;; # Assume installed for other managers
    esac
    
    if [[ "$was_installed" == "false" ]]; then
        if install_package "$package"; then
            INSTALLED_PACKAGES+=("$package")
            return 0
        fi
        return 1
    fi
    return 0
}

install_package() {
    local package="$1"
    
    case "$PACKAGE_MANAGER" in
        apt)
            sudo apt-get update -qq || true
            sudo apt-get install -y "$package"
            ;;
        brew) brew install "$package" ;;
        dnf) sudo dnf install -y "$package" ;;
        yum) sudo yum install -y "$package" ;;
        pacman) sudo pacman -S --noconfirm "$package" ;;
        zypper) sudo zypper install -y "$package" ;;
        apk) sudo apk add "$package" ;;
        pkg) sudo pkg install -y "$package" ;;
        choco) choco install -y "$package" ;;
        scoop) scoop install "$package" ;;
        winget) winget install "$package" ;;
        *) log_warn "No supported package manager found"; return 1 ;;
    esac
}

remove_package() {
    local package="$1"
    
    case "$PACKAGE_MANAGER" in
        apt) sudo apt-get remove -y "$package" ;;
        dnf) sudo dnf remove -y "$package" ;;
        yum) sudo yum remove -y "$package" ;;
        pacman) sudo pacman -R --noconfirm "$package" ;;
        brew) brew uninstall "$package" ;;
        pkg) sudo pkg delete -y "$package" ;;
        *) return 0 ;;
    esac
}

install_python_neovim() {
    log_info "Installing Python neovim support..."
    
    case "$PACKAGE_MANAGER" in
        apt)
            if try_install_package "python3-neovim" || try_install_package "python3-pynvim"; then
                return 0
            fi
            ;;
        dnf|yum)
            if try_install_package "python3-neovim" || try_install_package "python3-pynvim"; then
                return 0
            fi
            ;;
        pacman)
            if try_install_package "python-neovim" || try_install_package "python-pynvim"; then
                return 0
            fi
            ;;
        brew)
            if try_install_package "python-neovim"; then
                return 0
            fi
            ;;
        pkg)
            if try_install_package "py39-neovim" || try_install_package "py39-pynvim"; then
                return 0
            fi
            ;;
    esac
    
    # Try pipx (recommended for externally-managed environments)
    if command_exists pipx; then
        if pipx install pynvim; then
            log_success "Installed pynvim via pipx"
            return 0
        fi
    elif command_exists pip3 && try_install_package "python3-pipx"; then
        if pipx install pynvim; then
            log_success "Installed pynvim via pipx"
            return 0
        fi
    fi
    
    # Try user install as fallback
    if command_exists pip3; then
        if pip3 install --user --upgrade pynvim; then
            log_success "Installed pynvim via pip3 --user"
            return 0
        fi
    fi
    
    log_warn "Could not install Python neovim support. Install manually: pip3 install --user pynvim"
}

install_node_neovim() {
    log_info "Installing Node.js neovim support..."
    
    if ! command_exists npm; then
        return 0
    fi
    
    if sudo npm install -g neovim 2>/dev/null; then
        log_success "Installed neovim via npm (global)"
        return 0
    fi
    
    mkdir -p "$HOME/.local/lib"
    if npm install --prefix "$HOME/.local" neovim; then
        # Add to PATH if not already there
        local npm_bin="$HOME/.local/bin"
        if [[ ":$PATH:" != *":$npm_bin:"* ]]; then
            export PATH="$npm_bin:$PATH"
        fi
        log_success "Installed neovim via npm (user-local)"
        return 0
    fi
    
    log_warn "Could not install Node.js neovim support. Install manually: npm install -g neovim"
}

ensure_dependencies() {
    log_info "Ensuring required dependencies..."
    
    # Essential tools
    local required=("curl" "git")
    local optional=("unzip" "tar")
    
    for tool in "${required[@]}"; do
        if ! command_exists "$tool"; then
            try_install_package "$tool" || {
                log_error "Failed to install required dependency: $tool"
                return 1
            }
        fi
    done
    
    for tool in "${optional[@]}"; do
        command_exists "$tool" || try_install_package "$tool" || true
    done
    
    # Development dependencies
    local dev_packages=()
    case "$PACKAGE_MANAGER" in
        apt) dev_packages=("nodejs" "npm" "python3-pip" "python3-venv" "pipx" "ripgrep" "fd-find") ;;
        brew) dev_packages=("node" "python" "pipx" "ripgrep" "fd") ;;
        dnf|yum) dev_packages=("nodejs" "npm" "python3-pip" "python3-venv" "pipx" "ripgrep" "fd-find") ;;
        pacman) dev_packages=("nodejs" "npm" "python-pip" "python-pipx" "ripgrep" "fd") ;;
        pkg) dev_packages=("node" "py39-pip" "py39-pipx" "ripgrep" "fd-find") ;;
    esac
    
    for package in "${dev_packages[@]}"; do
        try_install_package "$package" || true
    done
    
    # Install language support
    install_python_neovim
    install_node_neovim
}

clean_previous_installations() {
    log_info "Cleaning previous installations..."
    
    local paths_to_clean=(
        "/opt/nvim*" "/usr/local/nvim*" "/opt/homebrew/nvim*"
        "/usr/local/bin/nvim" "/usr/bin/nvim" "/opt/homebrew/bin/nvim"
        "$HOME/AppData/Local/nvim*" "$BIN_DIR/nvim*"
        "$CONFIG_DIR/nvim"
    )
    
    for path in "${paths_to_clean[@]}"; do
        if [[ "$path" == *"/usr/"* ]] || [[ "$path" == *"/opt/"* ]]; then
            sudo rm -rf $path 2>/dev/null || true
        else
            rm -rf $path 2>/dev/null || true
        fi
    done
}

get_nvim_download_url() {
    local base_url="https://github.com/neovim/neovim/releases/download/$NVIM_VERSION"
    
    case "$OS-$ARCH" in
        Linux-x86_64|WSL-x86_64|FreeBSD-x86_64) echo "$base_url/nvim-linux-x86_64.tar.gz" ;;
        Linux-arm64|WSL-arm64|FreeBSD-arm64) echo "$base_url/nvim-linux-arm64.tar.gz" ;;
        macOS-x86_64) echo "$base_url/nvim-macos-x86_64.tar.gz" ;;
        macOS-arm64) echo "$base_url/nvim-macos-arm64.tar.gz" ;;
        Windows-*) echo "$base_url/nvim-win64.zip" ;;
        *) echo "" ;;
    esac
}

install_neovim() {
    log_info "Installing NeoVim $NVIM_VERSION..."
    
    case "$PACKAGE_MANAGER" in
        brew|pacman|pkg)
            if "$PACKAGE_MANAGER" install neovim && command_exists nvim; then
                log_success "NeoVim installed via $PACKAGE_MANAGER"
                return 0
            fi
            ;;
        dnf|yum)
            if sudo "$PACKAGE_MANAGER" install -y neovim && command_exists nvim; then
                log_success "NeoVim installed via $PACKAGE_MANAGER"
                return 0
            fi
            ;;
    esac
    
    # Manual installation
    local download_url
    download_url=$(get_nvim_download_url)
    
    if [[ -z "$download_url" ]]; then
        log_error "No download URL available for $OS-$ARCH"
        return 1
    fi
    
    log_info "Downloading from: $download_url"
    
    local temp_dir
    temp_dir=$(create_temp_dir)
    cd "$temp_dir"
    
    # Download with fallback methods
    local download_success=false
    if command_exists curl; then
        curl -fsSL "$download_url" -o nvim_archive && download_success=true
    elif command_exists wget; then
        wget -q "$download_url" -O nvim_archive && download_success=true
    fi
    
    if [[ "$download_success" != "true" ]]; then
        log_error "Failed to download NeoVim"
        return 1
    fi
    
    # Extract archive
    if [[ "$download_url" == *.tar.gz ]]; then
        tar -xzf nvim_archive || { log_error "Failed to extract archive"; return 1; }
    elif [[ "$download_url" == *.zip ]]; then
        if command_exists unzip; then
            unzip -q nvim_archive || { log_error "Failed to extract archive"; return 1; }
        else
            log_error "unzip not found"
            return 1
        fi
    fi
    
    # Find and install extracted directory
    local extracted_dir
    extracted_dir=$(find . -maxdepth 1 -type d -name "*nvim*" | head -1)
    
    if [[ -z "$extracted_dir" ]]; then
        log_error "Could not find extracted NeoVim directory"
        return 1
    fi
    
    case "$OS" in
        Linux|WSL|FreeBSD|macOS)
            sudo cp -r "$extracted_dir" "$INSTALL_DIR/nvim"
            sudo ln -sf "$INSTALL_DIR/nvim/bin/nvim" "$BIN_DIR/nvim"
            sudo chmod +x "$BIN_DIR/nvim"
            ;;
        Windows)
            cp -r "$extracted_dir" "$INSTALL_DIR/nvim"
            cp "$INSTALL_DIR/nvim/bin/nvim.exe" "$BIN_DIR/nvim.exe"
            ;;
    esac
    
    cd - >/dev/null
    
    if command_exists nvim; then
        log_success "NeoVim installed successfully!"
        nvim --version | head -1
    else
        log_error "NeoVim installation verification failed"
        return 1
    fi
}

configure_shell() {
    log_info "Configuring shell environment..."
    
    local config_file
    case "$SHELL_NAME" in
        bash) config_file="$HOME/.bashrc" ;;
        zsh) config_file="$HOME/.zshrc" ;;
        fish) 
            config_file="$HOME/.config/fish/config.fish"
            mkdir -p "$(dirname "$config_file")"
            ;;
        *) 
            log_warn "Unknown shell: $SHELL_NAME. Skipping configuration."
            return 0
            ;;
    esac
    
    [[ ! -f "$config_file" ]] && touch "$config_file"
    
    if ! grep -q "alias vim=nvim\|alias vim nvim" "$config_file" 2>/dev/null; then
        {
            echo ""
            echo "# NeoVim configuration"
            if [[ "$SHELL_NAME" == "fish" ]]; then
                echo "alias vim nvim"
                echo "alias vi nvim"
                echo "set -gx EDITOR nvim"
                echo "set -gx VISUAL nvim"
                [[ "$OS" == "Windows" ]] && echo "set -gx PATH $BIN_DIR \$PATH"
            else
                echo "alias vim=nvim"
                echo "alias vi=nvim"
                echo "export EDITOR=nvim"
                echo "export VISUAL=nvim"
                [[ "$OS" == "Windows" ]] && echo "export PATH=\"$BIN_DIR:\$PATH\""
            fi
        } >> "$config_file"
        
        log_success "Shell configuration updated"
    fi
}

install_config() {
    log_info "Installing NeoVim configuration..."
    
    local repo_url="https://github.com/HarrisonStokes/Personal_Configs/archive/refs/heads/main.zip"
    local temp_dir
    temp_dir=$(create_temp_dir)
    
    cd "$temp_dir"
    
    if curl -fsSL "$repo_url" -o config.zip && command_exists unzip; then
        unzip -q config.zip
        local extracted_dir
        extracted_dir=$(find . -maxdepth 1 -type d -name "*Personal_Configs*" | head -1)
        
        if [[ -n "$extracted_dir" && -d "$extracted_dir/nvim" ]]; then
            mkdir -p "$CONFIG_DIR"
            cp -r "$extracted_dir/nvim" "$CONFIG_DIR/"
            log_success "Configuration installed"
        else
            log_warn "Configuration not found in archive"
        fi
    else
        log_warn "Failed to download or extract configuration"
    fi
    
    cd - >/dev/null
}

install_font() {
    confirm "Would you like to install JetBrains Mono Nerd Font" 
    if [ "$?" -eq 1 ]; then
        return
    fi
    log_info "Installing JetBrains Mono Nerd Font..."
    
    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"
    
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/JetBrainsMono.zip"
    local temp_dir
    temp_dir=$(create_temp_dir)
    
    cd "$temp_dir"
    
    if curl -fsSL "$font_url" -o font.zip && command_exists unzip; then
        unzip -q font.zip -d "$font_dir/"
        command_exists fc-cache && fc-cache -fv &>/dev/null
        log_success "Font installed"
        
        if [[ "$OS" == "WSL" ]]; then
            log_warn "WSL requires manual font installation on Windows side"
            echo "1. Download $font_url onto your Windows file system."
            echo "2. Extract zip."
            echo "3. Select all .ttf files."
            echo "4. Right-click → 'Install' or 'Install for all users'."
            echo "5. Restart Terminal after script finishes."
            echo "6. Apply any of the following fonts in WSL setting:"
            echo "   * JetBrainsMono Nerd Font"
            echo "   * JetBrainsMono NF"
            echo "   * JetBrainsMonoNL Nerd Font"
            echo "   * JetBrainsMonoNL NF"
            confirm "Would you like to continue?" "(y)"
        fi
    else
        log_warn "Font installation failed"
    fi
    
    cd - >/dev/null
}

confirm() {
    local prompt="$1"
    local option=${2:-"(y/n)"}
    local response

    while true; do
        read -rp "$prompt $option: " response
        case "$response" in
            [Yy]|[Yy][Ee][Ss])
                return 0 
                ;;
            [Nn]|[Nn][Oo])
                return 1
                ;;
            *) echo "Please answer $option" ;;
        esac
    done
}

main() {
    trap cleanup EXIT INT TERM
    
    echo "=================================="
    echo "         NeoVim Installer         "
    echo "=================================="
    echo
    
    detect_system
    set_directories
    
    if [[ "$OS" == "Unknown" || "$ARCH" == "unknown" ]]; then
        log_error "Unsupported system: $OS-$ARCH"
        exit 1
    fi
    
    log_info "Starting installation process..."
    echo
    
    clean_previous_installations
    ensure_dependencies
    install_font
    install_neovim
    configure_shell
    install_config
    
    echo
    echo "=================================="
    log_success "Installation complete!"
    echo "=================================="
    echo
    echo "Next steps:"
    echo "1. Restart your shell or run: source ~/.${SHELL_NAME}rc"
    echo "2. Run 'nvim' to start NeoVim"
    echo "3. Run ':checkhealth' in NeoVim to verify setup"
    echo
    
    if command_exists nvim; then
        nvim --version | head -3
        echo
        confirm "Start NeoVim now?" && exec nvim
    else
        log_warn "NeoVim not found in PATH. Restart your shell."
    fi
}

main "$@"
