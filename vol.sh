amixer get Master | awk -F'[][]' '/%/ {if ($6 == "off") { print "Muted" } else { print "Vol:", $2 }}' | head -n 1
