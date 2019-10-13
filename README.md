# meetup1
https://www.meetup.com/pl-PL/Ansible-in-DevOps-Torun-Bydgoszcz/events/nfpfjryznbvb/


# Prelekcja nr 2 -> instalacja środowiska Ansible w Dokerze.

1. Zainstaluj paczki docker-ce oraz docker-compose do uruchomienia kontenerów. 

Uwaga: **Twój użytkownik Linux powinnien móc używać sudo na root-a.** (https://dug.net.pl/tekst/63/przewodnik_po_sudo/)

RedHat 7/CentOS 7
````bash
$ sudo yum install -y yum-utils device-mapper-persistent-data lvm2
$ sudo yum-config-manager --add-repo https://download.docker.com/linux/centos
$ sudo yum install docker-ce
$ sudo systemctl enable docker.service
$ sudo systemctl start docker.service
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
$ docker-compose --version
````
Ubuntu 18/Debian 9

````bash
$ sudo apt update
$ sudo apt install apt-transport-https ca-certificates curl software-properties-common
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
$ sudo apt update
$ sudo apt install docker-ce
$ sudo systemctl enable docker.service
$ sudo systemctl start docker.service
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
$ docker-compose --version
````

2. Uruchom kontenery 

````bash
$ git clone https://github.com/Ansible-in-DevOps/meetup1.git
$ cd ./meetup1/
$ sudo set -a
$ sudo source ./conf/.env 
$ sudo docker-compose -f docker-compose_ansible.yml up -d --build
$ sudo docker ps
CONTAINER ID        IMAGE                    COMMAND                  CREATED              STATUS              PORTS                 NAMES
a8329907eddb        meetup1_ansible_server   "/usr/local/bin/entr…"   About a minute ago   Up About a minute                         ansible-server
284518bd33fd        meetup1_apache_1         "/usr/local/bin/entr…"   4 minutes ago        Up 4 minutes        0.0.0.0:801->80/tcp   apache-server-1
31b0739b73a7        meetup1_apache_2         "/usr/local/bin/entr…"   4 minutes ago        Up 4 minutes        0.0.0.0:802->80/tcp   apache-server-2
````

3. Logowanie się do serwera Ansible (dwie metody):
- SSH 

````bash
$ sudo docker network inspect meetup1_ansible 
[
    {
        "Name": "meetup1_ansible",
        "Id": "6c9eaa735d45693076f767839335e959f270283b5015b45a94c3b11f9004d7e5",
        "Created": "2019-10-09T20:38:19.633593887+02:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.1.0.0/24"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "284518bd33fd9dcb06f5a11505ef4852c11bffcb1a1b2f61bc4a17552b63298d": {
                "Name": "apache-server-1",
                "EndpointID": "5fc0e63d26bda81f9d418e72211a7c6ff9a20630a271c039be0b646a0163a0c1",
                "MacAddress": "02:42:ac:01:00:14",
                "IPv4Address": "172.1.0.20/24",
                "IPv6Address": ""
            },
            "31b0739b73a75443471f89dd01430d3bfbc1201844a4987cbf819d6f1a24328a": {
                "Name": "apache-server-2",
                "EndpointID": "919655bf061463be1a446d1ad7d4300d00377b372695f12b3b472ce2a5077c1e",
                "MacAddress": "02:42:ac:01:00:1e",
                "IPv4Address": "172.1.0.30/24",
                "IPv6Address": ""
            },
            "a8329907eddb68f377ce7598d2b24b2809b4acf9b5bc58ebe2fe5c9e24ad4825": {
                "Name": "ansible-server",
                "EndpointID": "e1faff6edf4df08c8d3c532c94e8398ea03a76ed9f55042e0d0b8c10e268356f",
                "MacAddress": "02:42:ac:01:00:0a",
                "IPv4Address": "172.1.0.10/24",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]

$ ssh aido@172.1.0.10
````

- docker exec

````bash
$ sudo docker exec -it -u aido ansible-server bash 
````

4. Wymiana kluczy z serwera Ansible do serwerów Apache. 

````
aido@ansible-server-local:/opt/local/ansible$ ssh-keygen 
aido@ansible-server-local:/opt/local/ansible$ ssh-copy-id 172.1.0.20
Are you sure you want to continue connecting (yes/no)? yes
aido@172.1.0.20's password: 

Number of key(s) added: 1


aido@ansible-server-local:/opt/local/ansible$ ssh-copy-id 172.1.0.30
Are you sure you want to continue connecting (yes/no)? yes
aido@172.1.0.30's password: 

Number of key(s) added: 1
````

5. Test połączenia między serwerami. 

````bash
aido@ansible-server-local:/opt/local/ansible$ ansible apache -m ping   
apache2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    }, 
    "changed": false, 
    "ping": "pong"
}
apache1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    }, 
    "changed": false, 
    "ping": "pong"
}
````
6. Co w Ansible piszczy.

