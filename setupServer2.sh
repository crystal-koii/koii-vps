#!/bin/bash

# Function to update and upgrade the system
update_system() {
    UPDATE_MARKER="/var/log/update_done"

    if [ ! -f "$UPDATE_MARKER" ]; then
        echo "Updating and upgrading the system..."
        sudo apt update && sudo apt dist-upgrade -y
        sudo touch "$UPDATE_MARKER"
        echo "System update and upgrade completed."
    else
        echo "System update and upgrade have already been performed."
    fi
}

# Function to install Docker and Docker Compose
install_docker() {
    if ! [ -x "$(command -v docker)" ]; then
        echo "Installing Docker and Docker Compose..."
        for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
            sudo apt-get remove -y $pkg
        done
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        sudo usermod -aG docker $USER
        echo "Docker installed. Log out and log back in, or run 'exec su -l $USER'. Then run the script again and proceed to the next step."
        exit 0  # Stop script execution since logout is required
    else
        echo "Docker is already installed."
    fi
}

# Function to install nvm and Node.js
install_nvm() {
    if [ -z "$NVM_DIR" ]; then
        echo "Installing nvm and Node.js..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
        export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        nvm install 20
    else
        echo "nvm is already installed"
    fi

    # Verify installation
    node -v
    npm -v
}

# Function to install Koii CLI and create a wallet
install_koii() {
    if ! [ -x "$(command -v koii)" ]; then
        echo "Installing Koii CLI..."
        sh -c "$(curl -sSfL https://raw.githubusercontent.com/koii-network/k2-release/master/k2-install-init.sh)"
        echo "If prompted, please update your PATH as shown above."
        read -p "Press 'y' when you're ready to continue: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Exiting script. Please update your PATH and run the script again."
            exit 1
        fi
    else
        echo "Koii CLI is already installed."
    fi

    # Create a new Koii wallet
    if [ ! -f "$HOME/.config/koii/id.json" ]; then
        koii-keygen new --outfile ~/.config/koii/id.json
    else
        echo "Wallet already exists at ~/.config/koii/id.json"
        koii address
    fi
}

# Function to run Docker Compose
run_docker_compose() {
    echo "Running docker compose..."
    if sudo docker compose ps | grep -q "task_node"; then
        echo "Services already running. Re-running Docker Compose may restart them."
        read -p "Do you want to continue? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Skipping Docker Compose step."
        else
            sudo docker compose up -d
        fi
    else
        sudo docker compose up -d
    fi

    # Check if the service is running
    sudo docker logs -f --tail 10 task_node
}

# Prompt the user for which step to start at
echo "Select the step you are on:"
echo "1. Update and upgrade system"
echo "2. Install Docker and Docker Compose"
echo "3. Install nvm and Node.js"
echo "4. Install Koii CLI and create a wallet"
echo "5. Run Docker Compose"
echo "6. Run all steps in order"
read -p "Enter the step number (1-6): " step

case $step in
    1)
        update_system
        ;;
    2)
        install_docker
        ;;
    3)
        install_nvm
        ;;
    4)
        install_koii
        ;;
    5)
        run_docker_compose
        ;;
    6)
        update_system
        install_docker
        install_nvm
        install_koii
        run_docker_compose
        ;;
    *)
        echo "Invalid step number. Exiting."
        exit 1
        ;;
esac

echo "Step $step completed."
