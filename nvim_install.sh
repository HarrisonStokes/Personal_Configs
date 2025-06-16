#!/bin/bash

# Cross-Platform NeoVim Installation Script
# Supports: Linux, macOS, Windows (WSL/MSYS2/Cygwin), FreeBSD
# Shells: bash, zsh, fish, PowerShell

set -e

# Color definitions
if [[ -t 1 ]]; then
    boldGreenFg="\033[1;32m"
    boldRedFg="\033[1;31m"
    boldYellowFg="\033[1;33m"
    boldBlueFg="\033[1;34m"
    reset="\033[0m"
else
    boldGreenFg=""
    boldRedFg=""
    boldYellowFg=""
    boldBlueFg=""
    reset=""
fi

# Global variables
OS=""
ARCH=""
SHELL_NAME=""
PACKAGE_MANAGER=""
NVIM_VERSION="v0.11.2"
INSTALL_DIR=""
BIN_DIR=""
CONFIG_DIR=""

# Utility functions
log_info() {
    echo -e "${boldBlueFg}[INFO]${reset} $1"
}

log_success() {
    echo -e "${boldGreenFg}[SUCCESS]${reset} $1"
}

log_warning() {
    echo -e "${boldYellowFg}[WARNING]${reset} $1"
}

log_error() {
    echo -e "${boldRedFg}[ERROR]${reset} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# OS Detection
detect_os() {
    case "$(uname -s)" in
        Linux*)
            if [[ -f /proc/version ]] && grep -q Microsoft /proc/version; then
                OS="WSL"
            else
                OS="Linux"
            fi
            ;;
        Darwin*)
            OS="macOS"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            OS="Windows"
            ;;
        FreeBSD*)
            OS="FreeBSD"
            ;;
        *)
            OS="Unknown"
            ;;
    esac
    log_info "Detected OS: $OS"
}

# Architecture Detection
detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)
            ARCH="x86_64"
            ;;
        arm64|aarch64)
            ARCH="arm64"
            ;;
        armv7l)
            ARCH="armv7"
            ;;
        i386|i686)
            ARCH="i386"
            ;;
        *)
            ARCH="unknown"
            ;;
    esac
    log_info "Detected architecture: $ARCH"
}

# Shell Detection
detect_shell() {
    if [[ -n "$ZSH_VERSION" ]]; then
        SHELL_NAME="zsh"
    elif [[ -n "$BASH_VERSION" ]]; then
        SHELL_NAME="bash"
    elif [[ -n "$FISH_VERSION" ]]; then
        SHELL_NAME="fish"
    else
        SHELL_NAME=$(basename "$SHELL" 2>/dev/null || echo "unknown")
    fi
    log_info "Detected shell: $SHELL_NAME"
}

# Package Manager Detection
detect_package_manager() {
    if command_exists apt; then
        PACKAGE_MANAGER="apt"
    elif command_exists brew; then
        PACKAGE_MANAGER="brew"
    elif command_exists dnf; then
        PACKAGE_MANAGER="dnf"
    elif command_exists yum; then
        PACKAGE_MANAGER="yum"
    elif command_exists pacman; then
        PACKAGE_MANAGER="pacman"
    elif command_exists zypper; then
        PACKAGE_MANAGER="zypper"
    elif command_exists apk; then
        PACKAGE_MANAGER="apk"
    elif command_exists pkg && [[ "$OS" == "FreeBSD" ]]; then
        PACKAGE_MANAGER="pkg"
    elif command_exists choco; then
        PACKAGE_MANAGER="choco"
    elif command_exists scoop; then
        PACKAGE_MANAGER="scoop"
    elif command_exists winget; then
        PACKAGE_MANAGER="winget"
    else
        PACKAGE_MANAGER="none"
    fi
    log_info "Detected package manager: $PACKAGE_MANAGER"
}

# Set directories based on OS
set_directories() {
    case "$OS" in
        "Linux"|"WSL"|"FreeBSD")
            INSTALL_DIR="/opt"
            BIN_DIR="/usr/local/bin"
            CONFIG_DIR="$HOME/.config"
            ;;
        "macOS")
            if [[ -d "/opt/homebrew" ]]; then
                INSTALL_DIR="/opt/homebrew"
                BIN_DIR="/opt/homebrew/bin"
            else
                INSTALL_DIR="/usr/local"
                BIN_DIR="/usr/local/bin"
            fi
            CONFIG_DIR="$HOME/.config"
            ;;
        "Windows")
            INSTALL_DIR="$HOME/AppData/Local"
            BIN_DIR="$HOME/AppData/Local/bin"
            CONFIG_DIR="$HOME/AppData/Local"
            mkdir -p "$BIN_DIR"
            ;;
    esac
    log_info "Install directory: $INSTALL_DIR"
    log_info "Binary directory: $BIN_DIR"
    log_info "Config directory: $CONFIG_DIR"
}

