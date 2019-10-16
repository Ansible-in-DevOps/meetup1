r_httpd_app
=========

Role is responsible for deployment simple application on apache httpd server

Requirements
------------

Internet connection with access

Role Variables
--------------
Inventory variables:
--------------
| Name              | Example Value       | Description          |
|-------------------|---------------------|----------------------|
|WEBSITE_PACKAGE|index.zip|Package to deploy|

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: prod
      vars:
        WEBSITE_PACKAGE: "index.zip"
      serial:
        - 1   
        - 50%
      roles:
        - r_httpd_app


License
-------

BSD

Author Information
------------------

daca444@gmail.com
