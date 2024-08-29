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

# Step 2: Install Docker (if not installed)
if ! [ -x "$(command -v docker)" ]; then
    sudo apt-get install -y docker.io
fi

docker -v

# Step 3: Install Docker Compose (if not installed)
if ! [ -x "$(command -v docker-compose)" ]; then
    sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d '\"' -f 4)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

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
if docker-compose ps | grep -q "task_node"; then
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