#!/usr/bin/env fish

# This script is used to manage workspaces in a bspwm environment depending on
# the number and type of connected monitors. It first checks the number of
# connected monitors and then either sets a default workspace if there's only
# one monitor or runs the `two_monitors` function if there are two monitors.
# The `two_monitors` function checks which monitors are connected and runs the
# corresponding script to set the monitor layout. It then assigns workspaces
# to the monitors based on their position.

# Set the internal monitor name
set INTERNAL_MONITOR $argv[1]

# Check if a main monitor position is provided as the second argument.
if count $argv >1 # Clearer condition: More than 1 argument
    set main_monitor_post $argv[2]
else if set -q MAIN_MONITOR_POST
    # Use the environment variable if it exists.
    set main_monitor_post $MAIN_MONITOR_POST
else
    # Default to "right" if no argument or environment variable is set.
    set main_monitor_post right
end

function set_display
    # Get the output of xrandr and split it into lines
    set output (xrandr | string split '\n')
    set index 0
    set connected_indices
    set disconneted_indices

    # Loop over the lines
    for line in $output
        # Increment the index
        set index (math $index+1)
        # If the line contains "connected", add the index to the list
        if string match -q "* connected *" $line
            set connected_indices $connected_indices $index
        else if string match -q "* disconnected *" $line
            set disconneted_indices $disconneted_indices $index
        end
    end

    set connected_monitors
    set resolutions

    # Loop over the indices of connected monitors to get 
    # their name & resolution
    for idx in $connected_indices
        # Print the line
        # Extract the monitor name and add it to the list
        set monitor_name (echo $output[$idx] | awk '{print $1}')
        # Calculate the index of the resolution
        set resolution_idx (math $idx+1)
        # Extract the resolution and add it to the list
        set res (echo $output[$resolution_idx] | awk '{print $1}')
        set width (echo $res | awk -F x '{print $1}')
        if test "$monitor_name" != "$INTERNAL_MONITOR" -a $width -gt 3000
            # Switch to the second resolution if the width is more than 3800
            set resolution_idx (math $resolution_idx+1)
            set res (echo $output[$resolution_idx] | awk '{print $1}')
        end
        set connected_monitors $connected_monitors $monitor_name
        set resolutions $resolutions $res
    end

    for i in (seq (count $disconneted_indices))
        set monitor_name (echo $output[$idx] | awk '{print $1}')
        xrandr --output $monitor_name --off
    end

    # Loop over the connected monitors
    set y 0
    set cur_x 0
    for i in (seq (count $connected_monitors))
        # Configure the monitor with xrandr
        xrandr --output $connected_monitors[$i] --mode $resolutions[$i] --pos "$cur_x"x"$y"
        # Calculate the x-coordinate for the next monitor
        if test "$main_monitor_post" = left
            set x_add (math (echo $resolutions[$i] | awk -F x '{print $1}'))
            set cur_x (math $cur_x+$x_add)
        else
            set x_add (math (echo $resolutions[$i] | awk -F x '{print $1}'))
            set cur_x (math $cur_x-$x_add)
        end
    end
end

# Function to set default workspace
function default_workspace
    # Assign workspaces 1-10 to the internal monitor
    bspc monitor $INTERNAL_MONITOR -d 1 2 3 4 5 6 7 8 9 10
end

# Function to handle two monitors
function two_monitors_workspace
    # Set the bspwm workspace based on the number of monitors and their position
    for monitor in (bspc query -M --names)
        # Get the coordinates of the monitor
        set coordinate (xrandr | grep $monitor | grep -oP '\d+x\d+\+\d+\+\d+')

        # Extract the x-coordinate from the coordinates
        set x_coordinate (echo $coordinate | awk -F '[x+]' '{print $3}')

        # Check if the x-coordinate is not empty
        if test -n $x_coordinate
            # Convert the x-coordinate to a number
            set x_coordinate (math $x_coordinate)
            # If the x-coordinate is 0, set the workspace to the left monitor
            if test $x_coordinate -eq 0
                bspc monitor $monitor -d 1 2 3 4 5 11 12 13 14 15
            else
                # If the x-coordinate is not 0, set the workspace to the right monitor
                bspc monitor $monitor -d 6 7 8 9 10 16 17 18 19 20
            end
        end
    end
end

# set diplay automatically
set_display
# Get the number of connected monitors
set monitors_count (xrandr | grep -c " connected ")
# If there is only one monitor, set the default workspace
if [ $monitors_count = 1 ]
    default_workspace
else
    # If there are two monitors, run the two_monitors function
    two_monitors_workspace
end
