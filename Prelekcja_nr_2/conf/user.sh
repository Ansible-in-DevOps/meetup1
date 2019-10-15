#!/bin/bash

echo "Adding user"

useradd -m -d /home/${SSH_ANSIBLE_USER} -G ssh ${SSH_ANSIBLE_USER} -s /bin/bash
echo "${SSH_ANSIBLE_USER}:${SSH_ANSIBLE_PASS}" | chpasswd
echo 'PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin"' >> /home/${SSH_ANSIBLE_USER}/.profile
 
exec "$@"