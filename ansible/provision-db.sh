#!/bin/bash

echo "Starting provision..."

if [[ "$1" == "--sync" ]]; then 
    cd /opt/provisioning/ansible
    sudo git config pull.ff only
    sudo git pull

    exec acc-provision
fi

### fetch disk type for this cloud
disktype=sd

if ls /dev | grep -P '^xvd' >/dev/null; then
    disktype=xvd
fi

### run playbooks

if stat /dev/${disktype}b >/dev/null && stat /dev/${disktype}c >/dev/null; then
    ansible-playbook -i localhost, -c local -b /opt/provisioning/ansible/db.yml -e disktype=$disktype
else
    echo "Required disks not yet mounted, not running automatic provisioning."
fi
