English Wikipedia ACC provisioning
================================

Note: This code is not designed for Production use; currently this is mostly experimental.

## OAuth test server 
You'll need an AWS account. You can optionally use a Linode DNS-hosted zone as well if you want a nice hostname.

### AWS
If you already use the AWS CLI, this may be already set up for you. These instructions are also intended for a Linux system; if you're on Windows/Mac, you're on your own.

1. Create a folder in your home directory called `~/.aws`
2. In that folder, create two files - `config` and `credentials`
3. In `config`, place the following configuration: 
```
[default]
region = eu-west-1
```
4. In credentials, place the following configuration (substituting your own credentials in place of the example below):
```
[default]
aws_access_key_id = AKIAYZOJRTJVW6KVXOG2
aws_secret_access_key = l4cLg+gobWkPQrX8BmHg/jlXw4d+ZE0gRH05RVm8
```

### Linode
These instructions are also intended for a Linux system; if you're on Windows/Mac, you're on your own.

Create a file called `~/.config/linode` with the following content (substituting your Linode API token in place of the example below)

```
[default]
token = ab551158c5126e9328062b846b3fdae121dd0df9f6ec3efac6c33bfe752c6019
```

### Provisioning stuff

Go to aws-prereqs, and tweak the parameters in `terraform.tfvars` as you need to - it's better to do this by copying the file to `something.auto.tfvars`, and making changes there.

When ready, run `terraform init` followed by `terraform apply`. This should create a VPC for everything to deploy into.

Then go to oauth-aws, tweak the parameters in `terraform.tfvars` as you need to, and `terraform init` and `terraform apply` your way to infrastructure. You should get a DNS name given to you which you should be able to throw into a browser.

If you use Linode for your DNS, you can specify the name of the zone and the name of the record to be created as a CNAME for your instance.

### Setting up OAuth from scratch
Not yet done, good luck.

### WMCS deployment

You can't use Terraform, so you'll have to do this manually.

1. Shutoff the old instance and detach the cinder volumes.
2. Create a new instance with the settings below
3. Attach the cinder volumes to the new instance
4. Create instance metadata called "publicdns" with value "accounts-oauth.wmflabs.org"
5. Update novaproxy to point to the new instance
6. Log into the box 
7. Check /var/log/cloud-init-output.log to make sure everything finished successfully
8. Run `acc-provision`

Instance settings:
   * Name: accounts-mwoauthX
   * SecGroups: web/default
   * Flavour: g3.cores1.ram2.disk20
   * UserData: use the contents of the ./ansible/oauth-wmcs-userdata.sh file.
