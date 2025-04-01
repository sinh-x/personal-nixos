#!/usr/bin/env fish

set wifi_name (wpa_cli status | grep '^ssid=' | cut -d'=' -f2)

if test "$wifi_name" = "Mai Trang"
    # Run this command if connected to "Mai Trang"
    fish /home/sinh/.config/bspwm/scripts/monitor-management.fish eDP-1 right
else
    # Run a different command if not connected to "Mai Trang"
    fish /home/sinh/.config/bspwm/scripts/monitor-management.fish eDP-1 left
end
