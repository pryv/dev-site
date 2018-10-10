---
id: faq
title: "FAQ - infrastructure"
template: default.jade
withTOC: true
---

## Platform prerequisites

Additionally to the **Deployment design guide** document, a Pryv.IO platform requires its own **domain name**, such as pryv.me to work. Apps will access data through the https://${username}.${domain} endpoint, eg.: https://cobra.pryv.me, this can be totally hidden from the end user.

For communication encryption, we require a **wildcard SSL certificate** for the domain ***.domain**, this can be either bought for around ~100CHF/year or generating one using [let's encrypt](https://letsencrypt.org/), this can currently be done manually, but will be automated in future versions.

Since we use our own DNS servers to resolve the domain associated with the platform, it must be possible to **set name servers** for the domain. This must be verified before buying the domain, as some providers do not allow it.

### Do SSL certificates need to be signed by publicly trusted CA or can we use self-signed certificates?

All devices that interact with the Pryv installation must be able to verify the certificates and thus see/trust the CA, even if it is internal. In this project, that would involve: the mobile application, all machines that perform analytics and display of the data collected.

### SSL certificates are mentioned to be wildcard ones. Are we able to define all the subdomains beforehand and rather create SSL with SANs?

Pryv uses a subdomain per user account that is created. So no, you cannot use SAN certificates unless you're able to know the possible user base ahead of time.

### On what cloud offerings can Pryv IO be installed

Pryv can be installed on any cloud offering that runs at least Docker 1.12.6. The real consideration here is compliance and the security of the data storage.

We have run Pryv.IO on the following public clouds: AWS, Azure, Gandi.net, Exoscale.ch, Joyent, Fengqi.asia.

### What constraints should be considered when choosing a host

where (in what countries legislation) the data is stored. should be HIPPA/EU DPD compliant…

### How do you address encryption of the data at rest? As medical records will be stored in the MongoDB, are you using DB encryption or some other application specific encryption?

Pryv offers three options here:

- Application-level end-to-end encryption: The application(s) that access Pryv encrypt the data that is stored in Pryv on creation and decrypt it after reading it back. Pryv provides a data type for this usage. See: <http://api.pryv.com/event-types/#encrypted>
- MongoDB encryption: We can provide you with a recent release of MongoDB that will allow you to set up EAR: <https://docs.mongodb.com/manual/core/security-encryption-at-rest/>
- Disk encryption: Linux has a solid story of disk encryption. If stored on such a disk, Pryv data is encrypted at rest as well.

My take on this is that the last option will probably the easiest to implement. It offers good protection against disks being stolen from the datacenter, while not increasing overall system complexity by much.

### Self-managed top-domain

The DNS running on the registry must resolve all requests for the domain. Entries in the top-domain will look like:

```
ns1-domain TTL_SECONDS IN A IP_ADDRESS_REGISTER_MACHINE_1
ns2-domain TTL_SECONDS IN A IP_ADDRESS_REGISTER_MACHINE_2

subdomain	TTL_SECONDS IN NS ns1-domain
subdomain	TTL_SECONDS IN NS ns2-domain
```

On single node or PoC installations, you will have only one registry, both Type A entries for the machine will point to the same IP address:

```
ns1-domain TTL_SECONDS IN A IP_ADDRESS_REGISTER_MACHINE_1
ns2-domain TTL_SECONDS IN A IP_ADDRESS_REGISTER_MACHINE_1

subdomain	TTL_SECONDS IN NS ns1-domain
subdomain	TTL_SECONDS IN NS ns2-domain
```

## Customize registration, login, password-reset pages

We deliver the platform with default web apps for registration, login, password-reset and auth request. The code is available on https://github.com/pryv/app-web-auth2.

To customize it, fork the repository, create a symlink `ln -s v2/ ${DOMAIN}` on the `gh-pages` branch as seen [here](https://github.com/pryv/app-web-auth2/tree/gh-pages) and modify the NGINX configuration on the static-web machine `static/nginx/site.conf` (or `pryv/nginx/site.conf` for single node). Change line:

```
proxy_pass        https://pryv.github.io/app-web-auth2/${DOMAIN}/;
```

to:

```
proxy_pass        https://${CUSTOMER_ACCOUNT}.github.io/app-web-auth2/${DOMAIN}/;
```

## How to host apps, resources on the same domain / reuse the SSL certificate

The web role is meant for this. It contains a proxy server that can be configured to serve apps from different sources such as GitHub pages under the same domain, thus allowing 

Using the web role, apps can be served on any path from https://sw.${DOMAIN}/...

This is done by addding the following `location` clause in the `pryv/nginx/conf/site.conf` file:

```
server {
 	listen               443;
 	server_name          sw.DOMAIN;
  
  //...
  
	location /MY_APP/ {
    	proxy_pass            MY_APP_URL_WITH_PROTOCOL;
    	proxy_set_header      X-Real-IP $remote_addr;
    	proxy_set_header      X-Forwarded-For $proxy_add_x_forwarded_for;
    	proxy_buffering       off;
  	}
}
```

## System administrators

### Are my containers running?

Show running containers: "docker ps", if the container exited, you can use "docker ps -a". This will allow to find the name of the container.

### Container XYZ is not running

The issue is most probably with NGINX, which crashes if it cannot find the SSL certificate files. You can see this if its container doesn't appear when running "docker ps" and shows the file path related error when running "docker logs CONTAINER_NAME".

### Permission denied error

`chown -R 9999:9999 pryv/nginx/log`

### print logs

"docker logs -f --tail 50 CONTAINER_NAME"

### Reset data

To erase all data on the platform, you need to delete the contents of the data folders and reboot the services.

On the registry:

- `cd PRYV_CONF_ROOT`

- `./stop-containers`
- `rm -rf /var/pryv/reg-master/redis/data/*`
- `./run-reg-master`

On core:

- `cd PRYV_CONF_ROOT`

- `./stop-containers`
- `rm -rf /var/pryv/core-v1.3/core/data/*`
- `rm -rf /var/pryv/core-v1.3/mongodb/data/*`
- `./run-core-v1.3`

## Do you have a test setup where this could be tested?

You can try out Pryv IO, using our demo platform pryv.me: https://pryv.com/pryvlab/

## I wish to adapt the dashboard app shown in the demo

App-web is by default delivered with Pryv.IO, but is not part of the product. Some features available on the demo pryv.me platform are not available here such as: integrations with 