#!./bin/bash
#UNCOMMENT THE FOLLOWING LINES BEFORE PROD
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# This script installs Curl on a Debian-based system as it is required for Tailscale installation
command -v curl >> /dev/null 2>&1
if [ $? -ne 0 ] ; then
    echo "curl not found, installing curl..." >>/var/log/tailscale_install.log
    apt-get update && apt install -y curl >>/var/log/tailscale_install.log
    if [ $? -eq 0 ] ; then
        echo "Installed curl successfully, proceeding with Tailscale installation" >>/var/log/tailscale\install.log
    else
        echo "Failed to install curl, check the logs for errors" >>/var/log/tailscale_install.log
        exit 1
    fi
fi


# Check if Tailscale is already installed
dpkg -l tailscale >> /dev/null 2>&1
if [ $? -eq 0 ] ; then
    TAILSCALE_INSTALLED="true"
    echo "Tailscale is already installed " >>/var/log/tailscale_install.log
else
    TAILSCALE_INSTALLED="false"
    echo "Tailscale is not installed, installing now..." >>/var/log/tailscale_install.log  
    curl -fsSL https://tailscale.com/install.sh |sh >>/var/log/tailscale_install.log       
    if [ $? -eq 0 ] ; then
        echo "Installed Tailscale" >>/var/log/tailscale_install.log

    else
        echo "Failed to install Tailscale, check the logs for details" >>/var/log/tailscale_install.log
        exit 1
    fi
fi
# Check if Tailscale key exists and use it to authenticate

if [ -f ./top_secret ] ; then
    echo "secret auth key found, using it to authenticate Tailscale..." >>/var/log/tailscale_install.log
    TAILSCALE_AUTH_KEY=$(cat ./top_secret)
    echo "Using auth key: $TAILSCALE_AUTH_KEY" >>/var/log/tailscale_install.log
    tailscale up --authkey $TAILSCALE_AUTH_KEY >>/var/log/tailscale_install.log
    if [ $? -eq 0 ] ; then
        echo "Tailscale authenticated successfully" >>/var/log/tailscale_install.log
        echo "Tailscale is now running, your ip address is: $(tailscale ip -4)" >>/var/log/tailscale_install.log
    else
        echo "Failed to authenticate Tailscale, check the logs for details" >>/var/log/tailscale_install.log
        exit 1
    fi
else
    echo "No secret auth key found, please provide one in top_secret.txt" >>/var/log/tailscale_install.log
    exit 1
fi