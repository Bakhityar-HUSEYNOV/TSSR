#!/bin/bash

# Variables for mounting
TARGET_DEVICE="/dev/sda1"
TARGET_MOUNT_POINT="/tmp/target_os"
# Create the temporary  directory where we will mount the partition
mkdir -p "$TARGET_MOUNT_POINT" 
# Attempt to mount the large partition (sda1)
mount "$TARGET_DEVICE" "$TARGET_MOUNT_POINT" 
#Create a directory for script and key file
mkdir -p "$TARGET_MOUNT_POINT/var/postdeploy"
#Copy key and script from fog server
cp /images/postdownloadscripts/deploy.sh "$TARGET_MOUNT_POINT/var/postdeploy/"
cp /images/postdownloadscripts/key.txt "$TARGET_MOUNT_POINT/var/postdeploy/"
#Creating oneshoot systemd service for deployment script
cat <<EOF > "$TARGET_MOUNT_POINT/etc/systemd/system/post_deployment.service"
[Unit]
Description=Inject Tailscale script
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash /var/postdeploy/deploy.sh
RemainAfterExit=true
StandardOutput=journal

[Install]
WantedBy=multi-user.target
EOF
#enable the created service
ln -sf /etc/systemd/system/post_deployment.service "$TARGET_MOUNT_POINT/etc/systemd/system/multi-user.target.wants/post_deployment.service"
# Unmount the partition.
umount "$TARGET_MOUNT_POINT" 
#Waiting for user input to close FOS
echo "Injection completed.Files and Service Configured."
echo "Files Copied To:"
echo "  - Script: $TARGET_MOUNT_POINT/var/postdeploy/deploy.sh"
echo "  - Key:    $TARGET_MOUNT_POINT/var/postdeploy/key.txt"
echo " "
echo "Systemd Service Status:"
echo "  - File Created: $TARGET_MOUNT_POINT/etc/systemd/system/post_deployment.service"
echo "  - Target:       multi-user.target"
echo "  - Dependency:   After=multi-user.target (Latest possible run time)"
echo "  - Log Output:   StandardOutput=journal (Logs viewable via 'journalctl -u post_deployment.service')"
echo "  - Status:       Partition $TARGET_MOUNT_POINT mounted, configured, and ready for first boot."
echo "========================================================="
echo " Press Enter to reboot"
read
