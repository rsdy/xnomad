#!/bin/sh
# Script to launch dmenu with colors matching IR_Black theme
# Author: Vic Fryzel
# http://github.com/vicfryzel/xmonad-config

exe=$(dmenu_path | /usr/bin/dmenu -fn 'xft:Envy Code R:size=10' \
	-nb '#002b36' -nf '#657b83' -sb '#073642' -sf '#f30085') && eval "exec $exe"
