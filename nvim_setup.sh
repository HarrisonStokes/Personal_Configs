#!/bin/bash

boldGreenFg="\033[1;32m"
boldRedFg="\033[1;31m"
reset="\033[0m"

function clear_previous_nvim()
{
    echo "Removing old NeoVim installations..."
    sudo apt remove neovim -y &> /dev/null
    sudo rm -rf /opt/nvim-linux* &> /dev/null
    sudo rm -f /usr/local/bin/nvim &> /dev/null  
    sudo rm -rf ~/.config/nvim/ &> /dev/null    
}

# $1 - Tool name.
# $2 - Install = true. Uninstall = false.
function package_manager()
{
    local pkg="$1"
    local install="$2"
    
    if [[ "$install" == "true" ]]; then
        echo -e "$boldGreenFg Installing $reset $pkg"
    else
        echo -e "$boldRedFg Uninstalling $reset $pkg"
    fi
    
    if command -v apt &> /dev/null; then
        if [[ "$install" == "true" ]]; then
            sudo apt install -y $pkg
        else
            sudo apt remove -y $pkg
        fi
    elif command -v dnf &> /dev/null; then
        if [[ "$install" == "true" ]]; then
            sudo dnf install -y $pkg
        else
            sudo dnf remove -y $pkg
        fi
    elif command -v yum &> /dev/null; then
        if [[ "$install" == "true" ]]; then
            sudo yum install -y $pkg
        else
            sudo yum remove -y $pkg
        fi
    elif command -v pacman &> /dev/null; then
        if [[ "$install" == "true" ]]; then
            sudo pacman -S --noconfirm $pkg
        else
            sudo pacman -R --noconfirm $pkg
        fi
    elif command -v zypper &> /dev/null; then
        if [[ "$install" == "true" ]]; then
            sudo zypper install -y $pkg
        else
            sudo zypper remove -y $pkg
        fi
    elif command -v apk &> /dev/null; then
        if [[ "$install" == "true" ]]; then
            sudo apk add $pkg
        else
            sudo apk del $pkg
        fi
    fi
}

installedWget=false
installedUnzip=false
installedTar=false

function get_pkgs()
{
    echo "Installing necessary packages..."
    
    if ! command -v wget &> /dev/null; then
        installedWget=true
        package_manager "wget" "true"
    fi
    
    if ! command -v unzip &> /dev/null; then
        installedUnzip=true
        package_manager "unzip" "true"
    fi
    
    if ! command -v tar &> /dev/null; then
        installedTar=true
        package_manager "tar" "true"
    fi
}

function remove_pkgs()
{
    echo "Removing unnecessary packages..."
    
    if [[ "$installedWget" == "true" ]]; then
        package_manager "wget" "false"
    fi
    
    if [[ "$installedUnzip" == "true" ]]; then
        package_manager "unzip" "false"
    fi
    
    if [[ "$installedTar" == "true" ]]; then
        package_manager "tar" "false"
    fi
}

function download_nvim()
{
    local defaultUrl="https://github.com/neovim/neovim/releases/download/v0.11.2/nvim-linux-x86_64.tar.gz"
    local userUrl
    
    echo "NeoVim packages: https://github.com/neovim/neovim/releases/"
    echo "Recommended version 0.11+"
    echo "Copy package link under Assets."
    read -p "Enter package URL (Leaving empty will use default) > " userUrl
    
    if [[ -z "$userUrl" ]]; then
        userUrl="$defaultUrl"
    fi
    
    echo "Downloading NeoVim..."
    wget "$userUrl" -q --show-progress
    
    if [[ $? -ne 0 ]]; then
        echo -e "$boldRedFg FAILED$reset: NeoVim package download failed!"
        exit $?
    fi
    
    filename="${userUrl##*/}"
    
    # Extract based on file extension
    if [[ "$filename" == *.tar.gz ]] || [[ "$filename" == *.tar ]]; then
        echo "Extracting tar archive..."
        sudo tar -C /opt -xzf "$filename"
    elif [[ "$filename" == *.zip ]]; then
        echo "Extracting zip archive..."
        sudo unzip -q "$filename" -d /opt/
    else
        echo -e "$boldRedFg FAILED$reset: Unable to handle file type!"
        exit 1
    fi
    
    if [[ "$filename" == *.tar.gz ]]; then
        binname="${filename%.tar.gz}"
    else
        binname="${filename%.*}"
    fi
    
    # Create symlink 
    if [[ -d "/opt/$binname" ]]; then
        sudo ln -sf /opt/$binname/bin/nvim /usr/local/bin/nvim
    else
        echo "Warning: Expected directory structure not found. Please check /opt/ and create symlink manually."
    fi
    
    rm "$filename"
    
    # Verify installation
    hash -r
    if nvim --version &> /dev/null; then
        echo "NeoVim installed successfully!"
        nvim --version | head -1
    else
        echo -e "$boldRedFg FAILED$reset: NeoVim installation verification failed!"
        exit 1
    fi
}

