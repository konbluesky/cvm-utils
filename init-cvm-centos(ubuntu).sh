#!/usr/bin/env bash

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -t, --tools       Install basic tools (vim, tree, curl, git, net-tools, expect, unzip, lsof, rsync, jq, htop)"
    echo "  -n, --nodejs      Install Node.js and npm, and globally install pm2 and yarn"
    echo "  -j, --java        Install OpenJDK 17"
    echo "  -g, --go          Install Go (Golang 1.17.5)"
    echo "  -v, --vim         Initialize Vim configuration"
    echo "  -p, --python      Initialize Python (3.9.6)"
    echo "  -d, --docker      Initialize Docker"
    echo "  -h, --help        Show this help message"
    echo
    echo "Examples:"
    echo "  $0 -t              # Install basic tools"
    echo "  $0 -n              # Install Node.js and npm"
    echo "  $0 -j              # Install OpenJDK 17"
    echo "  $0 -p              # Install Python"
    echo "  $0 -d              # Install Docker"
    echo "  $0 -g              # Install Go"
    echo "  $0 -t -n           # Install basic tools and Node.js"
    exit 1
}

install_python() {
    sudo apt-get update
    sudo apt-get install -y git gcc make libssl-dev libbz2-dev libffi-dev zlib1g-dev libreadline-dev libsqlite3-dev
    wget https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tgz
    tar -xvf Python-3.9.6.tgz
    cd Python-3.9.6
    ./configure --enable-optimizations
    sudo make
    sudo make altinstall
    python3.9 --version
}

install_tools() {
    echo "Installing basic tools..."
    sudo apt-get update
    sudo apt-get install -y vim tree curl git net-tools expect unzip lsof rsync jq htop
    echo "Basic tools installation finished."
}

install_nodejs() {
    echo "Installing Node.js and npm..."
    echo "Installing Node.js https://github.com/nodesource/distributions"
    sudo apt-get update
    sudo apt-get install -y nodejs npm
    sudo npm install -g pm2 yarn
    echo "Node.js and npm installation finished."
    echo "Node.js version: $(node -v)"
}

add_to_profile() {
    local line="$1"
    local profile_file="$2"

    if ! grep -qxF "$line" "$profile_file"; then
        echo "$line" >> "$profile_file"
        source "$profile_file"  # Source the file to apply changes in the current session
    fi
}

install_java() {
    echo "Installing OpenJDK 17..."
#    sudo apt-get install -y openjdk-17-jdk
    wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.deb
    sudo dpkg -i jdk-17_linux-x64_bin.deb
    java -version
    echo "Java installation finished."
}

initialize_vim() {
    echo "Initializing Vim configuration..."
    vim_config_file="$HOME/.vimrc"
    if [ -f "$vim_config_file" ]; then
        echo "set encoding=utf-8" >> "$vim_config_file"
        echo "set nu" >> "$vim_config_file"
        echo "Vim configuration updated."
    else
        echo "set encoding=utf-8" > "$vim_config_file"
        echo "set nu" >> "$vim_config_file"
        echo "Vim configuration created."
    fi
    echo "Vim initialization finished."
}

install_docker() {
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_go() {
    echo "Installing Go..."
    sudo apt-get update
    sudo apt-get install -y golang-1.17
    export_line='export PATH=$PATH:/usr/lib/go-1.17/bin'
    add_to_profile "$export_line" ~/.bashrc
    add_to_profile "$export_line" ~/.bash_profile
    echo "Go installation finished."
    go version
}

function install_bsc_node() {
  wget   $(curl -s https://api.github.com/repos/bnb-chain/bsc/releases/latest |grep browser_ |grep geth_linux |cut -d\" -f4)
  mv geth_linux geth
  chmod -v u+x geth
  wget   $(curl -s https://api.github.com/repos/bnb-chain/bsc/releases/latest |grep browser_ |grep mainnet |cut -d\" -f4)
  unzip mainnet.zip
}


while [ "$#" -gt 0 ]; do
    case "$1" in
        -t|--tools)
            install_tools
            ;;
        -n|--nodejs)
            install_nodejs
            ;;
        -j|--java)
            install_java
            ;;
        -g|--go)
            install_go
            ;;
        -v|--vim)
            initialize_vim
            ;;
        -p|--python)
            install_python
            ;;
        -d|--docker)
            install_docker
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Invalid option: $1"
            usage
            exit 1
            ;;
    esac
    shift
done

usage
