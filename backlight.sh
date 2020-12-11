#!/bin/bash

driver="/sys/devices/platform/tuxedo_keyboard"
args=($@)

if [ ! -d ${driver} ]; then
	echo "Please load tuxedo_keyboard module!"
	exit 1
fi

if [ ! -d "${driver}/uw_kbd_bl_color" ]; then
	echo "Only TUXEDO Polaris Laptops are supported!"
	exit 1
fi

driver="${driver}/uw_kbd_bl_color"

if [ $# -eq 0 ]; then
	echo "Usage: $0 help"
	exit 1
fi

SUDO=
if [ $EUID -ne 0 ]; then
	SUDO="sudo"
fi

for (( i=0; i<$#; i++ )); do
	arg=${args[$i]}
	if [ $arg = "help" ]; then
		echo "TUXEDO Polaris Backlight Control - 0.1 - 2020-12-11"
		echo "By Benjamin Stürz <stuerzbenni@gmail.com>"
		echo
		echo "$0 <command>"
		echo
		echo "Usage:"
		echo "       $0 help                - Show this page"
		echo "       $0 colors              - List available colors"
		echo "       $0 brightness [value]  - Get/Set brightness"
		echo "       $0 color <color>       - Set color"
		echo ""
		echo "Report bugs at "
		exit 0
	elif [ $arg = "colors" ]; then
		cat "${driver}/color_string"
		exit 0
	elif [ $arg = "color" ]; then
		if [ $i -eq $(($# - 1)) ]; then
			echo "Usage: $0 color <color>"
			exit 1
		else
			color=${args[$(($i+1))]}
			color=$(echo ${color} | tr '[:lower:]' '[:upper:]')
			echo ${color} | ${SUDO} tee "${driver}/color_string" > /dev/null 2> /dev/null
			if [ $? -ne 0 ]; then
				echo "Invalid Color"
				exit 1
			fi
		fi
		i=$(($i + 1))
	elif [ $arg = "brightness" ]; then
		if [ $i -eq $(($# - 1)) ]; then
			brightness=$(cat "${driver}/brightness")
			echo "Current brightness: ${brightness}"
		else
			brightness=${args[$i+1]}
			if [ $brightness -lt 0 ] || [ $brightness -gt 200 ]; then
				echo "Brightness values are between 0 and 200"
				exit 1
			fi
			msg=$(echo ${brightness} | ${SUDO} tee "${driver}/brightness")
			if [ $? -ne 0 ]; then
				echo "Failed to adjust brightness: $msg"
				exit 1
			fi
			i=$(($i + 1))
		fi
	else
		echo "Usage: $0 help"
		exit 1
	fi
done

