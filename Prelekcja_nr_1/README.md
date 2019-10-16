

Lest see scenario:
w1 – test machine
w2,w3 – production machine

Let’s make deployment for a new released web site: index.zip

1. Install apache httpd on test environment
2. Unzip package with web content to /var/www/html (remember about permissions – unarchive module)
3. Make template of index.html and change it on server Put server name and IP after #TODO (template module)

4. Check it: web page working correctly (see ansible loops 2nd example)

If change goes properly perform it on production env in canary deployment (one server in one time) – serial option – google it

5. Same steps as before (remember about when clausule – distro == debian or distro == RedHat)
