---
id: open-api-3
title: 'Open API 3.0'
template: default.jade
customer: true
withTOC: true
---

# Definition file

Here is the Pryv.io API in OpenAPI 3.0 format: [api.yaml](/open-api/3.0/api.yaml).

This OpenAPI document describes the Pryv.io API and conforms to the OpenAPI Specification. It is represented in YAML format and can be downloaded from the above link to be imported on other API tools such as Postman.

# Usage

## Postman

### Import

The OpenAPI description of Pryv.io can be directly imported into Postman to test the API's functionality. 


- **1.** If Postman has not yet been installed on your computer, you can download it from [here](http://www.getpostman.com). 
- **2.** In the Postman app, click `Import` to bring up the following screen:

![Import on Postman](/assets/images/import.png)

You can choose to upload a file, enter a URL, or copy the YAML file on Postman. 

Import the `open-api-format/api.yaml` from the [URL link](/open-api/3.0/api.yaml) or the YAML file directly with `Import as an API` and `Generate a Postman Collection` checked.

### Environment

- **3.** In the top right corner of Postman, click on the eye icon to see the Environment Options and `Add` a new active Environment for Pryv :

![Add the Environment](/assets/images/add.png)

- **4.** Set the environment variables of Pryv. 

Fill in the variables `username`, `token`, `password`, `baseUrl`, `appId` and `origin` as shown below:

![Manage the Environment](/assets/images/manage.png)

`Username`, `token`, `password` correspond to the variables created for your Pryv account. 
- `username`represents the username you chose when creating your Pryv account. You can find more information on how to create a Pryv user on the [dedicated page](http://api.pryv.com/getting-started/#create-a-pryv-lab-user);
- `password` is the password associated to your username;
- `token` corresponds to the access token that you generated for your Pryv account. 

You can obtain an Access Token from the [Pryv Access Token Generator](https://api.pryv.com/app-web-access/?pryv-reg=reg.pryv.me).

The variable `baseUrl` should be set as `https://{{token}}@{{username}}.pryv.me`.

Methods reserved for trusted apps only, which are tagged as such [here](/reference-full/#trusted-apps-verification) require a personal token which is only obtainable through an `auth.login` API call. For this you need to set the following environment variables:

The variable `appId` can be completed with any trusted app Id of your Pryv account.

The variable `origin` must be defined as `https://sw.{domain}` (in our case `https://sw.pryv.me`).

Finally, click on `Add` to update the environment.

### Testing the API

- **5.** Once the Pryv environment is set, you can get familiar with Pryv.io API by testing different methods :

![Open API methods](/assets/images/play.png)

Select a method by directly clicking on it.

For `GET` methods, you can check or uncheck the Query Params you need, and fill them with the right value in the `Params` field.

As an example, see the method `events.get` below :

![events.get](/assets/images/get-events.png)

For `POST` and `PUT` methods, you should fill the necessary parameters in the `Body` field.

As an example, the different parameters `name`, `parentId`, `singleActivity`, etc. should be completed with their own value when creating a new stream for the method `streams.create` below :

![events.get](/assets/images/create-streams.png)

- **6.** Once you have filled in the necessary fields for the method you are testing, click on `Send` to send the request :

![Send request](/assets/images/send.png) 

- **7.** Enjoy !

The original API reference can be found [online](https://api.pryv.com/reference/). 

For any questions or suggestions, do not hesitate to contact our team directly. 