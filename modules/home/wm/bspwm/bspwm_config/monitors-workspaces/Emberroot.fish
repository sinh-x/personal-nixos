#!/usr/bin/env fish

#set LEFT_MONITOR HDMI-1
#set MIDDLE_MONITOR DP-1
#
#xrandr --output DP-1 --primary --mode 3840x2160 --pos 2560x0 --rotate normal --output HDMI-1 --mode 2560x1440 --pos 0x0 --rotate normal
#
#bspc monitor "$LEFT_MONITOR" -d 1 2 3 4 5 11 12 13 14 15
#bspc monitor "$MIDDLE_MONITOR" -d 6 7 8 9 10 16 17 18 19 20
#bspc wm -O "$LEFT_MONITOR" "$MIDDLE_MONITOR"

#set MIDDLE_MONITOR DP-1
#bspc monitor "$MIDDLE_MONITOR" -d 1 2 3 4 5 6 7 8 9 10
#bspc wm -O "$MIDDLE_MONITOR"

fish /home/sinh/.config/bspwm/scripts/monitor-management.fish eDP-1 left
