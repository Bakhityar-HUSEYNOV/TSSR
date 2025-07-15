#!./bin/bash
#UNCOMMENT THE FOLLOWING LINES BEFORE PROD
#if [[ $EUID -ne 0 ]]; then
#   echo "This script must be run as root" 
#   exit 1
#fi

# This script installs Curl on a Debian-based system as it is required for Tailscale installation
curl -V >> /dev/null
if [ $? -eq 1 ] ; then
    echo "curl not found, installing curl..." >>/var/log/tailscale_install.log
    apt-get update && apt install -y curl >>var/log/tailscale_install.log
    if [ $? -eq 0] ; then
        echo "Installed curl successfully, proceeding with Tailscale installation" >>/var/log/tailscale\install.log
    else
        echo "Failed to install curl, check the logs for errors" >>/var/log/tailscale_install.log
        exit 1
    fi


# Check if Tailscale is already installed
dpkg -l tailscale >> /dev/null
if [ $? -eq 0 ] ; then
    TAILSCALE_INSTALLED="true"
    echo "Tailscale is already installed " >>/var/log/tailscale_install.log
else
    TAILSCALE_INSTALLED="false"
    echo "Tailscla is not installed, installing now..." >>/var/log/tailscale_install.log  
    curl -fsSL https://tailscale.com/install.sh |sh >>/var/log/tailscale_install.log       
    if [ $? -eq 0 ] ; then
        echo "Installed Tailscale" >>/var/log/tailscale_install.log

    else
        echo "Failed to install Tailscale, check the logs for details" >>/var/log/tailscale_install.log
        exit 1
    fi
fi
