#!/bin/bash
#UNCOMMENT THE FOLLOWING LINES BEFORE PROD
YELLOW='\033[1;33m' # Yellow
NC='\033[0m' # No Color
if [[ $EUID -ne 0 ]]; then
   echo -e "${YELLOW} This script must be run as root" 
   mkdir -p logs
   echo -e "${YELLOW}DEBUG: Not ran as a root" >>logs/tailscale_install.log
   exit 1
fi
mkdir -p logs

# This script installs Curl on a Debian-based system as it is required for Tailscale installation
command -v curl >> /dev/null 2>&1
if [ $? -ne 0 ] ; then
    echo -e "${YELLOW}curl not found, installing curl... ${NC}"
    echo -e "DEBUG:curl not found, installing curl..." >>logs/tailscale_install.log
    apt-get update && apt install -y curl >>logs/tailscale_install.log

    if [ $? -eq 0 ] ; then
        echo -e "${YELLOW}Installed curl successfully, proceeding with Tailscale installation...${NC}" 
        echo -e "${NC}DEBUG: Installed curl successfully, proceeding with Tailscale installation" >>logs/tailscale\install.log
    else
        echo -e "${YELLOW}Failed to install curl, check the logs for errors" 
        echo -e "${YELLOW}DEBUG: Failed to install curl, check the logs for errors" >>logs/tailscale_install.log
        exit 1
    fi
fi


# Check if Tailscale is already installed

dpkg -l tailscale >> /dev/null 2>&1
if [ $? -eq 0 ] ; then
    TAILSCALE_INSTALLED="true"
    echo -e "${YELLOW}Tailscale is already installed "
    echo -e "${YELLOW}DEBUG: Tailscale is already installed " >>logs/tailscale_install.log
else
    TAILSCALE_INSTALLED="false"
    echo -e "${YELLOW}Tailscale is not installed, installing now... ${NC}"  
    echo -e "DEBUG: Tailscale is not installed, installing now..." >>logs/tailscale_install.log 
    curl -fsSL https://tailscale.com/install.sh |sh >>logs/tailscale_install.log 2>&1 
    if [ $? -eq 0 ] ; then
        echo -e "${YELLOW}Installed Tailscale"
        echo -e "DEBUG: Installed Tailscale" >>logs/tailscale_install.log

    else
        echo -e "${YELLOW}Failed to install Tailscale, check the logs for details"
        echo -e "${YELLOW}Failed to install Tailscale, check the logs for details" >>logs/tailscale_install.log
        exit 1
    fi
fi

# Check if Tailscale is already up and running
if tailscale status | grep -q "Logged out" ; then
    echo -e "${YELLOW}Tailscale is logged out, attempting to authenticate..." 
    echo -e "${YELLOW}DEBUG:Tailscale is logged out, attempting to authenticate..." >>logs/tailscale_install.log
else
    echo -e "${YELLOW}Tailscale is already authenticated, no need to log in again"
    echo -e "${YELLOW}DEBUG:Tailscale is already authenticated, no need to log in again" >>logs/tailscale_install.log
    exit 0
fi

# Check if the secret auth key file exists and attempt to use it for authentication
if [ -f ./top_secret ] ; then
    echo -e "${YELLOW}Secret auth key found, using it to authenticate Tailscale..."
    echo -e "${YELLOW}DEBUG: secret auth key found, using it to authenticate Tailscale..." >>logs/tailscale_install.log
    TAILSCALE_AUTH_KEY=$(cat ./top_secret)
    echo -e "${YELLOW}Using auth key: $TAILSCALE_AUTH_KEY" >>logs/tailscale_install.log
    tailscale up --authkey $TAILSCALE_AUTH_KEY >>logs/tailscale_install.log
    if [ $? -eq 0 ] ; then
        echo -e "${YELLOW}Tailscale authenticated successfully"
        echo -e "${YELLOW}Tailscale is now running, your ip address is: $(tailscale ip -4)"
        echo -e "${YELLOW}Tailscale is now running, your ip address is: $(tailscale ip -4)" >>logs/tailscale_install.log
    else
        echo -e "${YELLOW}DEBUG: Failed to authenticate Tailscale, check the logs for details" >>logs/tailscale_install.log
        echo -e "${YELLOW}Failed to authenticate Tailscale, check the logs for details" 
        exit 1
    fi
else
    echo -e "${YELLOW}No secret auth key found, please provide one in top_secret.txt"
    echo -e "${YELLOW}DEBUG: No secret auth key found, please provide one in top_secret.txt" >>logs/tailscale_install.log
    exit 1
fi