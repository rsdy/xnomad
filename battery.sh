acpi -b | awk -F' ' '{if ($3 == "Discharging,") { print "Battery:", $5 } }'
