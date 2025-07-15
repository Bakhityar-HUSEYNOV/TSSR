#!/bin/bash
#UNCOMMENT THE FOLLOWING LINES BEFORE PROD
YELLOW='\033[1;33m'
if [[ $EUID -ne 0 ]]; then
   echo -e "${YELLOW} This script must be run as root" 
   echo "${YELLOW}DEBUG: Not ran as a root" >>/var/log/tailscale_install.log
   exit 1
fi

# This script installs Curl on a Debian-based system as it is required for Tailscale installation
command -v curl >> /dev/null 2>&1
if [ $? -ne 0 ] ; then
    echo "${YELLOW}curl not found, installing curl..."
    echo "${YELLOW}DEBUG:curl not found, installing curl..." >>/var/log/tailscale_install.log
    apt-get update && apt install -y curl >>/var/log/tailscale_install.log

    if [ $? -eq 0 ] ; then
        echo "${YELLOW}Installed curl successfully, proceeding with Tailscale installation" 
        echo "${YELLOW}DEBUG: Installed curl successfully, proceeding with Tailscale installation" >>/var/log/tailscale\install.log
    else
        echo "${YELLOW}Failed to install curl, check the logs for errors" 
        echo "${YELLOW}DEBUG: Failed to install curl, check the logs for errors" >>/var/log/tailscale_install.log
        exit 1
    fi
fi


# Check if Tailscale is already installed

dpkg -l tailscale >> /dev/null 2>&1
if [ $? -eq 0 ] ; then
    TAILSCALE_INSTALLED="true"
    echo "${YELLOW}Tailscale is already installed "
    echo "${YELLOW}DEBUG: Tailscale is already installed " >>/var/log/tailscale_install.log
else
    TAILSCALE_INSTALLED="false"
    echo "${YELLOW}Tailscale is not installed, installing now..."  
    echo "${YELLOW}DEBUG: Tailscale is not installed, installing now..." >>/var/log/tailscale_install.log 
    curl -fsSL https://tailscale.com/install.sh |sh >>/var/log/tailscale_install.log 2>&1 
    if [ $? -eq 0 ] ; then
        echo "${YELLOW}Installed Tailscale"
        echo "${YELLOW}DEBUG: Installed Tailscale" >>/var/log/tailscale_install.log

    else
        echo "${YELLOW}Failed to install Tailscale, check the logs for details"
        echo "${YELLOW}Failed to install Tailscale, check the logs for details" >>/var/log/tailscale_install.log
        exit 1
    fi
fi

# Check if Tailscale is already up and running
if tailscale status | grep -q "Logged out" ; then
    echo "${YELLOW}Tailscale is logged out, attempting to authenticate..." 
    echo "${YELLOW}DEBUG:Tailscale is logged out, attempting to authenticate..." >>/var/log/tailscale_install.log
else
    echo "${YELLOW}Tailscale is already authenticated, no need to log in again"
    echo "${YELLOW}DEBUG:Tailscale is already authenticated, no need to log in again" >>/var/log/tailscale_install.log
    exit 0
fi

# Check if the secret auth key file exists and attempt to use it for authentication
if [ -f ./top_secret ] ; then
    echo "${YELLOW}Secret auth key found, using it to authenticate Tailscale..."
    echo "${YELLOW}DEBUG: secret auth key found, using it to authenticate Tailscale..." >>/var/log/tailscale_install.log
    TAILSCALE_AUTH_KEY=$(cat ./top_secret)
    echo "${YELLOW}Using auth key: $TAILSCALE_AUTH_KEY" >>/var/log/tailscale_install.log
    tailscale up --authkey $TAILSCALE_AUTH_KEY >>/var/log/tailscale_install.log
    if [ $? -eq 0 ] ; then
        echo "${YELLOW}Tailscale authenticated successfully"
         echo "${YELLOW}Tailscale is now running, your ip address is: $(tailscale ip -4)"
        echo "${YELLOW}Tailscale is now running, your ip address is: $(tailscale ip -4)" >>/var/log/tailscale_install.log
    else
        echo "${YELLOW}DEBUG: Failed to authenticate Tailscale, check the logs for details" >>/var/log/tailscale_install.log
        echo "${YELLOW}Failed to authenticate Tailscale, check the logs for details" 
        exit 1
    fi
else
    echo "${YELLOW}No secret auth key found, please provide one in top_secret.txt"
    echo "${YELLOW}DEBUG: No secret auth key found, please provide one in top_secret.txt" >>/var/log/tailscale_install.log
    exit 1
fi