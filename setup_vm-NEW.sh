#! /bin/bash

###############################################################
## Our main bash script file:
## 
## to use: ./main.sh
## 
#############################################################

## Some basic varibles:
timeofday=$(date)
GREEN="\033[1;32m"
RED="\033[1;31m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
NC="\033[0m"
export GREEN
export RED
export BLUE
export YELLOW
export NC

#############################################################
## Create the Banner to be used everywhere:
#############################################################
function banner(){
#echo "${GREEN}
echo "
 ___     ___ __    _ __   __ __   __                         
|   |   |   |  |  | |  | |  |  |_|  |                        
|   |   |   |   |_| |  | |  |       |                        
|   |   |   |       |  |_|  |       |                        
|   |___|   |  _    |       ||     |                         
|       |   | | |   |       |   _   |                        
|_______|___|_|_ |__|_______|__| |__|__  __   __ ___ __    _ 
|       |  | |  |       |   _   |      ||  |_|  |   |  |  | |
|  _____|  |_|  |  _____|  |_|  |  _    |       |   |   |_| |
| |_____|       | |_____|       | | |   |       |   |       |
|_____  |_     _|_____  |       | |_|   |       |   |  _    |
 _____| | |   |  _____| |   _   |       | ||_|| |   | | |   |
|_______|_|___| |_______|__|_|__|______||_|   |_|___|_|  |__|
|       |   |   |   _   |       |       |                    
|       |   |   |  |_|  |  _____|  _____|                    
|       |   |   |       | |_____| |_____                     
|      _|   |___|       |_____  |_____  |                    
|     |_|       |   _   |_____| |_____| |                    
|_______|_______|__| |__|_______|_______|                    
"
}
#############################################################

#############################################################
## Setting up CLI Logging:
#############################################################
function cli-logging(){

    # Change the kali user's shell to BASH
    chsh -s /bin/bash

    # Update the apt cache:
    echo "Updating the APT Cache:"
    sudo apt update
    echo "Done."
    echo

    # Install rsyslog and other tools:
    echo "Installing rsyslog and some tools:"
    sudo apt install -y rsyslog golang
    echo "Done."
    
    # Set up the logging of our commands:
    echo "Adding the logging info to the /etc/rsyslog.d directory:"
    echo "Working Directory: $(pwd)"
    sudo cp configs/bash.conf /etc/rsyslog.d/
    echo
    echo

    # Add the logging information into the current logged in user's .zshrc file:
    echo "Adding the logging info to the current user's account:"
    echo "Working Directory: $(pwd)"
    sudo cat configs/zshrc_update.conf >> ~/.zshrc
    sudo cat configs/bashrc_update.conf >> ~/.bashrc
    #source ~/.zshrc
    echo "Done."
    echo
    echo

    # Add the config information into the /etc/skel .zshrc and .bashrc files:
    echo "Updating the /etc/skel files:"
    echo "Working Directory: $(pwd)"
    sudo cp configs/zshrc_updates.dist /etc/skel/.zshrc
    sudo cp configs/bashrc_updates.dist /etc/skel/.bashrc
    echo "Done."
    
    # Restart the rsyslog service:
    sudo systemctl restart rsyslog
    
    # Finished.
    echo "Finished setting up the CLI Logging. For best results, please restart the VM."
}
#############################################################

##################################################################################
## Install extra tools:
##################################################################################
function extra-tools(){
    # Install rsyslog and other tools:
    echo "Installing some extra tools:"
    sudo apt update
    sudo apt install -y terminator cherrytree tmux screen libpcap-dev massdns flatpak python3-venv
    echo "Done."
}

##################################################################################
## Install Docker:
##################################################################################
function install-docker(){
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bullseye stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update the APT Cache:
    sudo apt-get update
    
    # Install docker and docker-compose components:
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose docker-compose-plugin

    # Set the current user to run docker with root previlages:
    echo "Adding the current user to the docker group."
    sudo adduser $USER docker
    echo "$USER has been added to the docker group.  You will need to log out and back in again or restart the VM."
    #sudo reboot
}

