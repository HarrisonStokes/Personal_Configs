#!/bin/bash

# Cross-Platform NeoVim Installation Script
# Supports: Linux, macOS, Windows (WSL/MSYS2/Cygwin), FreeBSD

load_scripts() {
    source ./lib/logger.sh
    source ./lib/system.sh
    source ./lib/pkg_manager.sh
}
load_scripts

# Global variables
NVIM_VERSION="stable"
INSTALL_DIR=""
BIN_DIR=""
CONFIG_DIR=""

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
   
    install_dependencies "${required[@]}" "${optional[@]}"

    # Development dependencies
    local dev_packages=()
    case "$PACKAGE_MANAGER" in
        apt) dev_packages=("python3-pip" "python3-venv" "pipx" "ripgrep" "fd-find") ;;
        brew) dev_packages=("node" "python" "pipx" "ripgrep" "fd") ;;
        dnf|yum) dev_packages=("nodejs" "npm" "python3-pip" "python3-venv" "pipx" "ripgrep" "fd-find") ;;
        pacman) dev_packages=("nodejs" "npm" "python-pip" "python-pipx" "ripgrep" "fd") ;;
        pkg) dev_packages=("node" "py39-pip" "py39-pipx" "ripgrep" "fd-find") ;;
    esac

    for package in "${dev_packages[@]}"; do
        try_install_package "$package" || true
    done

    # Verify Node.js and npm
    if ! command_exists node || ! command_exists npm; then
        log_warn "Node.js or npm not found. Attempting to install via nvm..."
        if ! command_exists nvm; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        fi
        nvm install --lts
        nvm use --lts
        if ! command_exists npm; then
            log_error "Failed to install npm. Please install Node.js manually."
            return 1
        fi
    fi
 
    # Update npm to the latest version
    log_info "Updating npm to the latest version..."
    if npm install -g npm@latest; then
        log_success "Updated npm to the latest version: $(npm --version)"
    else
        log_warn "Failed to update npm. Continuing with current version: $(npm --version)"
    fi
    
    # Verify npm is functional
    npm --version >/dev/null 2>&1 || {
        log_error "npm is installed but not functional. Please check your Node.js installation."
        return 1
    }
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
            sudo rm -rf "$path" 2>/dev/null || true
        else
            rm -rf "$path" 2>/dev/null || true
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

    local reponame="personal-configs"
    local repo_url="https://github.com/HarrisonStokes/$reponame/archive/refs/heads/main.zip"
    local temp_dir
    temp_dir=$(create_temp_dir)

    cd "$temp_dir"

    if curl -fsSL "$repo_url" -o config.zip && command_exists unzip; then
        unzip -q config.zip
        local extracted_dir
        extracted_dir=$(find . -maxdepth 1 -type d -name "*$reponame*" | head -1)

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