function get_dependencies()
{
    echo "Installing dependencies..."
    
    # Core dependencies
    package_manager "git curl build-essential nodejs npm ripgrep fd-find" "true"
    package_manager "clangd rustc cargo" "true"
    
    # Node.js neovim package
    echo "Installing Node.js neovim package..."
    npm install -g neovim
    
    # Python neovim package
    echo "Installing Python neovim package..."
    pip3 install --user --upgrade pynvim
    
    # Optional: Verilog/VHDL LSP support
    echo "Installing HDL support..."
    package_manager "verible" "true" 2>/dev/null || echo "Verible not available in package manager"
    pip3 install --user hdl-checker 2>/dev/null || echo "HDL checker installation failed"
}

function setup_bash_aliases()
{
    echo "Setting up bash aliases..."
    
    if ! grep -q "alias vim=nvim" ~/.bashrc; then
        echo 'alias vim=nvim' >> ~/.bashrc
        echo 'alias vi=nvim' >> ~/.bashrc
        echo 'export EDITOR=nvim' >> ~/.bashrc
        echo 'export VISUAL=nvim' >> ~/.bashrc
        echo "Bash aliases added. Run 'source ~/.bashrc' to activate."
    else
        echo "Bash aliases already exist."
    fi
}

function get_nvim_config()
{
    local ownerName="HarrisonStokes"
    local repoName="Personal_Configs"
    local githubLink="https://github.com/$ownerName/$repoName/archive/refs/heads/main.zip"

    echo "Downloading NeoVim configuration..."
    wget "$githubLink" -O main.zip
    
    if [[ $? -ne 0 ]]; then
        echo -e "$boldRedFg FAILED$reset: Config download failed!"
        return 1
    fi
    
    unzip -q main.zip
    
    extractedFolder=$(ls -d ${repoName}-*/ | head -1)
    extractedFolder=${extractedFolder%/}

    if [[ -d "$extractedFolder/nvim" ]]; then
        echo "Moving NeoVim configuration to ~/.config/"
        mv "$extractedFolder/nvim" ~/.config/
    else
        echo "Warning: nvim folder not found in extracted repo"
        ls -la "$extractedFolder/"
    fi

    rm -rf main.zip
    rm -rf "$extractedFolder"
}

function main()
{
    echo "Setting up NVIM..."
    echo "=================="
    
    clear_previous_nvim
    sleep 2.5

    get_pkgs
    sleep 2.5
    
    download_nvim
    sleep 2.5

    get_dependencies
    sleep 2.5

    get_nvim_config
    sleep 2.5

    setup_bash_aliases
    sleep 2.5

    remove_pkgs
    sleep 2.5
    
    echo ""
    echo "Setup complete! Next steps:"
    echo "1. Run 'source ~/.bashrc' to activate aliases"
    echo "2. Start nvim and let plugins install automatically"
    echo "3. Run ':checkhealth' in nvim to verify everything works"
    echo ""
    echo "Starting nvim now..."
    sleep 5 

    nvim 
    
    echo -e "$boldGreenFg SUCCESS$reset"
    exit 0
}

main "$@
