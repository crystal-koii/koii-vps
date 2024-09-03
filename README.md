# koii-vps

# Hardware requirements
Minimal Setup: A system with a 1+ GHz processor, 2 GB of RAM, and 10 GB of SSD storage meets the minimum requirements. Ensure a stable internet connection and use a 64-bit Linux distribution like Ubuntu 24.04 LTS for running the Koii Node.

Recommended Setup: For running multiple tasks, it's recommended to use a system with a 2+ GHz multi-core processor, 8 GB of RAM, and 30 GB of SSD storage. Ensure a stable internet connection with at least 10 Mbps upload/download speeds, and use a 64-bit Linux distribution like Ubuntu 24.04 LTS for optimal performance.

# To run Koii Node on a VPS overview

0. Have a VPS that has enough memory + cpu
1. SSH into your vps 
2. Clone this repo
3. cd into folder
4. Make script executable and run it.
    ```
    chmod +x setupServer.sh
    sudo ./setupServer.sh
    ```
5. Read through the script comments first to understand what will happen.
6. Follow along with script
7. Do manual steps and rerun the script at certain points. 
8. Check that it's running 
9. Enjoy!

# Steps you need to do, prompted in script:
1. When koii-cli is installed it will ask you if you updated the path, just copy the line starting with PATH that is printed in your terminal and paste it in. Then rerun the script.
    ```
    EXAMPLE - Please use what is in your terminal
    Please update your PATH environment variable to include the koii programs:
        PATH="/home/ubuntu/.local/share/koii/install/active_release/bin:$PATH"
    ```
2. When the public key and seed phrase are printed, save them you'll need them later. 
3. When prompted: "Please take a moment to fill your new wallet with enough koii to run the tasks." You need to copy the public key and use Finnie to fund your wallet before pressing y to continue.


# To claim rewards etc:
https://www.koii.network/docs/develop/command-line-tool/create-task-cli/install
```npx @_koii/create-task-cli@latest```

Only commands you'll need:
1.Claim Reward (If you have rewards)
2.Withdraw Staked Funds from Task (If you don't want to run the task anymore)
