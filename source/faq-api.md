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

The default set of validated types is defined in [http://api.pryv.com/event-types](http://api.pryv.com/event-types/), they are validated upon creation and modification. To validate custom types, it is possible to provide a different source of event types, following the [JSON schema format](https://api.pryv.com/event-types/#format-specification).

## API methods

### What is the exact structure of the create attachment call?

If you are having issues creating the package for the create attachment with the client/framework/library you are using. You can print the details of the call by using the `-v ` verbose option.

## User creation

### Can we limit access to user creation?

The user creation API call uses a token, this can be shared to select people.

### Is there an API call for user creation?

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

The `hosting` field must be chosen from https://reg.${DOMAIN}/hostings, defined in the registry configuration.

### What if I don't want to store an email the account?

If you do not wish to store an email, we suggest to fill this field with `${USERNAME}@${DOMAIN}`.

### How can I programmatically create user accounts?

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

### Should I use /auth/login or auth request?

The token obtained after a login request is similar to being `root` on an account. It returns an expirable token that allows to manipulate resources such as the password.

Tokens obtained after an auth request are similar to authorization steps in an oAuth process. They are used to request data access consents and do not expire unless they are cancelled or deleted. They are therefore recommended for mobile apps and external services.

## Account granularity

### Should I store multiple user data in a single account?

For compliance reasons, Pryv.IO accounts are per-user. Storing multiple people data under the same account bypasses the authorization step which is the technical equivalent of consent.

### How can researchers and clinicians access other peoples data, i.e study participants?

Access to people's data is done in multiple ways. When authentifying with username/email & password on a trusted app (the owner of the platform defines this), using the obtained token the user can create accesses to any subset of his/her data depending on a streams/tags matrix.
It is possible to develop "3rd party" apps whose authentification process is oAuth-like, which prompts the user with the request to give access to the said app for the requested streams. The obtained access token can be used to create accesses whose scope are subsets of itself.
For either way, to give access to people's data to researchers and clinicians, the created tokens need to be stored by a service accessible to them.
Accesses definition
The information regarding a user's study or organization belonging can be accessible through such a service as well, with each user's organization(s) & study(ies) stored either there or on the user's Pryv IO account.

## Cross app access

### How can I access Pryv.IO resources from another app?

This can be done by using the auth request through a consent step or by generating a token directly through an API call using a token obtained previously.

## Do you have a test setup where this could be tested?

You can try out Pryv IO, using our demo platform pryv.me: https://pryv.com/pryvlab/

