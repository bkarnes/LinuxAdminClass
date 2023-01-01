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
sudo adduser dude  # <-- Change the user name here
sudo usermod -aG sudo dude   # <-- Change the user name here

# Update the apt cache:
sudo apt update

# Install rsyslog:
sudo apt install -y rsyslog

# Let's add the update script to the scripts directory:
# First, test to make sure the directory isn't already there:
if [ ! -d scripts ]; then
	#mkdir ~/scripts
	mkdir scripts
fi

cd scripts
#echo -e "#! /bin/bash\n\n\nsudo apt update\nsudo apt upgrade\nsudo apt dist-upgrade\nsudo apt auto-remove" > updatescript.sh && chmod u+x updatescript.sh
echo -e "#! /bin/bash\n\n\nwhoami" > whoamiscript.sh && chmod u+x whoamiscript.sh
echo
echo

# Now, we can update the VM:
# NOTE: THIS CAN TAKE A LONG TIME TO COMPLETE!
#./updatescript.sh
echo "Running the script."
./scripts/whoamiscript.sh
echo
echo

# Set up the logging of our commands:
#sudo echo "local6.*	/var/log/commands.log" > /etc/rsyslog.d/bash.conf
echo "Adding the logging info to the /etc/rsyslog.d directory:"
sudo cp bash.conf /etc/rsyslog.d/
echo
echo

# Add the information into the current logged in user's .bashrc file:
#echo "export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug \"$(history 1 | sed \"s/^[ ]*[0-9]\+[ ]*//\" )\"'" >> ~/.bashrc
echo "Adding the logging info to the current user's account:"
sudo cat zshrc_update.conf >> ~/.zshrc
#source ~/.zshrc
echo "Done."
echo
echo

# Add the information into the newly added user's .bashrc file:
echo "Adding the logging stuff to the new user's account:"
#sudo echo "export PROMPT_COMMAND='RETRN_VAL=$?;logger -p local6.debug \"$(history 1 | sed \"s/^[ ]*[0-9]\+[ ]*//\" )\"'" >> /home/dude/.bashrc
sudo cp ~/.zshrc /home/dude/.zshrc
echo "Done."

echo "Need to restart the VM."
sudo reboot
# Restart the rsyslog service:
#sudo systemctl restart rsyslog
