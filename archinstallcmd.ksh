#!/bin/bash

# 1. Open VB with the arch iso
    VB setups to keep

# 2. Check for internet
ping -c 4 google.com

# 3. Setup the server
vim /etc/pacman.d/mirrorlist

# Replace all "Server" with "#Server" and select one which is closer to your location
## India
Server = http://mirror.cse.iitk.ac.in/archlinux/$repo/os/$arch
Server = http://mirrors.piconets.webwerks.in/archlinux-mirror/$repo/os/$arch
Server = https://mirrors.piconets.webwerks.in/archlinux-mirror/$repo/os/$arch

# 4. refresh local data base
pacman -Syy

# 5. Prepare the HDD for partition and install OS
    # To list the block devicies
    lsblk
    -This should list all the devicies avaliable

    # Open gdisk for creating the partition
    gdisk /dev/sda
    
    # create new partation by pressing n
        # chose default for Partition numbrer, First Sector
        # Chose a size ( +512M, +8G, +30G ) for Second sector.
        # chose a correct HEX code for the partition.

    # fist create a Boot partition
        # chose a +512M size
        # chose "EF00" for EFI partition 

    # Second create a root partion
        # chose a size of +30G ( depends on your requirement )
        # chose the default ( 8300 ) linux filesystem
        
    # Third create a home partion.
        # Chose the remaining HDD size
        # chose the default ( 8300 ) linux filesystem

    # Select "w" to write all the changes to the partition table.
    # and press "y" to update the partion table.
#verify with lsblk command.

# 6. Format the disk
 
    #Format boot partition
    mkfs -t fat -F 32 /dev/sda1
    
    # Format root partition
    mkfs -t ext4 /dev/sda2

    # Format home partition
    mkfs -t ext4 /dev/sda3

# 7. Mount the partition

    #Mount the OS partition
    mount /dev/sda2 /mnt 

    # Create couple of folders boot and home
    ### MAKE SURE TO MOUNDT OS PARTITION FIRST BEFORE CREATING THE FOLLOWING DIR ###
    mkdir -p /mnt/boot/efi
    mkdir /mnt/home
    
    # Mount the boot partition
    mount /dev/sda1 /mnt/boot/efi

    # mount the home partition
    mount /dev/sda3 /mnt/home

# 8. Download extract OS
pacstrap /mnt base linux linux-firmware vim nano bash-completion linux-headers base-devel

# 9. Supply OS fstab file to find the partition with the following command.
genfstab -U /mnt >> /mnt/etc/fstab

# 10. Switch into actual ARCH install part
arch-chroot /mnt
# You should the change in the path display in the cmd line.

# 11. Insatll the grub bootloader and other required programs
pacman -S grub efibootmgr efivar networkmanager intel-ucode

# 12. Install GRUB bootloader to disk
grub-install /dev/sda

# 13. Update GRUB config file if needed ( OPTIONAL )
vim /etc/default/grub
# modify grub timeout = 2

# 14. Update the GRUB config file.
grub-mkconfig -o /boot/grub/grub.cfg

# 15. Enable the network manager service.
systemctl enable NetwrokManager

# 16. Change root account password
passwd

# 17.  Exit boot env and come to insatll env.
exit

# 18. Un mount all the partition
umount /mnt/boot/efi
umount /mnt/home
umount /mnt

# 19 . reboot to complete the arch insatll.
reboot

# 20. Login into the new OS with id and pwd

# 21. Check the netwrok and connect the wifi
networkctl list

# 22. To access the netwokr userinterface
nmtui 
# make the necessary modification for the wifi network,
# give name ssid and pwd, save and exit

# 23. To check/show the connection
nmcli connection show
#you should see the wifi connection listed.
# ping google.com to check the connectivity

# 24. Setup hostname
vim /etc/hostname
# add "archvm" into the file.

# 25. Add the loopback address in the host file.
vim /etc/hosts
# add the following
127.0.0.1   localhost
127.0.1.1   archvm

# 26. Change the timezone.
timedatectl set-timezone Asia/Kolkata
# find your time zone in ls /usr/share/zoneinfo 

# 27. Syn the system clk and internet
tumedatectl set-ntp true

# to check the above setup
timedatectl status

