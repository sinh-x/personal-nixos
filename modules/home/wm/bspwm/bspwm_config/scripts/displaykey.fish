#!/usr/bin/env fish

set l_pkill (pgrep screenkey)
kill -9 {$l_pkill}

fish "$HOME/.config/bspwm/monitors-workspaces/$hostname-displaykey.fish"