# Package management wrapper
install_package() {
    local package="$1"
    local packages="$1"
    
    log_info "Installing package(s): $packages"
    
    case "$PACKAGE_MANAGER" in
        "apt")
            sudo apt update -qq && sudo apt install -y $packages
            ;;
        "brew")
            brew install $packages
            ;;
        "dnf")
            sudo dnf install -y $packages
            ;;
        "yum")
            sudo yum install -y $packages
            ;;
        "pacman")
            sudo pacman -S --noconfirm $packages
            ;;
        "zypper")
            sudo zypper install -y $packages
            ;;
        "apk")
            sudo apk add $packages
            ;;
        "pkg")
            sudo pkg install -y $packages
            ;;
        "choco")
            choco install -y $packages
            ;;
        "scoop")
            scoop install $packages
            ;;
        "winget")
            winget install $packages
            ;;
        *)
            log_warning "No supported package manager found. Please install manually: $packages"
            return 1
            ;;
    esac
}

# Remove old NeoVim installations
clean_previous_installations() {
    log_info "Cleaning previous NeoVim installations..."
    
    case "$OS" in
        "Linux"|"WSL"|"FreeBSD")
            sudo rm -rf /opt/nvim* 2>/dev/null || true
            sudo rm -f /usr/local/bin/nvim 2>/dev/null || true
            sudo rm -f /usr/bin/nvim 2>/dev/null || true
            ;;
        "macOS")
            sudo rm -rf /usr/local/nvim* 2>/dev/null || true
            sudo rm -rf /opt/homebrew/nvim* 2>/dev/null || true
            sudo rm -f /usr/local/bin/nvim 2>/dev/null || true
            sudo rm -f /opt/homebrew/bin/nvim 2>/dev/null || true
            ;;
        "Windows")
            rm -rf "$HOME/AppData/Local/nvim"* 2>/dev/null || true
            rm -f "$BIN_DIR/nvim.exe" 2>/dev/null || true
            ;;
    esac
    
    # Clean config directory
    rm -rf "$CONFIG_DIR/nvim" 2>/dev/null || true
}

# Install dependencies
install_dependencies() {
    log_info "Installing dependencies..."
    
    case "$OS" in
        "Linux"|"WSL")
            case "$PACKAGE_MANAGER" in
                "apt")
                    install_package "git curl build-essential nodejs npm python3-pip ripgrep fd-find"
                    ;;
                "dnf"|"yum")
                    install_package "git curl gcc gcc-c++ make nodejs npm python3-pip ripgrep fd-find"
                    ;;
                "pacman")
                    install_package "git curl base-devel nodejs npm python-pip ripgrep fd"
                    ;;
                "zypper")
                    install_package "git curl gcc gcc-c++ make nodejs npm python3-pip ripgrep fd"
                    ;;
                "apk")
                    install_package "git curl build-base nodejs npm py3-pip ripgrep fd"
                    ;;
            esac
            ;;
        "macOS")
            if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
                install_package "git curl node python ripgrep fd"
            fi
            ;;
        "FreeBSD")
            install_package "git curl node python3 py39-pip ripgrep fd-find"
            ;;
        "Windows")
            case "$PACKAGE_MANAGER" in
                "choco")
                    install_package "git curl nodejs python ripgrep fd"
                    ;;
                "scoop")
                    install_package "git curl nodejs python ripgrep fd"
                    ;;
                "winget")
                    install_package "Git.Git Curl NodeJS.NodeJS Python.Python.3 BurntSushi.ripgrep sharkdp.fd"
                    ;;
            esac
            ;;
    esac
    
    # Install Node.js and Python packages
    if command_exists npm; then
        log_info "Installing Node.js neovim package..."
        npm install -g neovim 2>/dev/null || log_warning "Failed to install Node.js neovim package"
    fi
    
    if command_exists pip3; then
        log_info "Installing Python neovim package..."
        pip3 install --user --upgrade pynvim 2>/dev/null || log_warning "Failed to install Python neovim package"
    elif command_exists pip; then
        log_info "Installing Python neovim package..."
        pip install --user --upgrade pynvim 2>/dev/null || log_warning "Failed to install Python neovim package"
    fi
}

