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

### fetch target hostname

# AWS with Linode?
urlScheme=https
dnsName=$(curl -f http://169.254.169.254/latest/meta-data/tags/instance/publicdns 2>/dev/null)
if [[ $? -ne 0 ]] || [[ "${dnsName}" == "." ]]; then
    # openstack?
    dnsName=$(curl -f http://169.254.169.254/openstack/latest/meta_data.json 2>/dev/null | jq -r .meta.publicdns)

    if [[ $? -ne 0 ]] || [[ "${dnsName}" == "" ]]; then
        # plain AWS?
        dnsName=$(curl -f http://169.254.169.254/latest/meta-data/public-hostname 2>/dev/null)
        urlScheme=http

        if [[ $? -ne 0 ]]; then
            # welp.
            dnsName=localhost
        fi
    fi
fi


echo "Using ${urlScheme}://${dnsName}/ as public endpoint."

### run playbooks

if stat /dev/${disktype}b >/dev/null && stat /dev/${disktype}c >/dev/null; then
    ansible-playbook -i localhost, -c local -b /opt/provisioning/ansible/oauth.yml -e disktype=$disktype -e wgServer=$dnsName -e urlScheme=$urlScheme
else
    echo "Required disks not yet mounted, not running automatic provisioning."
fi
