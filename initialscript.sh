#! /bin/bash

#################################################################################
## initialscript.sh
## Usage: ./initialscript.sh
## Requirements:
##    None
##
#################################################################################

# Change the kali user password:
echo "Changing the current user's password ($(whoami)):" | tee --append initialscript.log
passwd | tee --append initialscript.log

# Add a new user:
sudo adduser <USERNAME> | tee --append initialscript.log  # <-- Change the user name here
sudo usermod -aG sudo <USERNAME> | tee --append initialscript.log  # <-- Change the user name here

# Update the apt cache:
sudo apt update | tee --append initialscript.log

# Install rsyslog:
sudo apt install -y rsyslog terminator | tee --append initialscript.log

# Let's add the update script to the scripts directory:
# First, test to make sure the directory isn't already there:
if [ ! -d scripts ]; then
	#mkdir ~/scripts
	mkdir scripts
fi

#echo -e "#! /bin/bash\n\n\nsudo apt update\nsudo apt upgrade\nsudo apt dist-upgrade\nsudo apt auto-remove" > scripts/updatescript.sh && chmod u+x scripts/updatescript.sh
echo -e "#! /bin/bash\n\n\nwhoami" > scripts/whoamiscript.sh && chmod u+x scripts/whoamiscript.sh | tee --append initialscript.log
echo | tee --append initialscript.log
echo | tee --append initialscript.log

# Now, we can update the VM:
# NOTE: THIS CAN TAKE A LONG TIME TO COMPLETE!
#./scripts/updatescript.sh
echo "Running the script." | tee --append initialscript.log
./scripts/whoamiscript.sh | tee --append initialscript.log
echo | tee --append initialscript.log
echo | tee --append initialscript.log

# Set up the logging of our commands:
echo "Adding the logging info to the /etc/rsyslog.d directory:" | tee --append initialscript.log
sudo cp bash.conf /etc/rsyslog.d/ | tee --append initialscript.log
echo | tee --append initialscript.log
echo | tee --append initialscript.log

# Add the information into the current logged in user's .bashrc file:
echo "Adding the logging info to the current user's account:" | tee --append initialscript.log
sudo cat zshrc_update.conf >> ~/.zshrc | tee --append initialscript.log
#source ~/.zshrc
echo "Done." | tee --append initialscript.log
echo | tee --append initialscript.log
echo | tee --append initialscript.log

# Add the information into the newly added user's .bashrc file:
echo "Adding the logging stuff to the new user's account:" | tee --append initialscript.log
sudo cp ~/.zshrc /home/<USERNAME>/.zshrc | tee --append initialscript.log
echo "Done." | tee --append initialscript.log

echo "Please restart the VM." | tee --append initialscript.log
#sudo reboot
# Restart the rsyslog service:
sudo systemctl restart rsyslog | tee --append initialscript.log
