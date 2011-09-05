#!/bin/sh
# Script to launch dmenu with colors matching IR_Black theme
# Author: Vic Fryzel
# http://github.com/vicfryzel/xmonad-config

exe=$(dmenu_path | /usr/bin/dmenu -fn 'xft:Envy Code R:size=10' \
	-nb '#000000' -nf '#FFFFFF' -sb '#222222' -sf '#b6e77d') && eval "exec $exe"
