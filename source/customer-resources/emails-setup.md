---
id: Email configuration
title: 'Pryv.io email configuration'
template: default.jade
customer: true
withTOC: true
---

This document describes how to configure the settings for the sending of email for:

- Account creation,
- Password reset requests.

The prerequisite for this is to have a running Pryv.io platform. Refer to the [Pryv.io setup guide](/customer-resources/pryv.io-setup/) for its installation.

The email settings are to be set either directly through the platform settings configuration file `platform.yml` or through the admin panel.

## Transport

Emails can be sent using:

- sendmail
- your SMTP server
- Mandrill (deprecated)

### Sendmail

Sendmail is useful for development purposes and not recommended for production. To activate it, set `EMAIL_SENDMAIL_SETTINGS`:  

in the platform.yml file:  

```yaml
EMAIL_SENDMAIL_SETTINGS:
  description: "Alternative transport, using sendmail. Will replace SMTP transport if set to true"
  value:
    active: true
```

or in the admin panel:

```json
{
  "active": true
}
```

This will override the SMTP settings.

### Your own SMTP server

For production purposes, we strongly recommend to setup your own SMTP server. To activate its usage, disable sendmail as described above and set `EMAIL_SMTP_SETTINGS`:

in the platform.yml file:

```yaml
EMAIL_SMTP_SETTINGS:
  description: "If used, Host, port and credentials of the SMTP server"
  value:
    host: your-smtp-server-hostname
    port: your-smtp-server
    auth:
      user: REPLACE_ME
      pass: REPLACE_ME
```

in the admin panel:  

```json
{
  "host": "your-smtp-server-hostname",
  "port": "your-smtp-server",
  "auth": {
    "user": "REPLACE_ME",
    "pass": "REPLACE_ME"
  }
}
```

## Email settings

### Activation

You can choose whether to activate or not the **welcome** and **password reset** emails setting `EMAIL_ACTIVATION`:  

in the platform.yml file:

```yaml
EMAIL_ACTIVATION:
  description: "Allows to activate/deactivate sending of welcome and password reset emails"
  value: 
    welcome: true
    resetPassword: true
```

in the admin panel:  

```json
{
  "welcome": true,
  "resetPassword": true
}
```

### Sender

You can define the email sender name and email address setting `EMAIL_SENDER`:  

in the platform.yml file:

```yaml
EMAIL_SENDER:
  description: "Sender name and email address"
  value: 
    name: REPLACE_ME
    address: REPLACE_ME
```

in the admin panel:  

```json
{
  "name": "Pryv Lab no reply",
  "address": "no-reply@pryv.com"
}
```

#### Using your Pryv.io domain

SMTP servers use SPF records to help prevent email spooFing. In order to send an email on behalf of a certain domain, you will need to add the SPF record associated with your SMTP server to your domain's DNS zone.  
If you choose to use the domain associated with your Pryv.io platform, you should add a SPF record similar to this one:

```
@ 10800 IN TXT "v=spf1 include:spf.mandrillapp.com ~all"
```

In the SPF record above, we declared that Mandrill can be used to send emails on behalf of the domain of our Pryv.io platform.
You can of course replace Mandrill by the SPF address of the SMTP host(s) of your choice.

Please refer to [the DNS configuration document](https://api.pryv.com/customer-resources/#guides-and-documents) on how to set such SPF record in the Pryv.io DNS.

### Email template default language

You can set the default language for the template that will be applied if you do not provide a `language` field in the [Create user API method](/reference/#create-user), by setting `EMAIL_TEMPLATES_DEFAULT_LANG`:  

in the platform.yml file:

```yaml
EMAIL_TEMPLATES_DEFAULT_LANG: 
  value: en
  description: "Default language for email templates eg: en"
```

in the admin panel:  

```json
en
```

## Templates

Pryv.io currently supports email templates in 3 languages. They can be provided in [pug](https://pugjs.org/api/getting-started.html) format, a templating language for HTML. These templates can be set in the platform.yml file or through the admin panel:

### Welcome

The welcome template accepts the following variables:

- USERNAME

```
<img src="https://api.pryv.com/style/images/logo-256.png" alt="Logo"> 
<h1><span style="color:#bd1026">Hey</span> #{USERNAME},</h1>
<h2><span style="color:#bd1026">Thanks for creating your Pryv account</span></h2>
```

### Password reset

The welcome template accepts the following variables:

- RESET_URL, a web application that will prompt the user for a new password and use it to make the [reset password API method](/reference/#reset-password)
- REST_TOKEN, to be used in the [reset password API method](/reference/#reset-password)

```
p Hi,
p We have received word that you have lost your password. If you have asked for a password request please click on the link below. If you did not please delete this email.
p <a href="#{RESET_URL}?resetToken=#{RESET_TOKEN}" target="_blank">Click here</a> to reset your Pryv password.
p Pryv team 
```

## Previous version

The previous guide for email configuration is still available [here](/assets/docs/20190508-pryv.io-emails-v4.pdf).
