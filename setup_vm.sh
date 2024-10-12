#################################################################################
## setup_vm.sh
## Usage: ./setup_vm.sh
## Requirements:
##    None
##
#################################################################################

# Change the kali user password:
# Commenting this out for now, will show how to change password manually.
#echo "Changing the current user's password ($(whoami)):"
#passwd

# Update the apt cache:
echo "Updating the APT Cache:"
sudo apt update
echo "Done."
echo

# Install rsyslog and other tools:
echo "Installing some tools:"
sudo apt install -y rsyslog terminator cherrytree tmux screen golang libpcap-dev massdns flatpak python3-venv
echo "Done."

# Let's make some default directories:
# First, the scripts directory.  Test to make sure the directory isn't already there:
#mkdir ~/scripts
if [ -d "~/scripts" ]; then
    echo "~/scripts Directory exists. Skipping."
else
    echo "Creating the ~/scripts directory."
    mkdir ~/scripts
fi

# Next, add to the Downloads directory:
#mkdir -p ~/Downloads/Software

if [ -d "~/Downloads/Software" ]; then
    echo "~/Downloads/Software Directory exists. Skipping."
else
    echo "Creating the ~/Downloads/Software directory."
    mkdir -p ~/Downloads/Software
fi

# Next, the tools directory.  Test to make sure the directory isn't already there:
#mkdir ~/tools

if [ -d "~/tools" ]; then
    echo "~/tools Directory exists. Skipping."
else
    echo "Creating the ~/tools directory."
    mkdir ~/tools
fi

# Add the update script to the ~/scripts directory:
echo "#! /bin/bash\n\n\nsudo apt update\nsudo apt upgrade\nsudo apt dist-upgrade\nsudo apt auto-remove" > ~/scripts/updatescript.sh && chmod u+x ~/scripts/updatescript.sh
echo "#! /bin/bash\n\n\nwhoami" > ~/scripts/whoamiscript.sh && chmod u+x ~/scripts/whoamiscript.sh
echo
echo

# Now, we can update the VM:
# NOTE: THIS CAN TAKE A LONG TIME TO COMPLETE!
#~/scripts/updatescript.sh
echo "Running the script."
~/scripts/whoamiscript.sh
echo
echo

################################################################################
## Set up CLI Logging for the system:
################################################################################

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

################################################################################
## Set up Docker:
################################################################################

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bullseye stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose docker-compose-plugin

################################################################################
## Set up a new secondary user:
################################################################################

echo "Setting up the secondary user:"
echo $1

# Add a new secondary user:
sudo adduser $(echo $1)  # <-- Change the user name here
sudo adduser $(echo $1) sudo # <-- Change the user name here

# Let's make some default directories for the new user:
# First, the scripts directory.  Test to make sure the directory isn't already there:
sudo mkdir /home/$(echo $1)/scripts
sudo chown $(echo $1):$(echo $1) /home/$(echo $1)/scripts

# Next, the Projects directory.  Test to make sure the directory isn't already there:
sudo mkdir /home/$(echo $1)/Projects
sudo chown $(echo $1):$(echo $1) /home/$(echo $1)/Projects

# Next, the tools directory.  Test to make sure the directory isn't already there:
sudo mkdir /home/$(echo $1)/tools
sudo chown $(echo $1):$(echo $1) /home/$(echo $1)/tools

# Finished.
echo "Finished setting up the VM for the first time. Please restart the VM."
#sudo reboot
