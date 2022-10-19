English Wikipedia ACC provisioning
================================

Note: This code is not designed for Production use; currently this is **ENTIRELY** experimental.

### Setting up OAuth from scratch

If you're doing this from scratch, the playbook that's run to set up the instance should configure a fully-working MediaWiki instance you can use. Default credentials:
 * Username: `Admin`
 * Password: `AdminOAuth123!`

### WMCS deployment

You can't use Terraform, so you'll have to do this manually.

1. Shutoff the old instance and detach the cinder volumes.
2. Create a new instance with the settings below. If you're nervous about being able to complete the next two steps quickly, drop the `acc-provision` line from near the bottom of the userdata.
3. Attach the cinder volumes to the new instance
4. Create instance metadata called "publicdns" with value "accounts-oauth.wmflabs.org"
5. Update novaproxy to point to the new instance
6. Log into the box 
7. Check /var/log/cloud-init-output.log to make sure everything finished successfully. You should see "Cloud-init finished"
8. Run `acc-provision` if it wasn't run by userdata already.

Instance settings:
   * Name: accounts-mwoauthX
   * SecGroups: web, default
   * Flavour: g3.cores1.ram2.disk20
   * UserData: use the file `./userdata/oauth/userdata.sh` file.

## Application

### Provisioning database

1. Create the Cinder volumes
2. Create a new instance with the settings below. If you're nervous about being able to complete the next two steps quickly, drop the `acc-provision` line from near the bottom of the userdata.
3. Attach the cinder volumes to the new instance. Attach db disk first, then backup disk
6. Log into the box 
7. Check /var/log/cloud-init-output.log to make sure everything finished successfully. You should see "Cloud-init finished"
8. Run `acc-provision` if it wasn't run by userdata already.

Instance settings:
   * Name: accounts-dbX
   * SecGroups: database, default
   * Flavour: g3.cores1.ram2.disk20
   * UserData: use the file `./userdata/app/db-userdata.sh` file.

### Provisioning application

1. Create the Cinder volume
2. Create a new instance with the settings below. If you're nervous about being able to complete the next two steps quickly, drop the `acc-provision` line from near the bottom of the userdata.
3. Attach the cinder volume to the new instance.
6. Log into the box 
7. Check /var/log/cloud-init-output.log to make sure everything finished successfully. You should see "Cloud-init finished"
8. Run `acc-provision` if it wasn't run by userdata already.

Instance settings:
   * Name: accounts-appserverX
   * SecGroups: database, default
   * Flavour: g3.cores1.ram2.disk20
   * UserData: use the file `./userdata/app/app-userdata.sh` file.