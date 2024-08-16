#! /bin/sh
# ~/.config/bspwm/scripts/external_rules.sh

wid=$1
class=$2
instance=$3
consequences=$4

fish "$HOME/.config/bspwm/scripts/external_rules.fish" "$wid" "$class" "$instance" "$consequences"

# case "$class" in
#     ("")
#         unset -v _NET_WM_PID;
#         . /dev/fd/0 2>/dev/null <<IN
#         : \"\${$(
#             xprop \
#                 -id "$wid" \
#                 -notype \
#                 -f _NET_WM_PID 32c '=$0' \
#                 _NET_WM_PID;
#         )}\";
# IN
#         case "$(ps -p "${_NET_WM_PID:?}" -o comm= 2>/dev/null)" in
#             (spotify)
#                 echo 'desktop=11 follow=on';;
# 			(VirtualBox Machine)
# 				echo 'desktop=6 state=floating';;
#         esac;;
# esac;
#
# if [ "$class" = 'Galendae' ] ; then
#     echo "floating=on follow=off"
#     xdotool windowmove $wid x 1000 y 120 --relative
# fi
#
# title="$(xprop -id $wid '\t$0' _NET_WM_NAME | cut -f 2)"
# if [[ "$title" == *"Reconcile Account"* ]] ; then
# 	notify-send "$title"
# 	echo "state=floating follow=off center=true";
# fi
# if [[ "$title" == *"Edit Split"* ]] ; then
# 	notify-send "$title"
# 	echo "state=floating follow=off center=true";
# fi
# # if [[ "$title" == *"Windows 10 [Running] - Oracle VM VirtualBox"* ]] ; then
# # 	notify-send "$title"
# # 	echo "desktop=6 state=floating follow=off";
# # fi
