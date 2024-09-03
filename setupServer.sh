#!/bin/bash

# Path to the marker file
UPDATE_MARKER="/var/log/update_done"

# Step 1: Update and upgrade the system, but only if not done before
if [ ! -f "$UPDATE_MARKER" ]; then
    echo "Updating and upgrading the system..."
    sudo apt update && sudo apt dist-upgrade -y
    
    # Create the marker file to indicate the update has been done
    sudo touch "$UPDATE_MARKER"
    echo "System update and upgrade completed. If you need to run the update again, delete the marker file with:"
    echo "sudo rm $UPDATE_MARKER"
else
    echo "System update and upgrade have already been performed. Skipping this step."
    echo "If you want to run the update again, delete the marker file with:"
    echo "sudo rm $UPDATE_MARKER"
fi

# Step 2: Install Docker and Docker Compose (if not installed)
if ! [ -x "$(command -v docker)" ]; then
    # Uninstall conflicting packages
    for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
        sudo apt-get remove -y $pkg
    done

    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update

    # Install Docker and Docker Compose
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Run Docker as non-root
    sudo usermod -aG docker $USER
    echo "Docker is installed. Please log out and log back in or run 'exec su -l $USER' to apply Docker group changes."
    exit 0
fi

echo "Docker version:"
docker -v
echo "Docker compose version:"
docker compose version

# Step 4: Install nvm (if not installed)
if [ -z "$NVM_DIR" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
    export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    nvm install 20
else
    echo "nvm is already installed"
fi

# Step 5: Verify Node.js and npm installation
node -v  # should print `v20.x.x`
npm -v   # should print `10.x.x`

# Step 6: Install the Koii CLI (if not installed)
if ! [ -x "$(command -v koii)" ]; then
    sh -c "$(curl -sSfL https://raw.githubusercontent.com/koii-network/k2-release/master/k2-install-init.sh)"
    
    # Prompt to update PATH if needed
    echo "If prompted, please update your PATH as shown above."
    read -p "Press 'y' if you've updated your PATH and are ready to continue: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Exiting script. Please update your PATH and run the script again."
        exit 1
    fi
else
    echo "Koii CLI is already installed."
fi

# Step 7: Verify Koii CLI installation
koii --version

# Step 9: Create a new Koii wallet (skip if already exists)
if [ ! -f "$HOME/.config/koii/id.json" ]; then
    koii-keygen new --outfile ~/.config/koii/id.json
else
    echo "Wallet already exists at ~/.config/koii/id.json"
    echo "Your public key:"
    koii address
fi

# Step 10: Pause for user to copy wallet path
echo "Please take a moment to copy the wallet path information."
read -p "When you're ready, press 'y' to continue: " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Exiting script. Please run it again when you're ready."
    exit 1
fi

# Step 10: Pause for user to copy wallet path
echo "Please take a moment to fill your new wallet with enough koii to run the tasks."
read -p "When you're ready, press 'y' to continue: " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Exiting script. Please run it again when you're ready."
    exit 1
fi

# Step 12: Run Docker Compose (warn if services already running)
echo "Running docker compose..."
if docker compose ps | grep -q "task_node"; then
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

# Step 13: Wait a few seconds to let the services start
sleep 10

# Step 14: Check if the service is running correctly
sudo docker logs -f --tail 10 task_node