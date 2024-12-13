#! /usr/bin/env fish

set wid $argv[1]
set -x class $argv[2]
set instance $argv[3]
set consequence $argv[4]

set current_desktop (bspc query -D -d focused --names)
set current_monitor (bspc query -d focused  -M --names)
set title (xprop -id $wid '\t$0' _NET_WM_NAME | cut -f 2)

set left_monitor $LEFT_MONITOR


function is_single_monitor
    set monitor_count (xrandr --listmonitors | grep -c " connected ")
    if [ $monitor_count -eq 1 ]
        return 0
    else
        return 1
    end
end

#TODO: adjust this rules for one monitor only
function pick_desktop -a w_class -a class_set -a desktop_set -a desire_desktop_left -a desire_desktop_central
    if is_single_monitor
        if not contains $current_desktop $$desktop_set
            set min_desktop (math min $desktop_set)
            echo 'desktop=' $min_desktop ' follow=on'
        end
    else
        if contains $$w_class $$class_set
            if not contains $current_desktop $$desktop_set
                if [ $current_monitor = $left_monitor ]
                    echo 'desktop=' $desire_desktop_central ' follow=on'
                else
                    echo 'desktop=' $desire_desktop_left ' follow=on'
                end
            end
        end
    end
end

if string match '*_crx_*' "$title"
    echo "state=floating sticky=on"
    exit 0
end

set -x web_class Google-chrome Mircrosoft-edge-dev firefox floorp
set -x web_desktop 1 2 16 17

pick_desktop class web_class web_desktop 1 16

set -x term_class Alacritty Xfce4-terminal kitty
set -x term_desktop 11 12 6 7

pick_desktop class term_class term_desktop 12 7

if [ $class = Gsimplecal ]
    echo "state=floating sticky=on"
end

if [ $class = showmethekey-gtk ]
    echo "state=floating sticky=on locked=on center=false rectangle=500x80+2050+30"
end
