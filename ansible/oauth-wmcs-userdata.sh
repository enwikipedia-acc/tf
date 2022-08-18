#!/bin/bash -e
apt-get update
apt-get install -q -y git ansible jq
mkdir -p /opt/provisioning
git clone https://github.com/enwikipedia-acc/tf.git /opt/provisioning
cd /opt/provisioning/ansible

ln -s /opt/provisioning/ansible/provision-oauth.sh /usr/local/bin/acc-provision
chmod a+rx /opt/provisioning/ansible/acc-provision.sh
