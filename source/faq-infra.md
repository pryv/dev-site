---
id: faq
title: 'FAQ - infrastructure'
layout: default.pug
withTOC: true
---

In this FAQ we answer common questions related to Pryv.io platform. You can contact us directly if your question is not listed here.

## Table of contents <!-- omit in toc -->
<!-- no toc -->
- 1 [Platform prerequisites](#platform-prerequisites)
- 2 [Customize registration, login, password-reset pages](#customize-registration-login-password-reset-pages)
- 3 [Host apps, resources on the same domain, and reuse the SSL certificate](#host-apps-resources-on-the-same-domain-and-reuse-the-ssl-certificate)
- 4 [System administrators](#system-administrators)


## Platform prerequisites

In addition to the **Infrastructure procurement** guide (available on request), a Pryv.io platform requires its own **domain name**, such as `pryv.me` to work. Apps will access data through the https://${username}.${domain} endpoint, eg.: https://user-123.pryv.me. This can be totally hidden from the end user.

To encrypt data in transit, we require a **wildcard SSL certificate** for the domain **\*.domain**, this can be either bought or generated using [let's encrypt](https://letsencrypt.org/).

Since we use our own DNS servers to resolve the domain associated with the platform, it must be possible to **set name servers** for the domain. This must be verified before buying the domain, as some providers do not allow it.

### Do SSL certificates need to be signed by publicly trusted CA or can we use self-signed certificates?

All devices that interact with the Pryv.io platform must be able to verify the certificates and thus see/trust the CA, even if it is internal. That would involve: the mobile application, all machines that perform analytics and display of the data collected.

### SSL certificates are mentioned to be wildcard ones. Are we able to define all the subdomains beforehand and rather create SSL with SANs?

Pryv.io uses a subdomain per user account that is created. So no, you cannot use SAN certificates unless you're able to know the possible user base ahead of time.

### On what cloud offerings can Pryv.io be installed?

Pryv.io can be installed on any cloud offering that runs at least Docker 1.12.6. The real consideration here is compliance and the security of the data storage.

We have run Pryv.io on the following public clouds: AWS, Microsoft Azure, Gandi.net, Exoscale.ch, Joyent, Fengqi.asia.

### What constraints should be considered when choosing a host?

You must take into account the legislation covering the people whose data will be stored in the Pryv.io platform, such as US HIPAA, EU GDPR, Swiss DPA. This often includes requirements on the geographic location where the data is stored.

### How do you address encryption of the data at rest? As medical records will be stored in MongoDB, are you using DB encryption or some other application specific encryption?

Pryv offers three options here:

- Application-level end-to-end encryption: your application(s) that will access Pryv.io encrypt the data before sending it and can decrypt it after reading it back. Pryv.io provides a data type to include metadata concerning the encryption used by your application. See: <http://api.pryv.com/event-types/#encrypted>
- Disk encryption: Linux has a solid story of disk encryption. If stored on such a disk, Pryv data is encrypted at rest as well.

The last option will probably the easiest to implement. It offers good protection against disks being stolen from the datacenter, while not increasing overall system complexity by much.

### Self-managed top-domain

The DNS running on the register must resolve all requests for the domain. Entries in the top-domain will look like:

```
ns1-${DOMAIN} TTL_SECONDS IN A ${IP_ADDRESS_REGISTER_MACHINE_1}
ns2-${DOMAIN} TTL_SECONDS IN A ${IP_ADDRESS_REGISTER_MACHINE_2}

${DOMAIN}	TTL_SECONDS IN NS ns1-${DOMAIN}
${DOMAIN}	TTL_SECONDS IN NS ns2-${DOMAIN}
```

On single node or PoC installations, you will have only one register, both Type A entries for the machine will point to the same IP address:

```
ns1-${DOMAIN} TTL_SECONDS IN A ${IP_ADDRESS_REGISTER_MACHINE_1}
ns2-${DOMAIN} TTL_SECONDS IN A ${IP_ADDRESS_REGISTER_MACHINE_1}

${DOMAIN}	TTL_SECONDS IN NS ns1-${DOMAIN}
${DOMAIN}	TTL_SECONDS IN NS ns2-${DOMAIN}
```

You can verify that the register is set to resolve DNS queries for your domain using: `dig NS ${DOMAIN}`. The answer section must include:

```
${DOMAIN}		${TTL_SECONDS}	IN		NS		ns1-${DOMAIN}.${TOP_DOMAIN}
${DOMAIN}		${TTL_SECONDS}	IN		NS		ns2-${DOMAIN}.${TOP_DOMAIN}
```

## Customize registration, login, password-reset pages

We deliver the platform with default web apps for registration, login, password-reset and auth request. The code is available on https://github.com/pryv/app-web-auth3.

To customize it, fork the repository, make stub commit on the `gh-pages` branch to activate the [GitHub Pages](https://pages.github.com/).
Modify the NGINX configuration on the static-web machine `static/nginx/site.conf` (or `pryv/nginx/site.conf` for single node). Change line:

```
proxy_pass        https://pryv.github.io/app-web-auth3/;
```

to:

```
proxy_pass        https://${CUSTOMER_ACCOUNT}.github.io/app-web-auth3/;
```

and add the following in the sw.${DOMAIN} server scope:

```
if ($request_uri !~* "^/access/static/.*$") {
	rewrite ^.*$ /access/index.html;
}
```

The following pages will show the changes that you apply to this repository:

- Registration: https://sw.${DOMAIN}/access/register.html
- Reset password: https://sw.${DOMAIN}/access/reset-password.html
- Consent authorization: https://sw.${DOMAIN}/access/access.html

## Host apps, resources on the same domain and reuse the SSL certificate

The web role is meant for this. It contains a proxy server that can be configured to serve apps from different sources such as GitHub pages under the same domain, thus allowing to reuse the SSL certificate.

Using the web role, apps can be served on any path from the hostname https://sw.${DOMAIN}/ such as https://sw.${DOMAIN}/MY_APP/.

This is done by adding the following `location` clause in the `pryv/nginx/conf/site.conf` file:

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

### Port 53 is already in use (by Docker's embedded DNS)

On some installations, the DNS container cannot be started because docker-compose attempts to bind on the same network interface and port as Docker's embedded DNS.  
To fix this, you must specify the external network interface IP address (which may differ from the machine's public IP address, for example on AWS) in the docker-compose port mapping section of the DNS service as following:

```yaml
ports:
	- "EXTERNAL_INTERFACE_IP_ADDRESS:53:5353/udp"
```

### docker login X11 error

On a Pryv install using Ubuntu 18.X when running `docker login`: Ubuntu refuses to let you enter the password because it wants you to use a secure means of password entry. The error reads something like 'Cannot autolaunch D-Bus without X11 \$DISPLAY' ([docker-compose issue #6023](https://github.com/docker/compose/issues/6023)).
Our workaround is:

```
sudo apt-get remove golang-docker-credential-helpers
sudo apt install docker-compose
```

The second line is needed because the first removes docker-compose as well.

### Are my containers running?

Show running containers: "docker ps", if the container exited, you can use "docker ps -a". This will allow to find the name of the container.

### Why is container XYZ not running?

By default, our containers write logs into `stdout`, the reason for a failure can be printed using `docker logs ${CONTAINER_NAME}`.

### Permission denied error

During deployment and update, it is possible that some folders have incorrect permissions, preventing the Pryv.io process to read configuration and data files.  
The corresponding error can be found in the container logs using:

```
docker logs -f --tail 50 pryvio_${CONTAINER_NAME}
```

It should have a message similar to:

```
Error: EACCES: permission denied
```

This can be fixed by running the provided `ensure-permissions-${ROLE}` script. If necessary, reboot the Pryv.io services as well.

### How do I reset data on my Pryv.io platform?

This step will erase all data from your platform. Perform this at your own risk and make sure that you know what you are doing.

To erase all data on the platform, you need to delete the contents of the data folders and reboot the services.

On the register master:

```bash
cd ${PRYV_CONF_ROOT}
./stop-config-leader
./stop-pryv
rm -rf pryv/redis/data/*
rm -rf config-leader/database/*
./run-config-leader
./run-pryv
```

On core:

```bash
cd ${PRYV_CONF_ROOT}
./stop-pryv
rm -rf pryv/core/data/*
rm -rf pryv/mongodb/data/*
rm -rf pryv/influxdb/data/*
./run-pryv
```

### How can I use the demo dashboard app (_app-web_) on my Pryv.io platform?

App-web is hosted on GitHub pages and can be used for your Pryv.io platform as described in [its documentation](https://github.com/pryv/app-web#usage).
