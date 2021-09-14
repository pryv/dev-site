---
id: ssl-certificate
title: 'Pryv.io SSL Certificate'
template: default.jade
customer: true
withTOC: true
---

This document describes how to generate a wildcard SSL certificate using [Let's Encrypt](https://letsencrypt.org/) and Pryv.io's DNS.

The prerequisites for this are that you have [obtained a domain name](/customer-resources/pryv.io-setup/#obtain-a-domain-name) and [installed the Pryv.io platform](/customer-resources/pryv.io-setup/#set-the-platform-parameters).  
If you are using an infrastructure with appliances that perform the SSL termination, you can simply adapt the NGINX configuration files to listen on port 80 and not perform encryption.

## Certbot Installation

- [Reference](https://certbot.eff.org/lets-encrypt/ubuntuxenial-other)

This procedure describes the commands for Ubuntu 16.04.  
If you are using another OS, go to the reference link, choose *software: None of the above* and your OS and follow the installation instructions.

```bash
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install certbot
```

## Generate certificate using DNS validation

- [Reference](https://certbot.eff.org/docs/using.html#manual)

Make sure your DNS supports the Let's Encrypt CAA by verifying that it has this field in its platform variables:

```yaml
  ADVANCED_API_SETTINGS:
    optional: true
    name: "Advanced API settings"
    settings:
      SSL_CAA_ISSUER:
        value: letsencrypt.org
        description: "Certificate authority allowed to issue SSL certificates for this domain"
```

If you are not familiar with this process, it is recommended to do a dry-run as the Let's Encrypt API has a call limit, which may block you in case of multiple failed attempts.  
For this, append `--dry-run` to the command below. Once it works, simply repeat it without `--dry-run`.

Launch the process using:  

```bash
certbot certonly --manual --preferred-challenges dns
```

When prompted for the domain, enter `*.${DOMAIN}` and accept to share the IP address by pressing `ENTER`.

Now, the CLI will ask you to set a certain key to the TXT Record `_acme-challenge`. Enter it in the platform variables by adding the following field as following:

```yaml
  DNS_SETTINGS:
    name: "DNS settings"
    settings:
      DNS_CUSTOM_ENTRIES:
        description: "Additional DNS entries. See the DNS configuration document: https://api.pryv.com/customer-resources/#guides-and-documents.
        Can be set to null if not used."
        value:
          _acme-challenge:
            description: "KEY"
```

And reboot the follower and Pryv.io services:

```bash
./restart-config-follower
./restart-pryv
```

Verify that the key is querying the name servers.  

If you are running a single-node platform or cluster with a single DNS, you can run:  

```bash
dig @reg.${DOMAIN} TXT _acme-challenge.${DOMAIN}
```

If you are running a cluster platform with more than one DNS, run:

```bash
dig @${NS1_HOSTNAME} TXT _acme-challenge.${DOMAIN}
dig @${NS2_HOSTNAME} TXT _acme-challenge.${DOMAIN}
```

Once you get the right key, go back to the CLI and press ENTER.

You should now have a certificate in `/etc/letsencrypt/live/${DOMAIN}/`.

## Reorganize SSL certificate files

Rename the files to match the NGINX settings:

```bash
mv fullchain.pem ${DOMAIN}-bundle.crt
mv privkey.pem ${DOMAIN}-key.pem
```

You might have to copy them as `live/` holds symbolic links.

Then copy them into:  

```bash
${PRYV_CONF_ROOT}/config-leader/data/${ROLE}/nginx/conf/secret/
```

with `${ROLE}` being:

- `singlenode`

OR

- `core`
- `reg-master`
- `reg-slave`
- `static`

Make sure that the certificates permissions are set correctly: 

```bash
./ensure-permissions --ignore-redis
```

And reboot the follower and pryv services: 

```bash
./restart-config-follower
./restart-pryv
```
