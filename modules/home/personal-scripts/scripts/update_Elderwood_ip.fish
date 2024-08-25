#!/usr/bin/env fish

set new_hostname (rclone cat wasabi-sinh:sinh/shared_resources/Elderwood_public_ip.txt)
sed -i "/Host Elderwood/,+1s/HostName .*/HostName $new_hostname/" /home/sinh/.ssh/config