# Get NeoVim download URL
get_nvim_url() {
    local base_url="https://github.com/neovim/neovim/releases/download/$NVIM_VERSION"
    
    case "$OS" in
        "Linux"|"WSL"|"FreeBSD")
            case "$ARCH" in
                "x86_64")
                    echo "$base_url/nvim-linux64.tar.gz"
                    ;;
                "arm64")
                    echo "$base_url/nvim-linux-arm64.tar.gz"
                    ;;
                *)
                    echo ""
                    ;;
            esac
            ;;
        "macOS")
            case "$ARCH" in
                "x86_64")
                    echo "$base_url/nvim-macos-x86_64.tar.gz"
                    ;;
                "arm64")
                    echo "$base_url/nvim-macos-arm64.tar.gz"
                    ;;
                *)
                    echo ""
                    ;;
            esac
            ;;
        "Windows")
            echo "$base_url/nvim-win64.zip"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Download and install NeoVim
install_neovim() {
    log_info "Installing NeoVim $NVIM_VERSION..."
    
    # Try package manager first
    case "$PACKAGE_MANAGER" in
        "brew")
            if brew install neovim; then
                log_success "NeoVim installed via Homebrew"
                return 0
            fi
            ;;
        "apt")
            # Ubuntu/Debian often have old versions, so we'll skip package manager
            ;;
        "pacman")
            if sudo pacman -S --noconfirm neovim; then
                log_success "NeoVim installed via pacman"
                return 0
            fi
            ;;
        "pkg")
            if sudo pkg install -y neovim; then
                log_success "NeoVim installed via pkg"
                return 0
            fi
            ;;
    esac
    
    # Manual installation
    local download_url=$(get_nvim_url)
    
    if [[ -z "$download_url" ]]; then
        log_error "No download URL available for OS: $OS, ARCH: $ARCH"
        return 1
    fi
    
    log_info "Downloading from: $download_url"
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    if ! curl -fsSL "$download_url" -o nvim_archive; then
        log_error "Failed to download NeoVim"
        return 1
    fi
    
    # Extract archive
    case "$download_url" in
        *.tar.gz)
            tar -xzf nvim_archive
            ;;
        *.zip)
            if command_exists unzip; then
                unzip -q nvim_archive
            else
                log_error "unzip not found. Please install unzip."
                return 1
            fi
            ;;
    esac
    
    # Find extracted directory
    local extracted_dir=$(find . -maxdepth 1 -type d -name "*nvim*" | head -1)
    
    if [[ -z "$extracted_dir" ]]; then
        log_error "Could not find extracted NeoVim directory"
        return 1
    fi
    
    # Install NeoVim
    case "$OS" in
        "Linux"|"WSL"|"FreeBSD"|"macOS")
            sudo cp -r "$extracted_dir" "$INSTALL_DIR/nvim"
            sudo ln -sf "$INSTALL_DIR/nvim/bin/nvim" "$BIN_DIR/nvim"
            sudo chmod +x "$BIN_DIR/nvim"
            ;;
        "Windows")
            cp -r "$extracted_dir" "$INSTALL_DIR/nvim"
            cp "$INSTALL_DIR/nvim/bin/nvim.exe" "$BIN_DIR/nvim.exe"
            ;;
    esac
    
    cd - >/dev/null
    rm -rf "$temp_dir"
    
    # Verify installation
    if command_exists nvim; then
        log_success "NeoVim installed successfully!"
        nvim --version | head -1
    else
        log_error "NeoVim installation verification failed"
        return 1
    fi
}

# Configure shell aliases and environment
configure_shell() {
    log_info "Configuring shell environment..."
    
    local config_file=""
    local alias_syntax=""
    local export_syntax=""
    
    case "$SHELL_NAME" in
        "bash")
            config_file="$HOME/.bashrc"
            alias_syntax="alias"
            export_syntax="export"
            ;;
        "zsh")
            config_file="$HOME/.zshrc"
            alias_syntax="alias"
            export_syntax="export"
            ;;
        "fish")
            config_file="$HOME/.config/fish/config.fish"
            alias_syntax="alias"
            export_syntax="set -gx"
            mkdir -p "$(dirname "$config_file")"
            ;;
        *)
            log_warning "Unknown shell: $SHELL_NAME. Skipping shell configuration."
            return 0
            ;;
    esac
    
    if [[ ! -f "$config_file" ]]; then
        touch "$config_file"
    fi
    
    # Add aliases and environment variables
    local aliases_added=false
    
    if ! grep -q "alias vim=nvim" "$config_file" 2>/dev/null; then
        echo "" >> "$config_file"
        echo "# NeoVim aliases and environment" >> "$config_file"
        
        if [[ "$SHELL_NAME" == "fish" ]]; then
            echo "alias vim nvim" >> "$config_file"
            echo "alias vi nvim" >> "$config_file"
            echo "set -gx EDITOR nvim" >> "$config_file"
            echo "set -gx VISUAL nvim" >> "$config_file"
        else
            echo "alias vim=nvim" >> "$config_file"
            echo "alias vi=nvim" >> "$config_file"
            echo "export EDITOR=nvim" >> "$config_file"
            echo "export VISUAL=nvim" >> "$config_file"
        fi
        
        # Add binary directory to PATH if needed
        if [[ "$OS" == "Windows" ]] && [[ "$BIN_DIR" != "/usr/local/bin" ]]; then
            if [[ "$SHELL_NAME" == "fish" ]]; then
                echo "set -gx PATH $BIN_DIR \$PATH" >> "$config_file"
            else
                echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$config_file"
            fi
        fi
        
        aliases_added=true
    fi
    
    if [[ "$aliases_added" == "true" ]]; then
        log_success "Shell configuration updated. Run 'source $config_file' or restart your shell."
    else
        log_info "Shell configuration already exists."
    fi
}

