#!/bin/bash
     
#start SSH ans WWW server
printf "Starting the SSH server."

/etc/init.d/ssh start
/etc/init.d/apache2 start

exec "$@"
    
