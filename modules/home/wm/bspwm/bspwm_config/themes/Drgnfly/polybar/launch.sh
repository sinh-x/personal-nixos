#!/usr/bin/env bash

## Copyright (C) 2020-2024 Aditya Shakya <adi1090x@gmail.com>

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CARD="$(light -L | grep 'backlight' | head -n1 | cut -d'/' -f3)"
INTERFACE="$(ip link | awk '/state UP/ {print $2}' | tr -d :)"
RFILE="$DIR/.module"

# Fix backlight and network modules
fix_modules() {
	if [[ -z "$CARD" ]]; then
		sed -i -e 's/backlight/bna/g' "$DIR"/config.ini
	elif [[ "$CARD" != *"intel_"* ]]; then
		sed -i -e 's/backlight/brightness/g' "$DIR"/config.ini
	fi

	if [[ "$INTERFACE" == e* ]]; then
		sed -i -e 's/network/ethernet/g' "$DIR"/config.ini
	fi
}

# Launch the bar
launch_bar() {
	# Terminate already running bar instances
	pkill -9 -f "polybar -q"

	# Wait until the processes have been shut down
	while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

	# Launch the bar
	for mon in $(polybar --list-monitors | cut -d":" -f1); do
		if [[ "$mon" == "eDP-1" ]] || [[ "$mon" == "eDP1" ]]; then
            MONITOR=$mon polybar -q main -c "$DIR"/config.ini &
        else
            MONITOR=$mon polybar -q external -c "$DIR"/config.ini &
        fi
	done
}

# Execute functions
if [[ ! -f "$RFILE" ]]; then
	fix_modules
	touch "$RFILE"
fi	
launch_bar
