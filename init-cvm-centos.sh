#!/usr/bin/env bash

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -t, --tools       Install basic tools (vim, tree, curl, git, net-tools, expect, unzip, lsof, rsync)"
    echo "  -n, --nodejs      Install Node.js and npm, and globally install pm2 and yarn"
    echo "  -j, --java        Install Java (JDK 17.0.9)"
    echo "  -g, --go          Install Go (Golang 1.17.5)"
    echo "  -h, --help        Show this help message"
    echo
    echo "Examples:"
    echo "  $0 -t              # Install basic tools"
    echo "  $0 -n              # Install Node.js and npm"
    echo "  $0 -j              # Install Java"
    echo "  $0 -g              # Install Go"
    echo "  $0 -t -n           # Install basic tools and Node.js"
    exit 1
}


install_tools() {
    echo "Installing basic tools..."
    yum install -y vim tree curl git net-tools expect unzip lsof rsync
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
    wget https://download.oracle.com/java/17/archive/jdk-17.0.9_linux-aarch64_bin.rpm

    # Install JDK from RPM package
    sudo rpm -i jdk-17.0.9_linux-aarch64_bin.rpm

    # Check Java version
    java -version

    echo "Java installation finished."
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
        -h|--help)
            usage
            ;;
        *)
            echo "Invalid option: $1"
            usage
            ;;
    esac
    shift
done

if [ "$#" -eq 0 ]; then
    usage
fi
