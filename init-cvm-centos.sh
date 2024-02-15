#!/usr/bin/env bash

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -t, --tools       Install basic tools (vim, tree, curl, git, net-tools, expect, unzip, lsof, rsync)"
    echo "  -n, --nodejs      Install Node.js and npm, and globally install pm2 and yarn"
    echo "  -j, --java        Install Java (JDK 17.0.9)"
    echo "  -g, --go          Install Go (Golang 1.17.5)"
    echo "  -v, --vim         Initialize Vim configuration"
    echo "  -p, --python      Initialize Python(3.9.6)"
    echo "  -d, --docker      Initialize Docker"
    echo "  -h, --help        Show this help message"
    echo
    echo "Examples:"
    echo "  $0 -t              # Install basic tools"
    echo "  $0 -n              # Install Node.js and npm"
    echo "  $0 -j              # Install Java"
    echo "  $0 -p              # Install Python"
    echo "  $0 -d              # Install Docker"
    echo "  $0 -g              # Install Go"
    echo "  $0 -t -n           # Install basic tools and Node.js"
    exit 1
}

install_python(){
  yum groupinstall "Development Tools";
  yum install -y git gcc make openssl-devel bzip2-devel libffi-devel zlib-devel readline-devel sqlite-devel;
  # sudo yum install gcc openssl-devel bzip2-devel libffi-devel zlib-devel
  wget https://www.python.org/ftp/python/3.9.6/Python-3.9.6.tgz;
  tar -xvf Python-3.9.6.tgz;
  cd Python-3.9.6;
  ./configure --enable-optimizations;
  sudo make;
  sudo make altinstall;
  python3.9 --version;
}

install_tools() {
    echo "Installing basic tools..."
    yum install -y vim tree curl git net-tools expect unzip lsof rsync jq htop
    echo "Basic tools installation finished."
}

install_nodejs() {
    echo "Installing Node.js and npm..."
    sudo yum install https://rpm.nodesource.com/pub_20.x/nodistro/repo/nodesource-release-nodistro-1.noarch.rpm -y
    sudo yum install nodejs -y --setopt=nodesource-nodejs.module_hotfixes=1
    npm install -g pm2
    npm install -g yarn
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
    echo "Installing Java..."
    # Download JDK RPM package
#    JDK_RPM="jdk-17.0.9_linux-aarch64_bin.rpm"
    JDK_RPM="jdk-17.0.9_linux-x64_bin.rpm"

    # Check if JDK RPM file already exists
    if [ ! -f "$JDK_RPM" ]; then
        # Download JDK RPM package
        wget -O $JDK_RPM https://download.oracle.com/java/17/archive/$JDK_RPM
    else
        echo "JDK RPM file already exists. Skipping download."
    fi

    # Install JDK from RPM package
    sudo rpm -i $JDK_RPM
    # Check Java version
    java -version
    echo "Java installation finished."
}


initialize_vim() {
    echo "Initializing Vim configuration..."

    # Create or edit Vim configuration file
    vim_config_file="$HOME/.vimrc"

    if [ -f "$vim_config_file" ]; then
        # If the file already exists, append or update settings
        echo "set encoding=utf-8" >> "$vim_config_file"
        echo "set nu" >> "$vim_config_file"
        echo "Vim configuration updated."
    else
        # If the file doesn't exist, create and add settings
        echo "set encoding=utf-8" > "$vim_config_file"
        echo "set nu" >> "$vim_config_file"
        echo "Vim configuration created."
    fi

    echo "Vim initialization finished."
}

install_docker(){
  sudo yum install -y yum-utils
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

install_go() {
    echo "Installing Go..."
    wget https://golang.org/dl/go1.17.5.linux-amd64.tar.gz
    rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.5.linux-amd64.tar.gz

    export_line='export PATH=$PATH:/usr/local/go/bin'

    add_to_profile "$export_line" ~/.bashrc
    add_to_profile "$export_line" ~/.bash_profile

    echo "Go installation finished."
    go version
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
            exit 1  # 直接退出脚本，不再执行后续逻辑
            ;;
    esac
    shift
done

# 这里不再判断是否有参数，而是直接执行 usage 函数
usage