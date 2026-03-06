#!/bin/bash

echo "Sending test notifications..."

notify-send "HyprUI" "This is a standard notification test." -i utilities-terminal
sleep 1
notify-send "System Update" "Your system is up to date." -u low -i system-software-update
sleep 1
notify-send "Battery Critical" "Please plug in your charger immediately!" -u critical -i battery-caution
sleep 1
notify-send "Music" "Now Playing: Catppuccin Beats" -i multimedia-player

echo "Done."
