# LinuxAdminClass
This is the main repo for the Linux Admin Class at BridgeValley.

## Download a fresh Kali VM:
[Get Kali - Pre-made VMs](https://www.kali.org/get-kali/#kali-virtual-machines)

Please note that the script is currently only set up for Kali.  I'm working on the Parrot version.

## Setup your VM:
Once you've started your VM in VirtualBox and logged in as the kali user (kali:kali), you will need to run the following commands to get the setup script on your machine.

```
mkdir Projects
cd Projects
git clone https://github.com/bkarnes/LinuxAdminClass.git
cd LinuxAdminClass
chmod u+x setup_vm.sh
./setup_vm.sh
```
This will then open the setup menu (see below):

```
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


 Today is: Wed Dec 31 03:14:38 PM EST 2025
 What can I do for you today?

 1) Setup CLI logging and default directories.  Will require a reboot.
 2) Update VM.  Will require a reboot.
 3) Install Docker.  Will require a reboot.
 4) Install netbird client.
 5) Set up SecureWV 15 CTF
 6) Set up Black Hat Bash docker images.  Will need a reboot.
 7) Install Project Discovery Tools.  Will need a reboot.
 8) Add a user (Optional)
 (R)eboot
 (Q)uit
```

We will be running this script in our class on the first night.
