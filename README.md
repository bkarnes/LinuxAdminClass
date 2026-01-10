# LinuxAdminClass
This is the main repo for my Linux Admin Class at Bridge Valley Community College.

This script will help students set up their Virtual Machines we will be using in class.  Currently, the script is only set up for running on Kali, but I'm working on the Parrot version.

## Download a fresh Kali VM (Windows and Linux):
[Get Kali - Pre-made VMs](https://cdimage.kali.org/kali-2025.4/kali-linux-2025.4-virtualbox-amd64.7z)

## Download the ISO (Mac M-Series Laptops):
If you are using a MacOS Apple Silicon (M-Series) laptop, you will need to download the ISO file and build the VM from it.
[Get Kali - Pre-made VMs](https://cdimage.kali.org/kali-2025.4/kali-linux-2025.4-installer-arm64.iso)

After downloading the ISO installer image, you can follow the [Fresh Kali Install from ISO for Apple Silicon guide](https://ethicalhacker.quest/Fresh_Kali_Install-ISO-AppleSilicon_VirtualBox.pdf) on my web site. 

## Virtual Manager:
During the class, we will be using [VirtualBox](https://www.virtualbox.org/) as our Virtual Manager, but if you already have a Virtual Manager set up, then this script should still work within the Kali VM, but you will need to download the pre-made Kali image for the appropriate Virtual Manager.

## Setup your VM:
Once you've installed VirtualBox and have logged in as the kali user (kali:kali) or built your VM from scratch, you will need to run the following commands to get the setup script on your machine.

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


 Today is: Fri Jan  2 04:49:54 PM EST 2026
 What can I do for you today?

 1) Add a new user.  Will reboot after update.
 2) Setup CLI logging and default directories.  Will reboot after update.
 3) Install Docker.  Will reboot after update.
 4) Install netbird client.
 5) Set up the OWASP JuiceShop.
 6) Set up Black Hat Bash docker images.  Will need a reboot.
 7) Install Project Discovery Tools.  Will need a reboot.
 8) Update VM.  Will reboot after update.
 (R)eboot
 (Q)uit
```

We will be running this script in our class on the first night.
