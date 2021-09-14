#!/bin/sh
# ToppDev's Arch Linux Installation Scripts (TALIS)
# by Thomas Topp <dev@topp.cc>
# License: GNU GPLv3

# ########################################################################################################## #
#                                               Helper scripts                                               #
# ########################################################################################################## #

scriptdir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

source "$scriptdir/helper/color.sh"
source "$scriptdir/helper/log.sh"
source "$scriptdir/helper/install.sh"
source "$scriptdir/helper/checkArchRootInternet.sh"

# ########################################################################################################## #
#                                              Check Arch distro                                             #
# ########################################################################################################## #

check_arch_internet

# ########################################################################################################## #
#                                                Installation                                                #
# ########################################################################################################## #

# Private Internet Access (VPN)
if ! command -v piactl &> /dev/null; then
    inst='y'
    read -p "Install Private Internet Access VPN Client? [Y/n] " inst
    if [ ! $inst ] || [ $inst = "y" ] || [ $inst = "Y" ] || [ $inst = "yes" ] || [ $inst = "Yes" ]; then
        wget -P /tmp -nc https://installers.privateinternetaccess.com/download/pia-linux-3.0.1-06696.run
        chmod +x /tmp/pia-linux-*.run
        /tmp/pia-linux-*.run
        rm -f /tmp/pia-linux-*.run
    fi
fi

if ! pacman -Qs steam > /dev/null; then
    inst='y'
    read -p "Install steam? [Y/n] " inst
    if [ ! $inst ] || [ $inst = "y" ] || [ $inst = "Y" ] || [ $inst = "yes" ] || [ $inst = "Yes" ]; then
        aurinstall steam-fonts
        sudo fc-cache -fv
        pacinstall steam steam-native-runtime
        aurinstall protontricks
    fi
fi

# Open Gaming Platform
if ! pacman -Qs lutris > /dev/null; then
    inst='y'
    read -p "Install lutris? [Y/n] " inst
    if [ ! $inst ] || [ $inst = "y" ] || [ $inst = "Y" ] || [ $inst = "yes" ] || [ $inst = "Yes" ]; then
        pacinstall lutris
        if lspci -v | grep -A1 -e VGA -e 3D | grep -q "Intel"; then
            pacinstall lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader
        elif lspci -v | grep -A1 -e VGA -e 3D | grep -q "NVIDIA"; then
            pacinstall nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader
        elif lspci -v | grep -A1 -e VGA -e 3D | grep -q "AMD"; then
            pacinstall lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
        elif lspci -v | grep -A1 -e VGA -e 3D | grep -q "ATI"; then
            pacinstall lib32-mesa vulkan-radeon lib32-vulkan-radeon vulkan-icd-loader lib32-vulkan-icd-loader
        fi
    fi
fi

if pacman -Qs lutris > /dev/null; then
    if ! lutris --list-games --installed | grep Battle.net; then
        inst='y'
        read -p "Install Battle.net? [Y/n] " inst
        if [ ! $inst ] || [ $inst = "y" ] || [ $inst = "Y" ] || [ $inst = "yes" ] || [ $inst = "Yes" ]; then
            pacinstall wine lib32-gnutls lib32-libldap lib32-libgpg-error lib32-sqlite lib32-libpulse
            xdg-open lutris:blizzard-battlenet-standard
            echo "[Desktop Entry]
Type=Application
Name=Blizzard Battle.net
Icon=lutris_battlenet
Exec=lutris lutris:rungameid/1
Categories=Game
Name[en_US.UTF-8]=Blizzard Battle.net" > ~/.local/share/applications/Blizzard\ Battle.net
        fi
    fi
fi

if [ ! -d ~/Games/LeagueOfLegends ]; then
    inst='y'
    read -p "Install League of Legends? [Y/n] " inst
    if [ ! $inst ] || [ $inst = "y" ] || [ $inst = "Y" ] || [ $inst = "yes" ] || [ $inst = "Yes" ]; then
        aurinstall wine-lol
        wget -P /tmp -nc https://lol.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.euw.exe
        WINEARCH=win32 WINEPREFIX=~/Games/LeagueOfLegends/ /opt/wine-lol/bin/wine /tmp/live.euw.exe
        if ! sudo grep -q "abi.vsyscall32=0" /etc/sudoers; then
            sudo sed -i '/# ALL ALL=(ALL) ALL/a \\n%users ALL=(ALL) NOPASSWD: \/usr\/bin\/sysctl -w abi.vsyscall32=0' /etc/sudoers
        fi
        rm -f ~/.local/share/applications/wine/Programs/Riot\ Games/League\ of\ Legends.desktop
        rm -r ~/.local/share/applications/wine
    fi
fi


# ########################################################################################################## #

box "Other software installed"