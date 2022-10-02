#!/bin/bash

#Simple fresh install script..
#more to come along the road.


# Default stuff 
CWD=`pwd`;

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run with sudo (sudo -i)" 
   exit 1
fi

read -p "Please enter your username: " target_user;

if id -u "$target_user" >/dev/null 2>&1; then
    echo "User $target_user exists! Proceeding.. ";
else
    echo 'The username you entered does not seem to exist.';
    exit 1;
fi


# function to run command as non-root user
run_as_user() {
	sudo -u $target_user bash -c "$1";
}


# Standards needs to be fixed.....
#assumes minimal as default

apt update && apt update -y
#standard tools
apt install git -y
apt install curl -y
apt install wget -y
apt install gimp -y 
apt install ssh -y
apt install build-essential -y 
apt install python3 -y
apt install jq -y


#others
apt install neofetch -y 
apt install filezilla -y
apt install vlc -y 
apt install TeXstudio -y 
apt install ffmpeg -y

#standard apps 
apt install steam -y
apt install qbittorrent -y  

#libreoffice in nb defaults manual internal setup to be looked at later
apt install libreoffice libreoffice-l10n-nb myspell-nb mythes-no -y 

# nice calcualtor 
apt install qalc -y 
apt install qalculate-gtk -y

#flatpak section 
apt install flatpak -y
apt install gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

#flatpaks
flatpak install flathub com.usebottles.bottles


printf "Flatpak installed remember desktop enviromentals is not in effect before restart.\n";


#Glorious eggrolls
GEProtonVERSION=$(curl 'https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest' | jq '.tag_name' |awk '{print substr($0, 2, length($0) - 2)}');
echo $GEProtonVERSION
mkdir -p "/home/$USER/.steam/root/compatibilitytools.d"
wget https://github.com/GloriousEggroll/proton-ge-custom/releases/download/$GEProtonVERSION/$GEProtonVERSION.tar.gz
tar -xf $GEProtonVERSION.tar.gz -C "/home/$USER/.steam/root/compatibilitytools.d"


#Wine install 
sudo dpkg --add-architecture i386 
mkdir -pm755 /etc/apt/keyrings
wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key


#Purging evils
#might need updates in future versions
snap remove firefox
add-apt-repository ppa:mozillateam/ppa
echo '
Package: *
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
' | tee /etc/apt/preferences.d/mozilla-firefox

echo '
Unattended-Upgrade::Allowed-Origins:: 
"LP-PPA-mozillateam:${distro_codename}";
' |  tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox
apt install firefox
