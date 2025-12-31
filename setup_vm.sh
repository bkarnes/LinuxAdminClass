#! /bin/bash

##################################################################################
## Our main bash script file:
## 
## to use: ./setup_vm-NEW.sh
## 
##################################################################################

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

##################################################################################
## Create the Banner to be used everywhere:
##################################################################################
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
##################################################################################

##################################################################################
## Setting up CLI Logging:
##################################################################################
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
    sudo apt install -y rsyslog golang terminator cherrytree tmux screen libpcap-dev massdns flatpak python3-venv
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
    echo "Finished setting up the CLI Logging. Now, let's set up the default directories."
    
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
    echo -e "#! /bin/bash\n\n\nsudo apt update\nsudo apt upgrade -y\nsudo apt dist-upgrade -y\nsudo apt auto-remove -y" > ~/scripts/update.sh && chmod u+x ~/scripts/update.sh
    echo -e "#! /bin/bash\n\n\nwhoami" > ~/scripts/whoamiscript.sh && chmod u+x ~/scripts/whoamiscript.sh
    echo
    echo
    
    # Let the user know you are finished:
    #echo
    #echo "Done. Please restart the VM."
    
    # Reboot the VM:
    echo "Done. Will now reboot."
    sleep 5
    sudo reboot
}

##################################################################################
## Update VM:
##################################################################################
function update-vm(){
    echo "Starting the update script"
    ~/scripts/update.sh
    #echo "Done"
    
    # Reboot the VM:
    echo "Done. Will now reboot."
    sleep 5
    sudo reboot
}

##################################################################################
## Install Docker (Now using Podman):
##################################################################################
function install-docker(){
   # Remove Podman:
   sudo apt remove podman -y && sudo apt purge podman -y
   
   # Test to make sure Docker isn't already on the system:
   if command -v docker &> /dev/null; then
       echo "Docker is already installed, skipping installation."
   else
      echo "Docker is not installed, installing it now."
      
      # Add the docker apt source
      printf '%s\n' "deb https://download.docker.com/linux/debian bullseye stable" | sudo tee /etc/apt/sources.list.d/docker-ce.list

	  # Next, let's download and import the gpg key
      curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-ce-archive-keyring.gpg

      # Update the APT Cache:
      sudo apt-get update
    
      # Install docker and docker-compose components:
      #sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose docker-compose-plugin
      sudo apt install docker-ce docker-ce-cli containerd.io -y
      
      # Start Docker:
      sudo service docker start
   fi

    # Set the current user to run docker with root previlages:
    echo "Adding the current user to the docker group."
    sudo adduser $USER docker
    echo "$USER has been added to the docker group.  You will need to log out and back in again or restart the VM."
    echo -e "\n# Setting the docker socket:\nexport DOCKER_HOST=unix:///var/run/docker.sock" >> ~/.bashrc
    #sudo reboot
    
    # Reboot the VM:
    echo "Done. Will now reboot."
    sleep 5
    sudo reboot
}

##################################################################################
##  Add a user:
##################################################################################
add-secondary-user() {
    echo "Before setting up a new user, we need to update the kali user:"
    passwd

    echo "Setting up a new user:"
    read -rp "What is the New User's name? " newuser
    # Ensure we have a name
    if [[ -z $newuser ]]; then
        echo "User name cannot be empty." >&2
        return 1
    fi

    # Add the user (creates /home/$newuser automatically)
    sudo adduser "$newuser"
    # Add the user to the sudo group
    #sudo usermod -aG sudo "$newuser"
    sudo adduser $newuser sudo

    # Base directories
    for dir in Desktop Documents Downloads Music Pictures Projects Public scripts Templates tools Videos; do
        target="/home/${newuser}/${dir}"
        if [[ -d $target ]]; then
            echo "$target already exists. Skipping."
        else
            echo "Creating $target."
            sudo mkdir -p "$target"
        fi
    done

    # Create the update.sh script
    cat <<'EOF' | sudo tee "/home/${newuser}/scripts/update.sh" > /dev/null
#!/bin/bash

sudo apt update
sudo apt upgrade
sudo apt dist-upgrade
sudo apt autoremove
EOF
    sudo chmod u+x "/home/${newuser}/scripts/update.sh"

    # Create the whoami script
    cat <<'EOF' | sudo tee "/home/${newuser}/scripts/whoamiscript.sh" > /dev/null
#!/bin/bash

whoami
EOF
    sudo chmod u+x "/home/${newuser}/scripts/whoamiscript.sh"

    # Copy over the LinuxAdminClass dir from Kali to new user:
    sudo cp -r ~/Projects/LinuxAdminClass/ "/home/${newuser}/Projects/"

    # Own the whole home directory
    sudo chown -R "${newuser}:${newuser}" "/home/${newuser}"
    
    # Lock the kali user for after reboot:
    sudo passwd -l kali
    echo
    echo "You will not be able to log in as the Kali user after this."
    
    # Reboot the VM:
    echo "Done. Will now reboot."
    sleep 10
    sudo reboot
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

    #echo "Done.  Netbird is installed."
    
    # Reboot the VM:
    echo "Done. Will now reboot."
    sleep 5
    sudo reboot
}

