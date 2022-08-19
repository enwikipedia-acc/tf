#!/bin/bash -ex
apt-get -o DPkg::Lock::Timeout=120 update
apt-get -o DPkg::Lock::Timeout=120 install -q -y git ansible jq
mkdir -p /opt/provisioning
git clone https://github.com/enwikipedia-acc/tf.git /opt/provisioning

ln -sf /opt/provisioning/ansible/provision-oauth.sh /usr/local/bin/acc-provision
chmod a+rx /opt/provisioning/ansible/provision-oauth.sh
