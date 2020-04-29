---
id: pryv.io-setup
title: 'Pryv.io platform setup guide'
template: default.jade
customer: true
withTOC: true
---

In this guide we address IT operators that wish to install their Pryv.io platform.
It walks you through the different steps that have to be performed in order to set up your platform.

## Table of contents

- 1 [Set up the machines](#set-up-the-machines)
- 2 [Obtain a domain name](#obtain-a-domain-name)
- 3 [Obtain the license key, credentials and config files](#obtain-the-license-key-credentials-and-config-files)
- 4 [Set the platform parameters](#set-the-platform-parameters)
- 5 [Obtain an SSL certificate](#obtain-an-ssl-certificate)
- 6 [Validate your platform installation](#validate-your-platform-installation)
- 7 [Set up the platform health monitoring](#set-up-the-platform-health-monitoring)
- 8 [Customize authorization, registration and reset password apps](#customize-authorization-registration-and-reset-password-apps)
- 9 [Set up email sending](#set-up-email-sending)
- 10 [Define your data model](#define-your-data-model)
- 11 [Other documents](#other-documents)

## Set up the machines

You need first to define which hardware or virtual machines you will provision to host your Pryv.io instance.  

The **Deployment design guide** for the Pryv.io middleware from the [Customer Resources page](https://api.pryv.com/customer-resources/#documents) will guide you for the provisionning and deployment of your machines.

It will help you with the choice of your Pryv.io deployment (single node or cluster), and provide you with resources sizing considerations.  

The system requirements for each machine are also specified.

## Obtain a domain name

Now that your machines are ordered, you need to register your own domain name.

You can either:  

- obtain one yourself through a domain name registrar of your choice, make sure that you can configure your domain's name servers.
- or contact us directly to obtain a pryv.io subdomain, e.g. ***your-platform-name*.pryv.io**

You will need to obtain an additional one for your staging development, and pre-production if you have one.

## Obtain the license key, credentials and configuration files

In order to be able to run your Pryv.io instance, you will need to get a license key for your platform from Pryv and the credentials to pull the Docker images defined in the configuration files.

## Set the platform parameters

Along with the configuration files, you will find an Installation guide describing where to unpack them and how to set the platform variables.

## Obtain an SSL certificate

You will need to obtain a wildcard SSL certificate for *.DOMAIN to enable encryption to the platform's API. For this, you can either obtain one from your hosting provider, or generate one using LetsEncrypt, for which we can provide you a quick guide.

We have automatic SSL certificate renewal on our roadmap, so let us know if you are interested.

## Validate your platform installation

Now that your Pryv.io platform is configured and running, you can run the validation procedure from the [Pryv.io platform validation guide](/customer-resources/platform-validation).

It will walk you through the validation steps of your platform and contains a troubleshooting part in case of issue.

## Set up the platform health monitoring

You can monitor its status by setting up regular healthcheck API calls to the Pryv.io API.

The procedure for the platform health monitoring is described in the [Pryv.io Healthchecks guide](/customer-resources/healthchecks).

## Customize authorization, registration and reset password apps

In order to perform the [authorization procedure](/reference/#authorizing-your-app), a web page is necessary. We provide a template web app for this as well as for other functions such as registration and password reset. You can find the code repository on [github.com/pryv/app-web-auth3](https://github.com/pryv/app-web-auth3).

In order to customize your own, we suggest that you fork this repository and host the web app on your environment. The easiest way to begin is to fork it on GitHub and host it using GitHub-pages.

To use your own page, you will have to update the following platform variables:

- TRUSTED_AUTH_URLS
- TRUSTED_APPS

You will then need to provide your web page's URL in the [Auth request](/reference/#auth-request) `authUrl` parameter, or if you want to make it default, change the `DEFAULT_AUTH_URL` in the platform variables.

**We urge you to fork this web application even if you don't wish to customize it as it follows the versioning of the Pryv Lab platform and may incur breaking changes during updates.**

### GH pages

Make sure to implement the [following change](https://github.com/pryv/app-web-auth3/blob/master/README.md#fork-repository-for-github-pages) on your fork.

If you are hosting it on GitHub pages, you will need to adapt the platform variables as following:

```yaml
  TRUSTED_APPS: "*@https://*.DOMAIN*, *@https://pryv.github.io*, *@https://YOUR-GITHUB-ACCOUNT.github.io*"
  TRUSTED_AUTH_URLS:
    - "https://sw.DOMAIN/access/access.html"
    - "https://YOUR-GITHUB-ACCOUNT.github.io/app-web-auth3/access/access.html"
```

If you wish to make it default, you must additionally set as following:

```yaml
  DEFAULT_AUTH_URL: "https://YOUR-GITHUB-ACCOUNT.github.io/app-web-auth3/access/access.html"
```

### Your own server

If you are hosting it on your own server, you will need to adapt the platform variables as following:

```yaml
  TRUSTED_APPS: "*@https://*.DOMAIN*, *@https://pryv.github.io*, *@https://YOUR-SERVER-DOMAIN*"
  TRUSTED_AUTH_URLS:
    - "https://sw.DOMAIN/access/access.html"
    - "https://YOUR-SERVER-URL/access/access.html"
```

If you wish to make it default, you must additionally set as following:

```yaml
  DEFAULT_AUTH_URL: "https://YOUR-SERVER-URL/access/access.html"
```

## Set up email sending

Pryv.io allows to send emails in two situations:

- Account creation,
- Password reset requests.

You might want to install and configure the sending of emails in these situations. You can do so by either using your SMTP server, or Sendmail.

In both cases, you will need to customize settings in the "Email configuration" section of the platform parameters file.

You can also customize the email templates in the configuration files.

More details are provided in the **Emails configuration guide** that can be found in the [Customer Resources section](https://api.pryv.com/customer-resources/#documents).

## Define your data model

As your Pryv.io platform is fully operational, you can start collecting data.

To do so, you need to design the data model your app(s) will use using Pryv's data structures: **streams** and **events**.

You can have a look at our [Data modelling guide](https://api.pryv.com/guides/data-modelling/) which describes the Pryv.io data structure and walks you through different use cases for your data model.

We can also help you with the design and validation of your data model.

## Other documents

More resources can be found in our [Customer Resources page](https://api.pryv.com/customer-resources/#documents), or in the [FAQ](https://api.pryv.com/faq-infra/).