---
id: app-guidelines
title: 'App guidelines'
template: default.jade
customer: true
withTOC: true
---

In this guide we address developers that wish to initialize their Pryv.io platform.
It walks you through the different steps that have to be implemented in order to set up your platform.

## Table of contents

1. [Set up the machines](#set-up-the-machines)
2. [Obtain a domain name](#obtain-a-domain-name)
3. [Obtain the license, credentials and config files](#obtain-the-license-credentials-and-config-files)
4. [Set the platform variables](#set-the-platform-variables)
5. [Obtain an SSL certificate](#obtain-an-SSL-certificate)
6. [Validate your platform installation](#validate-your-platform-installation)
7. [Set up the platform health monitoring](#set-up-the-platform-health-monitoring)
8. [Fork the app-web-auth3 repositery](#fork-the-app-web-auth3-repositery)
9. [Define your data model](#define-your-data-model)
10. [Other documents](#other-documents)


## Set up the machines

You need first to decide which hardware or virtual machines you will provision to host your Pryv.io instance. 

The [Deployment Design Guide](https://api.pryv.com/assets/docs/deployment_design_guide_v6.pdf) for the Pryv.io middleware will guide you for the provisionning and deployment of your machines.

It will help you with the design of your Pryv.io deployment (single node or cluster), and provide you with cluster sizing considerations. 

The system requirements for each machine are also specified.


## Obtain a domain name

Now that your Pryv.io instance is deployed on your machines, you need to register your own domain name.

You can either : 
- obtain one yourself through a domain name registrar of your choice ;
- or contact us directly to obtain a domain name with pryv.io, e.g. ***yourdomainname*.pryv.io**.


## Obtain the license, credentials and config files

In order to be able to run your Pryv.io instance, you will need to get a license from Pryv and the credentials to pull the Docker images.

You can ask us directly to obtain the license and the credentials.

The template configuration files for a Pryv.io installation can be found [here](https://github.com/pryv/config-template-pryv.io/tree/central/pryv.io). The template files will be different depending if you have chosen a [single node](https://github.com/pryv/config-template-pryv.io/tree/central/pryv.io/single-node) installation, or a [cluster](https://github.com/pryv/config-template-pryv.io/tree/central/pryv.io/cluster) installation.

## Set the platform variables

You will find the settings for the platform variables in the [following file](https://github.com/pryv/config-template-pryv.io/blob/central/pryv.io/single-node/config-leader/conf/platform.yml).

It describes all the platform variables, API settings and other optional variables that you need to replace.

## Obtain an SSL certificate

You need to obtain an SSL certificate for your domain.

You can do so by using a web host that integrates SSL and configures HTTPS for you, or by getting an SSL certificate from a Certificate Authority (CA).

## Validate your platform installation

Now that your Pryv.io platform is installed, you might want to validate that it is up and running.
The [Validation document for Pryv.io installation](https://api.pryv.com/assets/docs/20190131-pryv.io-verification-v3.pdf) will walk you through the validation steps of your platform and contains a troubleshooting part in case of validation failure.

## Set up the platform health monitoring

As your Pryv.io platform is up and running, you can monitor its status by performing regular healthcheck API calls to the Pryv.io API.

The procedure for the platform health monitoring is described in the [Pryv.io Healthchecks document](https://api.pryv.com/assets/docs/20190201-API-healthchecks-v4.pdf).

## Fork the app-web-auth3 repositery

Your Pryv.io platform is now launched and ready to be used.

You will need to authenticate users in your app, and grant your app access to your users' data by authorizing your app.
We provide you with template web pages for app authorization, user registration and password reset that can be customized and adapted for each Pryv.io platform in our **app-web-auth3 template app**. 

This sample application, developed with Vue.js, provides a starting point to implement your own authorization or consent flow application. 

You might want to fork this repository from Github [here](https://github.com/pryv/app-web-auth3), and modify the code to fit your needs if you want to allow third party applications to interact with your platform.

## Define your data model

As your Pryv.io platform is operational and your app is authorized, you can start collecting data.

To do so, you need to design your own model and structure your data under Pryv's conventions using **streams** and **events**.

We will help you with the creation of your data model in our [Data modelling guide](https://api.pryv.com/guides/data-modelling/) which describes Pryv.io data structure and walks you through different use cases for your data model.

## Other documents

More resources can be found in our [Customer Resources page](https://api.pryv.com/customer-resources/#documents), or in the [FAQ](https://api.pryv.com/faq-infra/).