````bash
aido@ansible-server-local:/opt/local/ansible$ ansible -m ping apache2 -vvv
ansible 2.8.5
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/home/aido/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/dist-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.16 (default, Oct  7 2019, 17:36:04) [GCC 8.3.0]
Using /etc/ansible/ansible.cfg as config file
host_list declined parsing /etc/ansible/hosts as it did not pass it's verify_file() method
script declined parsing /etc/ansible/hosts as it did not pass it's verify_file() method
auto declined parsing /etc/ansible/hosts as it did not pass it's verify_file() method
Parsed /etc/ansible/hosts inventory source with ini plugin
META: ran handlers
<172.1.0.30> ESTABLISH SSH CONNECTION FOR USER: aido
<172.1.0.30> SSH: EXEC ssh -C -o ControlMaster=auto -o ControlPersist=60s -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o 'User="aido"' -o ConnectTimeout=10 -o ControlPath=/home/aido/.ansible/cp/7cd73dffac 172.1.0.30 '/bin/sh -c '"'"'echo ~aido && sleep 0'"'"''
<172.1.0.30> (0, '/home/aido\n', '')
<172.1.0.30> ESTABLISH SSH CONNECTION FOR USER: aido
<172.1.0.30> SSH: EXEC ssh -C -o ControlMaster=auto -o ControlPersist=60s -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o 'User="aido"' -o ConnectTimeout=10 -o ControlPath=/home/aido/.ansible/cp/7cd73dffac 172.1.0.30 '/bin/sh -c '"'"'( umask 77 && mkdir -p "` echo /home/aido/.ansible/tmp/ansible-tmp-1570915011.03-184174433091144 `" && echo ansible-tmp-1570915011.03-184174433091144="` echo /home/aido/.ansible/tmp/ansible-tmp-1570915011.03-184174433091144 `" ) && sleep 0'"'"''
<172.1.0.30> (0, 'ansible-tmp-1570915011.03-184174433091144=/home/aido/.ansible/tmp/ansible-tmp-1570915011.03-184174433091144\n', '')
<apache2> Attempting python interpreter discovery
<172.1.0.30> ESTABLISH SSH CONNECTION FOR USER: aido
<172.1.0.30> SSH: EXEC ssh -C -o ControlMaster=auto -o ControlPersist=60s -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o 'User="aido"' -o ConnectTimeout=10 -o ControlPath=/home/aido/.ansible/cp/7cd73dffac 172.1.0.30 '/bin/sh -c '"'"'echo PLATFORM; uname; echo FOUND; command -v '"'"'"'"'"'"'"'"'/usr/bin/python'"'"'"'"'"'"'"'"'; command -v '"'"'"'"'"'"'"'"'python3.7'"'"'"'"'"'"'"'"'; command -v '"'"'"'"'"'"'"'"'python3.6'"'"'"'"'"'"'"'"'; command -v '"'"'"'"'"'"'"'"'python3.5'"'"'"'"'"'"'"'"'; command -v '"'"'"'"'"'"'"'"'python2.7'"'"'"'"'"'"'"'"'; command -v '"'"'"'"'"'"'"'"'python2.6'"'"'"'"'"'"'"'"'; command -v '"'"'"'"'"'"'"'"'/usr/libexec/platform-python'"'"'"'"'"'"'"'"'; command -v '"'"'"'"'"'"'"'"'/usr/bin/python3'"'"'"'"'"'"'"'"'; command -v '"'"'"'"'"'"'"'"'python'"'"'"'"'"'"'"'"'; echo ENDFOUND && sleep 0'"'"''
<172.1.0.30> (0, 'PLATFORM\nLinux\nFOUND\n/usr/bin/python3.7\n/usr/bin/python3\nENDFOUND\n', '')
<172.1.0.30> ESTABLISH SSH CONNECTION FOR USER: aido
<172.1.0.30> SSH: EXEC ssh -C -o ControlMaster=auto -o ControlPersist=60s -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o 'User="aido"' -o ConnectTimeout=10 -o ControlPath=/home/aido/.ansible/cp/7cd73dffac 172.1.0.30 '/bin/sh -c '"'"'/usr/bin/python3.7 && sleep 0'"'"''
<172.1.0.30> (0, '{"platform_dist_result": ["Ubuntu", "19.04", "disco"], "osrelease_content": "NAME=\\"Ubuntu\\"\\nVERSION=\\"19.04 (Disco Dingo)\\"\\nID=ubuntu\\nID_LIKE=debian\\nPRETTY_NAME=\\"Ubuntu 19.04\\"\\nVERSION_ID=\\"19.04\\"\\nHOME_URL=\\"https://www.ubuntu.com/\\"\\nSUPPORT_URL=\\"https://help.ubuntu.com/\\"\\nBUG_REPORT_URL=\\"https://bugs.launchpad.net/ubuntu/\\"\\nPRIVACY_POLICY_URL=\\"https://www.ubuntu.com/legal/terms-and-policies/privacy-policy\\"\\nVERSION_CODENAME=disco\\nUBUNTU_CODENAME=disco\\n"}\n', '<stdin>:29: DeprecationWarning: dist() and linux_distribution() functions are deprecated in Python 3.5\n')
Using module file /usr/lib/python2.7/dist-packages/ansible/modules/system/ping.py
<172.1.0.30> PUT /home/aido/.ansible/tmp/ansible-local-7310IRRJg/tmpeRWX9t TO /home/aido/.ansible/tmp/ansible-tmp-1570915011.03-184174433091144/AnsiballZ_ping.py
<172.1.0.30> SSH: EXEC sftp -b - -C -o ControlMaster=auto -o ControlPersist=60s -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o 'User="aido"' -o ConnectTimeout=10 -o ControlPath=/home/aido/.ansible/cp/7cd73dffac '[172.1.0.30]'
<172.1.0.30> (0, 'sftp> put /home/aido/.ansible/tmp/ansible-local-7310IRRJg/tmpeRWX9t /home/aido/.ansible/tmp/ansible-tmp-1570915011.03-184174433091144/AnsiballZ_ping.py\n', '')
<172.1.0.30> ESTABLISH SSH CONNECTION FOR USER: aido
<172.1.0.30> SSH: EXEC ssh -C -o ControlMaster=auto -o ControlPersist=60s -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o 'User="aido"' -o ConnectTimeout=10 -o ControlPath=/home/aido/.ansible/cp/7cd73dffac 172.1.0.30 '/bin/sh -c '"'"'chmod u+x /home/aido/.ansible/tmp/ansible-tmp-1570915011.03-184174433091144/ /home/aido/.ansible/tmp/ansible-tmp-1570915011.03-184174433091144/AnsiballZ_ping.py && sleep 0'"'"''
<172.1.0.30> (0, '', '')
<172.1.0.30> ESTABLISH SSH CONNECTION FOR USER: aido
<172.1.0.30> SSH: EXEC ssh -C -o ControlMaster=auto -o ControlPersist=60s -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o 'User="aido"' -o ConnectTimeout=10 -o ControlPath=/home/aido/.ansible/cp/7cd73dffac -tt 172.1.0.30 '/bin/sh -c '"'"'sudo -H -S -n  -u root /bin/sh -c '"'"'"'"'"'"'"'"'echo BECOME-SUCCESS-fbdguoilvwsywxcourakznfvlqhjfeuc ; /usr/bin/python3 /home/aido/.ansible/tmp/ansible-tmp-1570915011.03-184174433091144/AnsiballZ_ping.py'"'"'"'"'"'"'"'"' && sleep 0'"'"''
Escalation succeeded
<172.1.0.30> (0, '/home/aido/.ansible/tmp/ansible-tmp-1570915011.03-184174433091144/AnsiballZ_ping.py:18: DeprecationWarning: the imp module is deprecated in favour of importlib; see the module\'s documentation for alternative uses\r\n  import imp\r\n\r\n{"ping": "pong", "invocation": {"module_args": {"data": "pong"}}}\r\n', 'Shared connection to 172.1.0.30 closed.\r\n')
<172.1.0.30> ESTABLISH SSH CONNECTION FOR USER: aido
<172.1.0.30> SSH: EXEC ssh -C -o ControlMaster=auto -o ControlPersist=60s -o KbdInteractiveAuthentication=no -o PreferredAuthentications=gssapi-with-mic,gssapi-keyex,hostbased,publickey -o PasswordAuthentication=no -o 'User="aido"' -o ConnectTimeout=10 -o ControlPath=/home/aido/.ansible/cp/7cd73dffac 172.1.0.30 '/bin/sh -c '"'"'rm -f -r /home/aido/.ansible/tmp/ansible-tmp-1570915011.03-184174433091144/ > /dev/null 2>&1 && sleep 0'"'"''
<172.1.0.30> (0, '', '')
apache2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    }, 
    "changed": false, 
    "invocation": {
        "module_args": {
            "data": "pong"
        }
    }, 
    "ping": "pong"
}
META: ran handlers
META: ran handlers
````

