# koii-vps

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
5. Follow along with script
6. Check that it's running 
7. Enjoy!

# Steps you need to do, prompted in script:
1. When koii-cli is installed it will ask you if you updated the path, just copy what is printed in terminal and paste it in. Then rerun the script.
    ```
    EXAMPLE - Please use what is in your terminal
    Please update your PATH environment variable to include the koii programs:
        PATH="/home/ubuntu/.local/share/koii/install/active_release/bin:$PATH"
    ```
2. When the public key and seed phrase are printed, save them you'll need them later. 
3. When prompted: "Please take a moment to fill your new wallet with enough koii to run the tasks." You need to copy the public key and use Finnie to fund your wallet before pressing y to continue.