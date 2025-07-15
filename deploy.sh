#!./bin/bash
dpkg -l tailscale 
if [ $? -eq 0 ] ; then
    TAILSCALE_INSTALLED="true"
    echo "Tailscale is already installed " >>/var/log/tailscale_install.log
    else
    TAILSCALE_INSTALLED="false"
    echo "Tailscla is not installed, installing now..." >>/var/log/tailscale_install.log
    if [ curl -V ] ; then
    
    curl -fsSL https://tailscale.com/install.sh |sh >>/var/log/tailscale_install.log
    else
        echo "curl not found, installing curl..." >>/var/log/tailscale_install.log
        apt-get update && apt install -y curl >>var/log/tailscale_install.log
        
    if [ $? -eq 0 ] ; then
        echo "Installed Tailscale" >>/var/log/tailscale_install.log

    else
        echo "Failed to install Tailscale, check the logs for details" >>/var/log/tailscale_install.log
        exit 1
    fi
fi