#!/bin/bash

# Start dbus service to allow scanimage to work properly
service dbus start

# Run scanservjs
cd /var/www/scanservjs/
/var/www/scanservjs/server.js

#echo "starting 'tail -f /dev/null' to keep container hanging"
#tail -f /dev/null
