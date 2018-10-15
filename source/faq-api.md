---
id: faq
title: "FAQ - API"
template: default.jade
withTOC: true
---

## Event types

### How can I define custom event types?

You can define any custom type as long as it follows [this structure](http://api.pryv.com/event-types/#basics). See [First steps - Date modeling tips](http://api.pryv.com/getting-started/pryvme/#data-modelling-tips/) for more information.

### Are my events content validated?

The default set of validated types is defined in [https://api.pryv.com/event-types](https://api.pryv.com/event-types/), they are validated upon creation and modification. To validate custom types, it is possible to provide a different source of event types, following the [JSON schema format](https://api.pryv.com/event-types/#format-specification).

### What kind of validation do you perform?

Depending on the `type` field of the event, the content of the fields `content` and `attachments` are validated.

## API methods

### What is the exact structure of the create attachment call?

If you are having issues creating the package for the create attachment with the client/framework/library you are using, you can print the details of the call by using the `-v ` verbose option.

## User creation

### Can we restrict access to user creation?

The user creation API call uses a token, by not making this token public, it is possible to make account creation available to select users.

### Is there an API call for user creation?

**create API doc**

The user register call is defined as:

HTTP POST https://reg.${DOMAIN}/user

```json
{
    "username": "",
    "password": "",
    "email": "",
    "appId": "",
    "invitationToken": "",
    "hosting": ""
}
```

The `hosting`  field must be chosen from https://reg.${DOMAIN}/hostings, defined in the registry configuration. From this resource, you must use any key of the `hostings` objects. For example, in the [pryv.me platform](https://reg.pryv.me/hostings), you must use `gandi.net-fr` to create an account on the server located in France.

### What if I don't want to provide an email registration phase?

Account must have an email-like string attached to them. You can make up an email address for you internal app usage, depending on your requirements. Please note that you will not be able to retrieve a lost password using the [reset password request](https://api.pryv.com/reference-full/#request-password-reset).

We suggest using the followoing format as a placeholder: `${USERNAME}@${DOMAIN}`.

### How can I programmatically create user accounts?

**link to API doc**

It is possible to create users with the aforementioned API call, without having to fill the fields manually.

## Authentication

### I'm getting the "invalid credentials" error although my fields are correct

I'm getting the following error on the [login call](https://api.pryv.com/reference-full/#login-user) although the payload is correct.

```json
{
    "error": {
        "id": "invalid-credentials",
        "message": "The app id ("appId") is either missing or not trusted."
    },
    "meta": {
        "apiVersion": "1.2.18",
        "serverTime": 1531830525.911
    }
}
```

API methods marked as *TRUSTED APPS ONLY* on [https://api.pryv.com/reference-full/](https://api.pryv.com/reference-full/) require to have the `Origin` or `Referer` headers matching the domain or one defined in the configuration. This field is not changeable in browser as it is a security measure. We use this to prevent phishing attacks that would allow attackers to impersonate Pryv.IO connected apps to steal user credentials.

In order for this to work, the web app must be running on the domain specified by the configuration. By default, this contains: `*.${DOMAIN}*, *.rec.la*, *.pryv.github.io*`.

In mobile apps, this header can be set manually in the HTTP request:

```json
Origin: "something.${DOMAIN}"

or

Referer: "something.${DOMAIN}"
```

### What authentication should I use in a mobile app?

You should implement the [auth request](https://api.pryv.com/reference-full/#auth-request), displaying the provided `url` in a web view. Once you obtain the token, save it into the local app storage so you will not have to authenticate each time.

### How does a person give access to his data?

Using a token previously obtained, you can generate a new one using the [accesses.create](https://api.pryv.com/reference/#create-access) API call to generate a new token. The permission set associated to this token must be a subset of the permissions set of the access token used for the call.

### How can I request access to someone's data?

In order to request an access to someone's data, one must implement a page that makes an [auth request](http://api.pryv.com/reference/#auth-request) when loaded. The `url` in the response must be displayed to the user. The web page will ask him for his credentials as well as display the list of requested permissions. Upon approval, the app will obtain a valid token in the polling url response.

A simple web app demonstrating this implementation can be seen [here](https://api.pryv.com/app-web-access/?pryv-reg=reg.pryv.me).

## Account granularity

### Should I store the data of more than one person in a single Pryv.IO account?

For compliance reasons, Pryv.IO accounts are per-user. Storing multiple people data under the same account bypasses the authorization step which is the technical equivalent of consent.

## Sharing access between apps

### How can I access Pryv.IO resources from another app?

This can be done by using the auth request through a consent step or by generating a token directly through an API call using a token obtained previously.

## Do you have a test setup where I could experiment with you API?

You can try out Pryv IO using our demo platform pryv.me: https://pryv.com/pryvlab/