7. Informacje o serwerach.

````bash
aido@ansible-server-local:/opt/local/ansible$ ansible -m setup apache1
...
        "ansible_fqdn": "apache-local-1", 
        "ansible_hostname": "apache-local-1", 
        "ansible_hostnqn": "", 
        "ansible_is_chroot": false, 
        "ansible_iscsi_iqn": "", 
        "ansible_kernel": "4.9.0-9-amd64", 
        "ansible_local": {}, 
        "ansible_lsb": {
            "codename": "disco", 
            "description": "Ubuntu 19.04", 
            "id": "Ubuntu", 
            "major_release": "19", 
            "release": "19.04"
        }, 
        "ansible_machine": "x86_64", 
...
aido@ansible-server-local:/opt/local/ansible$ ansible -m setup -a 'filter=*ansible_hostname*' apache
apache1 | SUCCESS => {
    "ansible_facts": {
        "ansible_hostname": "apache-local-1", 
        "discovered_interpreter_python": "/usr/bin/python3"
    }, 
    "changed": false
}
apache2 | SUCCESS => {
    "ansible_facts": {
        "ansible_hostname": "apache-local-2", 
        "discovered_interpreter_python": "/usr/bin/python3"
    }, 
    "changed": false
}
````

8. Zmiany na wielu serwerach.

