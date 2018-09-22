#!/bin/bash

# Start dbus service to allow scanimage to work properly
service dbus start

# Run brscan-skey (in background)
/opt/brother/scanner/brscan-skey/brscan-skey

# Run google-cloud-print
service avahi-daemon start
service cups start
#cupsctl --remote-admin --remote-any --share-printers
lpadmin -p "MFC7320-docker" -v "usb://Brother/MFC-7320?serial=000E8N228135" -P "/usr/share/cups/model/MFC7320.ppd" -o printer-is-shared=true
cupsenable "MFC7320-docker" -E
cupsaccept "MFC7320-docker"

# Run scanservjs
cd /var/www/scanservjs/
/var/www/scanservjs/server.js

#echo "starting 'tail -f /dev/null' to keep container hanging"
#tail -f /dev/null
