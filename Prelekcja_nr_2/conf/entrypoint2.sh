#!/bin/bash
     
#start SSH server
printf "Starting the SSH server."

/etc/init.d/ssh start

exec "$@"