##################################################################################
## Install initial directories:
##################################################################################
function install-directories(){
    # Let's make some default directories:
    # First, the scripts directory.  Test to make sure the directory isn't already there:
    if [ -d "~/scripts" ]; then
        echo "~/scripts Directory exists. Skipping."
    else
        echo "Creating the ~/scripts directory."
        mkdir ~/scripts
    fi

    # Next, add to the Downloads directory.  Test to make sure the directory isn't already there:
    if [ -d "~/Downloads/Software" ]; then
        echo "~/Downloads/Software Directory exists. Skipping."
    else
        echo "Creating the ~/Downloads/Software directory."
        mkdir -p ~/Downloads/Software
    fi

    # Next, the tools directory.  Test to make sure the directory isn't already there:
    if [ -d "~/tools" ]; then
        echo "~/tools Directory exists. Skipping."
    else
        echo "Creating the ~/tools directory."
        mkdir ~/tools
    fi
    
    # Add the update script to the ~/scripts directory:
    echo -e "#! /bin/bash\n\n\nsudo apt update\nsudo apt upgrade\nsudo apt dist-upgrade\nsudo apt auto-remove" > ~/scripts/update.sh && chmod u+x ~/scripts/update.sh
    echo -e "#! /bin/bash\n\n\nwhoami" > ~/scripts/whoamiscript.sh && chmod u+x ~/scripts/whoamiscript.sh
    echo
    echo
    
    # Let the user know you are finished:
    echo
    echo "Done."
}

##################################################################################
## Update VM:
##################################################################################
function update-vm(){
    echo "Starting the update script"
    ~/scripts/update.sh
    echo "Done"
}

##################################################################################
## Who am I?:
##################################################################################
function who-am-i(){
    echo "Who am I?"
    ~/scripts/whoamiscript.sh
}

