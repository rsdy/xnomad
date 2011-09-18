#!/bin/sh

/usr/bin/setxkbmap $1
/usr/bin/xmodmap -e "clear lock"
/usr/bin/xmodmap -e "keycode 0x42 = Escape"


