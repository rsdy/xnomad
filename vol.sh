SOUND_DEV="/dev/snd/controlC0"

volume() {
	amixer get Master | awk -F'[][]' '/%/ {if ($6 == "off") { print "muted" } else { print "v:", $2 }}' | head -n 1
}

while [ $? -eq 0 ] && [[ $(ps p $PPID | grep xmobar) ]];
do
	volume
	inotifywait $SOUND_DEV -e ACCESS -e CLOSE_WRITE > /dev/null 2>/dev/null
done
