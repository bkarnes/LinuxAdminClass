#! /bin/bash

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
sudo apt update

# Install rsyslog:
sudo apt install -y rsyslog terminator cherrytree tmux screen

# Let's make some default directories:
# First, the scripts directory.  Test to make sure the directory isn't already there:
mkdir ~/scripts

# Next, add to the Downloads directory:
mkdir -p ~/Downloads/Software

# Next, the tools directory.  Test to make sure the directory isn't already there:
mkdir ~/tools

echo -e "#! /bin/bash\n\n\nsudo apt update\nsudo apt upgrade\nsudo apt dist-upgrade\nsudo apt auto-remove" > ~/scripts/updatescript.sh && chmod u+x ~/scripts/updatescript.sh
echo -e "#! /bin/bash\n\n\nwhoami" > ~/scripts/whoamiscript.sh && chmod u+x ~/scripts/whoamiscript.sh
echo
echo

# Now, we can update the VM:
# NOTE: THIS CAN TAKE A LONG TIME TO COMPLETE!
#./scripts/updatescript.sh
echo "Running the script."
~/scripts/whoamiscript.sh
echo
echo

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

# Add a new secondary user:
sudo adduser <USERNAME> --shell /usr/bin/zsh  # <-- Change the user name here
sudo adduser <USERNAME> sudo # <-- Change the user name here

# Let's make some default directories for the new user:
# First, the scripts directory.  Test to make sure the directory isn't already there:
sudo mkdir /home/<USERNAME>/scripts
sudo chown <USERNAME>:<USERNAME> /home/<USERNAME>/scripts

# Next, the Projects directory.  Test to make sure the directory isn't already there:
sudo mkdir /home/<USERNAME>/Projects
sudo chown <USERNAME>:<USERNAME> /home/<USERNAME>/Projects

# Next, the tools directory.  Test to make sure the directory isn't already there:
sudo mkdir /home/<USERNAME>/tools
sudo chown <USERNAME>:<USERNAME> /home/<USERNAME>/tools

# Finished.
echo "Finished setting up the VM for the first time. Please restart the VM."
#sudo reboot
