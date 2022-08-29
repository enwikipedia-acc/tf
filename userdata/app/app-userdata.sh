From nobody Thu Jan  1 00:00:00 1970
Content-Type: multipart/mixed; boundary="==BOUNDARY=="
MIME-Version: 1.0

--==BOUNDARY==
MIME-Version: 1.0
Content-Type: text/x-shellscript; charset="us-ascii"
#cloud-config
version: v1
packages_update: true
packages_upgrade: true
packages:
  - ansible
  - git
  - jq

--==BOUNDARY==
MIME-Version: 1.0
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash -ex

git clone https://github.com/enwikipedia-acc/tf.git /opt/provisioning

ln -sf /opt/provisioning/ansible/provision-app.sh /usr/local/bin/acc-provision

acc-provision

--==BOUNDARY==--