#!/bin/bash
RED='\033[1;31m' # Red
GREEN='\033[1;32m' # Green
YELLOW='\033[1;33m' # Yellow
NC='\033[0m' # No Color

#gets the key required for Tailscale from FOG server
wget http://10.10.10.1/key/top_secret -O /tmp/key.txt

#Checks if it is ran as a root
if [[ $EUID -ne 0 ]]; then
   echo -e "${YELLOW} This script must be run as root" 
   echo -e "${YELLOW}DEBUG: Not ran as a root" >>/var/log/tailscale_install.log
   read -p "Press Enter to exit..."
   exit 1
fi


#Installs Curl on a Debian-based system as it is required for Tailscale installation
command -v curl >> /dev/null 2>&1
if [ $? -ne 0 ] ; then
    echo -e "${YELLOW}curl not found, installing curl... ${NC}"
    echo -e "DEBUG:curl not found, installing curl..." >>/var/log/tailscale_install.log
    apt-get update && apt install -y curl >>/var/log/tailscale_install.log

    if [ $? -eq 0 ] ; then
        echo -e "${GREEN}Installed curl successfully, proceeding with Tailscale installation...${NC}" 
        echo -e "${NC}DEBUG: Installed curl successfully, proceeding with Tailscale installation" >>/var/log/tailscale\install.log
    else
        echo -e "${RED}Failed to install curl, check the /var/log for errors" 
        echo -e "${RED}DEBUG: Failed to install curl, check the /var/log for errors" >>/var/log/tailscale_install.log
        read -p "Press Enter to exit..."
        exit 1
    fi
fi


# Check if Tailscale is already installed

dpkg -l tailscale >> /dev/null 2>&1
if [ $? -eq 0 ] ; then
    TAILSCALE_INSTALLED="true"
    echo -e "${GREEN}Tailscale is already installed "
    echo -e "${GREEN}DEBUG: Tailscale is already installed " >>/var/log/tailscale_install.log
else
    TAILSCALE_INSTALLED="false"
    echo -e "${YELLOW}Tailscale is not installed, installing now... ${NC}"  
    echo -e "DEBUG: Tailscale is not installed, installing now..." >>/var/log/tailscale_install.log 
    curl -fsSL https://tailscale.com/install.sh |sh >>/var/log/tailscale_install.log 2>&1 
    if [ $? -eq 0 ] ; then
        echo -e "${GREEN}Installed Tailscale"
        echo -e "DEBUG: Installed Tailscale" >>/var/log/tailscale_install.log

    else
        echo -e "${RED}Failed to install Tailscale, check the /var/log for details"
        echo -e "${RED}Failed to install Tailscale, check the /var/log for details" >>/var/log/tailscale_install.log
        read -p "Press Enter to exit..."
        exit 1
    fi
fi

# Check if Tailscale is already up and running
if tailscale status | grep -q "Logged out" ; then
    echo -e "${YELLOW}Tailscale is logged out, attempting to authenticate..." 
    echo -e "${YELLOW}DEBUG:Tailscale is logged out, attempting to authenticate..." >>/var/log/tailscale_install.log
else
    echo -e "${GREEN}Tailscale is already authenticated, no need to log in again"
    echo -e "${GREEN}DEBUG:Tailscale is already authenticated, no need to log in again" >>/var/log/tailscale_install.log
    read -p "Press Enter to exit..."
    exit 0
fi

# Check if the secret auth key file exists and attempt to use it for authentication
if [ -f /tmp/key.txt ] ; then
    echo -e "${YELLOW}Secret auth key found, using it to authenticate Tailscale..."
    echo -e "${YELLOW}DEBUG: secret auth key found, using it to authenticate Tailscale..." >>/var/log/tailscale_install.log
    TAILSCALE_AUTH_KEY=$(cat /tmp/key.txt)
    echo -e "${YELLOW}Using auth key: $TAILSCALE_AUTH_KEY" >>/var/log/tailscale_install.log
    tailscale up --authkey $TAILSCALE_AUTH_KEY >>/var/log/tailscale_install.log
    if [ $? -eq 0 ] ; then
        echo -e "${GREEN}Tailscale authenticated successfully"
        echo -e "${GREEN}Tailscale is now running, your ip address is: $(tailscale ip -4)"
        echo -e "${GREEN}Tailscale is now running, your ip address is: $(tailscale ip -4)" >>/var/log/tailscale_install.log
        read -p "Press Enter to exit..."
    else
        echo -e "${RED}DEBUG: Failed to authenticate Tailscale, check the /var/log for details" >>/var/log/tailscale_install.log
        echo -e "${RED}Failed to authenticate Tailscale, check the /var/log for details" 
        read -p "Press Enter to exit..."
        exit 1
    fi
else
    echo -e "${RED}No secret auth key found, please provide one in top_secret.txt"
    echo -e "${RED}DEBUG: No secret auth key found, please provide one in top_secret.txt" >>/var/log/tailscale_install.log
    read -p "Press Enter to exit..."
    exit 1
fi


read -p "Press Enter to exit..."