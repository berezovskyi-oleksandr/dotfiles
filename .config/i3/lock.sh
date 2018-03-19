#!/usr/bin/env bash
setxkbmap us
if [[ $(acpi -a) == *"off-line"* ]]
then
	i3lock --tiling --dpms --color 5e5e5e
	xset dpms force off
else
	i3lock --tiling --color 5e5e5e
fi

xkblayout-state set 0
setxkbmap -layout us,ru -option grp:caps_toggle -variant winkeys