# Download NeoVim configuration
install_nvim_config() {
    log_info "Installing NeoVim configuration..."
    
    local repo_url="https://github.com/HarrisonStokes/Personal_Configs/archive/refs/heads/main.zip"
    local temp_dir=$(mktemp -d)
    
    cd "$temp_dir"
    
    if ! curl -fsSL "$repo_url" -o config.zip; then
        log_warning "Failed to download configuration. Skipping..."
        return 0
    fi
    
    if command_exists unzip; then
        unzip -q config.zip
    else
        log_warning "unzip not found. Cannot extract configuration."
        return 0
    fi
    
    local extracted_dir=$(find . -maxdepth 1 -type d -name "*Personal_Configs*" | head -1)
    
    if [[ -n "$extracted_dir" ]] && [[ -d "$extracted_dir/nvim" ]]; then
        mkdir -p "$CONFIG_DIR"
        cp -r "$extracted_dir/nvim" "$CONFIG_DIR/"
        log_success "NeoVim configuration installed"
    else
        log_warning "Configuration directory not found in archive"
    fi
    
    cd - >/dev/null
    rm -rf "$temp_dir"
}

# Install additional LSP servers and tools
install_lsp_tools() {
    log_info "Installing LSP servers and development tools..."
    
    # Language servers that can be installed via package managers
    case "$PACKAGE_MANAGER" in
        "apt")
            install_package "clangd rustc" 2>/dev/null || true
            ;;
        "brew")
            install_package "llvm rust-analyzer" 2>/dev/null || true
            ;;
        "pacman")
            install_package "clang rust-analyzer" 2>/dev/null || true
            ;;
        "dnf"|"yum")
            install_package "clang rust" 2>/dev/null || true
            ;;
    esac
    
    # Install via npm if available
    if command_exists npm; then
        log_info "Installing Node.js-based LSP servers..."
        npm install -g typescript-language-server vscode-langservers-extracted 2>/dev/null || true
    fi
    
    # Install via pip if available
    if command_exists pip3; then
        log_info "Installing Python-based tools..."
        pip3 install --user black flake8 mypy 2>/dev/null || true
    fi
}

# Main installation function
main() {
    echo "=================================="
    echo "         NeoVim Installer         "
    echo "=================================="
    echo ""
    
    # Detect system
    detect_os
    detect_arch
    detect_shell
    detect_package_manager
    set_directories
    
    # Check for unsupported configurations
    if [[ "$OS" == "Unknown" ]] || [[ "$ARCH" == "unknown" ]]; then
        log_error "Unsupported OS ($OS) or architecture ($ARCH)"
        exit 1
    fi
    
    echo ""
    log_info "Starting installation process..."
    echo ""
    
    # Installation steps
    clean_previous_installations
    sleep 1
    
    install_dependencies
    sleep 1
    
    install_neovim
    sleep 1
    
    configure_shell
    sleep 1
    
    install_nvim_config
    sleep 1
    
    install_lsp_tools
    sleep 1
    
    echo ""
    echo "=================================="
    log_success "Installation complete!"
    echo "=================================="
    echo ""
    echo "Next steps:"
    echo "1. Restart your shell or run: source ~/.bashrc (or ~/.zshrc)"
    echo "2. Run 'nvim' to start NeoVim"
    echo "3. Let plugins install automatically on first run"
    echo "4. Run ':checkhealth' in NeoVim to verify everything works"
    echo ""
    
    if command_exists nvim; then
        echo "NeoVim version:"
        nvim --version | head -3
        echo ""
        
        read -p "Would you like to start NeoVim now? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            exec nvim
        fi
    else
        log_warning "NeoVim command not found in PATH. You may need to restart your shell."
    fi
}

main "$@"