# 28. update the system Local
vim /etc/local.gen
# uncomment en_US.*, en_IN* save and exit

# 29. Setup system wide user local
vim /etc/locale.conf
#insert the var "LANG=en_US.UTF.8"

# 30. Update the system local
local-gen

# 31. Setup swap file.
cd /
touch swapfile
dd if=/dev/zero of=swapfile bs=1M count=1000
chmod 600 swapfile
mkswap swapfile
swapon swapfile
#free -m ( to check the swapfile )

# 32. Modifiy the fstab to update the swapfile.
vim /etc/fstab
# add the following at the end of the file
#
#echo "/swapfile     none    swap    sw  0   0" >> /etc/fstab
#
# saave and exit

# 33. Reboot to udpate the system
reboot

# 34. General modification for evey new user ( optional )
cd /etc/skel/
# check for the .bashrc file and open it.
vim .bashrc

# 35. update the .bashrc with the following. 
export EDITOR=vim

alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

[ ! -e ~/.dircolors ] && eval $(dircolors -p > ~/.dircolors)
[ -e /bin/dircolors ] && eval $(dircolors -b ~/.dircolors)

# save and exit the file.

# 36. Copy all the files from skel to root folder.
cp -a . ~
ls -al /root

# 37. logout reboot and logback in.

# 38 . Create standard useraccounts
useradd --create-home usr001
passwd usr001
# 39.  add usr previlages.
usermod -aG wheel,users,storage,power,lp,adm,optical usr001
id usr001
# 40 .modify the sudousr to ask for the super user previlages.
visudo
#goto the wheel line and uncommnet the line, save and exit.

# 41. Install Xorg, Drivers adn desktop env.
pacman -S xorg

# 42. Insatll font packages.
pacman -S ttf-dejavu ttf-droid ttf-hack ttf-font-awesome otf-font-awesome ttf-lato ttf-liberation ttf-linux-libertime ttf-opensans ttf-roboto ttf-ubuntu-font-family

# 43. For font rendering and font configuration. ( optional )
cd /etc/fonts/conf.d/
ls ../conf.avial/

ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
ln -s /etc/fonts/conf.avail/70-no-bitmap.conf /etc/fonts/conf.d

vim /etc/profile.d/freetype2.sh
#uncomment the bottom line, save and exit file.

# 44. Video card driver.
lspci
#check for VGA compatilbe controller.
#For intel
xf86-video-intel libgl mesa optonal : vulka-intel ( for newer gen interl cpu )
# For Nvidia
nvidia nvidia-settings nvidia-utils mesa
# For AMD
mesa xf86-video-amdgpu vulkan-radeon

# for VM
virtualbox-guest-utils
virtualbox-guest-dkms
mesa
mesa-libgl

# 45. Insatll GUI env. (gnome, xfce, mate, )
    # to insatll gnome
    pacman -Syy gnome gnome-extra gdm

    # enable gnome disply manager
    systemctl enable gdm


# 46. To install i3 
sudo pacman -S xorg xorg-xinit i3-wm i3lock i3status i3blocks demnu terminator firefox

sudo cp /etc/X11/xinit/xinitrc ~/.xinitrc
sudo vim .xinitrc


# go to the end fo the file and enter teh ollowing
exec i3

--> setup configuration for the first time in i3
--> Hit enter the setup.
--> setup the mod key as per requriement.

mod+ENTER --> to open the terminal

--> to change the resoultion : 
xrandr --output Virtual-1 --mode 1920X1080
--> to change the font.
right click and preferences :  change it to source code pro - 14 size.

# enable virtualbox guest additional : auto screen size
sudo pacman -Syy virtualbox-guest-utils
sudo systemctl enable vboxservice.service


# 47. Purge local cache.
pacman -Scc

# 48. Customize the GNOME desktop evn.
    #Open setting pannel.
    
#


https://github.com/dilipjoe/archinstall/blob/main/archinstallcmd.ksh

curl -L https://github.com/dilipjoe/archinstall/blob/main/archinstallcmd.ksh > testfile

Then download the script with from the command line:

curl -L archfi.sf.net/archfi > archfi
If SourceForge is down, use this instead:

curl -L matmoul.github.io/archfi > archfi
Finally, launch the script:

sh archfi





