##################################################################################
## Add a user:
##################################################################################
function add-secondary-user(){
    echo "Setting up a new user:"
    echo "What is the New User's name?"
    read newuser

    # Add a new secondary user:
    sudo adduser $newuser  # <-- Change the user name here
    sudo adduser $newuser sudo # <-- Change the user name here

    # Let's make some default directories for the new user:

    # First, the scripts directory.  Test to make sure the directory isn't already there:
    if [ -d "/home/${newuser}/scripts" ]; then
        echo "/home/${newuser}/scripts Directory exists. Skipping."
    else
        echo "Creating the /home/${newuser}/scripts directory."
        sudo mkdir /home/${newuser}/scripts
    fi
    
    # Add the update script to the new user's  ~/scripts directory:
    echo -e "#! /bin/bash\n\n\nsudo apt update\nsudo apt upgrade\nsudo apt dist-upgrade\nsudo apt auto-remove" > /home/${newuser}/scripts/update.sh && chmod u+x /home/${newuser}/scripts/update.sh
    echo -e "#! /bin/bash\n\n\nwhoami" > /home/${newuser}/scripts/whoamiscript.sh && chmod u+x /home/${newuser}/scripts/whoamiscript.sh

    # Next, add to the Projects directory.  Test to make sure the directory isn't already there:
    if [ -d "/home/${newuser}/Projects" ]; then
        echo "/home/${newuser}/Projects Directory exists. Skipping."
    else
        echo "Creating the /home/${newuser}/Projects directory."
        sudo mkdir /home/${newuser}/Projects
    fi

    # Next, the tools directory.  Test to make sure the directory isn't already there:
    if [ -d "/home/${newuser}/tools" ]; then
        echo "/home/${newuser}/tools Directory exists. Skipping."
    else
        echo "Creating the /home/${newuser}/tools directory."
        sudo mkdir /home/${newuser}/tools
    fi

    sudo chown -R ${newuser}:${newuser} /home/${newuser}/*

}

##################################################################################
## Set up Black Hat Bash docker images:
##################################################################################
function blackhat-bash(){
    echo "This is where the Black Hat Bash docker pull will go."
}

##################################################################################
## Install Netbird client:
##################################################################################
function install-netbird(){
    echo "This is where we install netbird client."
    #curl -fsSL https://pkgs.netbird.io/install.sh | sh
    
    # Add the repository:
    sudo apt-get update
    sudo apt install ca-certificates curl gnupg -y
    curl -sSL https://pkgs.netbird.io/debian/public.key | sudo gpg --dearmor --output /usr/share/keyrings/netbird-archive-keyring.gpg
    echo 'deb [signed-by=/usr/share/keyrings/netbird-archive-keyring.gpg] https://pkgs.netbird.io/debian stable main' | sudo tee /etc/apt/sources.list.d/netbird.list

    # Update first:
    sudo apt-get update

    # Install the Clientl
    sudo apt-get install netbird netbird-ui

    echo "Done.  Netbird is installed."
}

##################################################################################
## Set up SecureWV 15 CTF:
##################################################################################
function securewv-15-ctf(){
    #echo "This is where the CTF setup will go."
    
    # Pull the JuiceShop Docer image down:
    echo "Pulling the latest JuiceShop Docker image."
    docker pull bkimminich/juice-shop
    echo "Done."
    echo
    
    # Pull the zip file from my server."
    echo "Pulling the zip file from the server."
    if [ -e ~/Projects/SecureWV-CTF.zip ]; then
        echo "Zip file has already been pulled down. Skipping."
    else
        echo "Zip file does not exist, pulling it down."
        cd ~/Projects/
        wget https://ethicalhacker.quest/sv15-ctf/SecureWV-CTF.zip
    fi
    
    # Do we need to unzip the file?
    if [ -d "SecureWV-CTF" ]; then
        echo "the SecureWV-CTF directory exists. Skipping."
    else
        echo "Unzipping the file."
        # Ask for the password:
        echo "What is the password for the zip file?"
        read mypass

        # unzip file
        unzip -P $mypass SecureWV-CTF.zip
    
        # Change to the Directory and move things around.
        cd ~/Projects/SecureWV-CTF
        cp CTF_bash_aliases ~/.bash_aliases
        chmod u+x startjuiceshop.sh
        source ~/.bash_aliases
    fi
    
    echo "Finished setting up the CTF for SecureWV 15."

}

#############################################################
## Start WhileLoop for Menu:
#############################################################
while true
do
    clear
    banner
    echo
    echo " Today is: $timeofday"
    echo " What can I do for you today?"
    echo
    echo " 1) Setup CLI logging.  Will require a reboot."
    echo " 2) Setup Directories"
    echo " 3) Update VM.  Will require a reboot."
    echo " 4) Install extra tools"
    echo " 5) Install Docker.  Will require a reboot."
    echo " 6) Install netbird client."
    echo " 7) Set up SecureWV 15 CTF"
    echo " 8) Set up Black Hat Bash docker images"
    echo " 9) Add a user"
    echo " (Q)uit"
    read choice
    
    case $choice in
    	[1])
    	    cli-logging
    	    ;;
    	[2])
    	    install-directories
    	    ;;
	[3])
            update-vm
            ;;
	[4])
            extra-tools
            ;;
	[5])
            install-docker
            ;;
	[6])
            install-netbird
            ;;
	[7])
            securewv-15-ctf
            ;;
	[8])
            blackhat-bash
            ;;
	[9])
            add-secondary-user
            ;;
    	[Qq])
  	    echo
    	    echo "Have a nice day."
    	    echo 
    	    exit;;
    	*)
    	    echo "Incorrect Choice.  Please try again."
    	    ;;
    esac
    echo
    echo -e "Enter return to continue...."
    read answer
done
