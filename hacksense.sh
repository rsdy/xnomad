wget -q -O - http://vsza.hu/hacksense/status.csv |awk -F';' '{ print "h:", $3 }'