##################################################################################
## Set up OWASP JuiceShop:
##################################################################################
function owasp_juiceshop(){
    #echo "This is where the CTF setup will go."
    
    # Pull the JuiceShop Docer image down:
    echo "Pulling the latest JuiceShop Docker image."
    docker pull bkimminich/juice-shop
    #podman pull docker.io/bkimminich/juice-shop
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
        cat ~/Projects/SecureWV-CTF/CTF_bash_aliases >> ~/.bash_aliases
        chmod u+x startjuiceshop.sh
        source ~/.bash_aliases
    fi
    
    #echo "Finished setting up the CTF for SecureWV 15."
    echo "Finished setting up the OWASP JuiceShop."

}

##################################################################################
## Set up Black Hat Bash docker images:
##################################################################################
function blackhat-bash(){
    echo "Let's clone the Black Hat Bash Repo for a cool lab."
    cd ~/Projects/
    git clone https://github.com/dolevf/Black-Hat-Bash.git
    
    cd ~/Projects/Black-Hat-Bash/lab
    sudo make deploy

    sudo make teardown
    
echo -e "\n\
# Black-Hat-Bash:
alias rustscan=\"docker run --network=host -it --rm --name rustscan rustscan/rustscan:2.1.1\"\n\
alias gitjacker=\"/home/kali/tools/gitjacker\"\n\
alias bhb_project=\"cd ~/Projects/Black-Hat-Bash/\"\n\
alias bhb_labs=\"cd ~/Projects/Black-Hat-Bash/lab/\"\n\
alias bhb_startlab=\"cd ~/Projects/Black-Hat-Bash/lab/ && docker compose up --detach\"\n\
alias bhb_stoplab=\"cd ~/Projects/Black-Hat-Bash/lab/ && docker compose down --volumes\""\
>> ~/.bash_aliases

# Let the user know that we're done."
echo "We have finished setting up the Black Hat Bash Repo."

}


##################################################################################
## Install Project Discovery tools via PDTM:
##################################################################################
function install-pdtm(){
    echo "Installing PDTM:"
    go install github.com/projectdiscovery/pdtm/cmd/pdtm@latest
    echo
    echo
    echo "Finished install PDTM, Installing all Project Discovery Tools:"
    pdtm -ia
    
echo -e "\n\
# Fix for Project Discovery's HTTPX:\n\
alias httpx=\"~/.pdtm/go/bin/httpx\"\n\
alias otherhttpx=\"/usr/bin/httpx\""\
>> ~/.bash_aliases

    echo
    echo
    echo "PDTM and Project Discovery tools are installed."
}

##################################################################################
## Start WhileLoop for Menu:
##################################################################################
while true
do
    clear
    banner
    echo
    echo " Today is: $timeofday"
    echo " What can I do for you today?"
    echo
    echo " 1) Add a new user.  Will reboot after update."
    echo " 2) Setup CLI logging and default directories.  Will reboot after update."
    echo " 3) Install Docker.  Will reboot after update."
    echo " 4) Install netbird client."
    echo " 5) Set up the OWASP JuiceShop."
    echo " 6) Set up Black Hat Bash docker images.  Will need a reboot."
    echo " 7) Install Project Discovery Tools.  Will need a reboot."
    echo " 8) Update VM.  Will reboot after update."
    echo " (R)eboot"
    echo " (Q)uit"
    read choice
    
    case $choice in
    	[1])
            add-secondary-user
            ;;
    	[2])
    	    cli-logging
    	    ;;
    	[3])
            install-docker
            ;;
    	[4])
            install-netbird
            ;;
    	[5])
            owasp_juiceshop
            ;;
    	[6])
            blackhat-bash
            ;;
    	[7])
            install-pdtm
            ;;
    	[8])
            update-vm
            ;;
        [Rr])
            sudo reboot
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
