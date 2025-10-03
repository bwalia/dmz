Role Name
=========

A dmz builds nginx from source with lua dynamic scripts to allow it to be integrated with Consul and other service mesh solutions for HA

Requirements
------------

- Ubuntu >= 22.04
- Openresty source
- lua
- lua modules to interact with DNS, SSL. IP TO COUNTRY DATABASE etc.


Role Variables
--------------

A dmz rely on various ENV variables in Ansible preset to work
A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

Dependencies
------------

*** Needs to be updated ***


- A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.


Production Nodes
--------------

- Install Control plane in kubernetes cluster (k3s (arxus), rke2 (arxus or DP side or azure), or aks for prod on HD side)

 Production DMZ - AKS cluster
 Load Balancer IP setup for Netscaler traffic to be passed directly to the DMZ or Nginx Legacy style config.



Run Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }


Test was done by BW at his home lab k3s and rke2 cluster. Documentation provided on confluence to learn more about the DMZ project

Node 2:

`ansible-playbook devops/ansible/manage_nginx_openresty_ops.yml --tags=nginx -i devops/ansible/hosts -l 10.72.131.2 --ask-vault-pass`

Node 3:

`ansible-playbook devops/ansible/manage_nginx_openresty_ops.yml --tags=nginx -i devops/ansible/hosts -l 10.72.131.3 --ask-vault-pass`

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
