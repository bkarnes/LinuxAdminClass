#! /bin/bash

#################################################################################
## initialscript.sh
## Usage: ./initialscript.sh
## Requirements:
##    None
##
#################################################################################

# Change the kali user password:
echo "Changing the current user's password ($(whoami)):"
passwd

# Add a new user:
sudo adduser <USERNAME>  # <-- Change the user name here
sudo usermod -aG sudo <USERNAME>   # <-- Change the user name here

# Update the apt cache:
sudo apt update

# Install rsyslog:
sudo apt install -y rsyslog terminator

# Let's add the update script to the scripts directory:
# First, test to make sure the directory isn't already there:
if [ ! -d scripts ]; then
	#mkdir ~/scripts
	mkdir scripts
fi

#echo -e "#! /bin/bash\n\n\nsudo apt update\nsudo apt upgrade\nsudo apt dist-upgrade\nsudo apt auto-remove" > scripts/updatescript.sh && chmod u+x scripts/updatescript.sh
echo -e "#! /bin/bash\n\n\nwhoami" > scripts/whoamiscript.sh && chmod u+x scripts/whoamiscript.sh
echo
echo

# Now, we can update the VM:
# NOTE: THIS CAN TAKE A LONG TIME TO COMPLETE!
#./scripts/updatescript.sh
echo "Running the script."
./scripts/whoamiscript.sh
echo
echo

# Set up the logging of our commands:
echo "Adding the logging info to the /etc/rsyslog.d directory:"
sudo cp bash.conf /etc/rsyslog.d/
echo
echo

# Add the information into the current logged in user's .bashrc file:
echo "Adding the logging info to the current user's account:"
sudo cat zshrc_update.conf >> ~/.zshrc
source ~/.zshrc
echo "Done."
echo
echo

# Add the information into the newly added user's .bashrc file:
echo "Adding the logging stuff to the new user's account:"
sudo cp ~/.zshrc /home/<USERNAME>/.zshrc
echo "Done."

echo "Need to restart the VM."
#sudo reboot
# Restart the rsyslog service:
sudo systemctl restart rsyslog