````bash
aido@ansible-server-local:/opt/local/ansible$ cat update_www.yml 
---
- hosts: apache
  tasks:
  - name: change content on apache 
    shell: echo '{{ ansible_hostname }}' > /var/www/html/index.html   

aido@ansible-server-local:/opt/local/ansible$ ansible-playbook -vv update_www.yml       
ansible-playbook 2.8.5
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/home/aido/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/dist-packages/ansible
  executable location = /usr/bin/ansible-playbook
  python version = 2.7.16 (default, Oct  7 2019, 17:36:04) [GCC 8.3.0]
Using /etc/ansible/ansible.cfg as config file

PLAYBOOK: update_www.yml *****************************************************************************************************************************
1 plays in update_www.yml

PLAY [apache] ****************************************************************************************************************************************

TASK [Gathering Facts] *******************************************************************************************************************************
task path: /opt/local/ansible/update_www.yml:2
ok: [apache2]
ok: [apache1]
META: ran handlers

TASK [change content on apache] **********************************************************************************************************************
task path: /opt/local/ansible/update_www.yml:4
changed: [apache2] => {"changed": true, "cmd": "echo 'apache-local-2' > /var/www/html/index.html", "delta": "0:00:00.005894", "end": "2019-10-12 21:14:05.138081", "rc": 0, "start": "2019-10-12 21:14:05.132187", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}
changed: [apache1] => {"changed": true, "cmd": "echo 'apache-local-1' > /var/www/html/index.html", "delta": "0:00:00.005161", "end": "2019-10-12 21:14:05.151054", "rc": 0, "start": "2019-10-12 21:14:05.145893", "stderr": "", "stderr_lines": [], "stdout": "", "stdout_lines": []}
META: ran handlers
META: ran handlers

PLAY RECAP *******************************************************************************************************************************************
apache1                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
apache2                    : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

````
9. Sprzątanie po warsztacie.

````bash
$ sudo docker-compose -f docker-compose_ansible.yml down
Stopping ansible-server ... done
Stopping apache-server-1 ... done
Stopping apache-server-2 ... done
Removing ansible-server ... done
Removing apache-server-1 ... done
Removing apache-server-2 ... done
Removing network meetup1_ansible
$ sudo rm -rf ./meetup1/
````
