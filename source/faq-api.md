---
id: faq
title: "FAQ"
template: default.jade
withTOC: true
---

## Event types

### How can I define custom event types?

You can define any custom type as long as it follows [this structure](http://api.pryv.com/event-types/#basics). See [First steps - Date modeling tips](http://api.pryv.com/getting-started/pryvme/#data-modelling-tips/) for more information.

### Are my event contents validated?

The types defined in [http://api.pryv.com/event-types](http://api.pryv.com/event-types/) are validate by the core upon creation and modification. To validate custom types, please contact your technical ...

## API methods

### create attachment

If you are having issues creating the package for the create attachment with the client/framework/library you are using. You can print the details of the call by using the `-v ` verbose option.

### Login user

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

API methods marked as *TRUSTED APPS ONLY* on [https://api.pryv.com/reference-full/](https://api.pryv.com/reference-full/) require to have the Origin or Referer headers matching the domain or one defined in the configuration. This field is not changeable in browser as it is a security measure. We use this to prevent fishing attacks that would allow attackers to impersonate Pryv.IO connected apps to steal user credentials.

In order for this to work, the web app must be running on the domain specified by the configuration. By default, this contains: `*.${DOMAIN}*, *.rec.la*, *.pryv.github.io*`.

In mobile apps, this header can be set manually in the HTTP request:

```json
Origin: "something.${DOMAIN}"

or

Referer: "something.${DOMAIN}"
```

## User creation

### Can we limit access to user creation?

The user creation API call uses a special token, this can be shared to select people.

### API call

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

### Email

If you do not wish to store an email, we suggest to fill this field with {USERNAME}@${DOMAIN}.

### Programatically create

It is possible to create users with the aforementioned API call, without having to fill the fields manually.

## Authentication

### Should I use /auth/login or auth request

The token obtained after a login request is similar to being `root` on an account. It allows to manipulate resources such as the password and the token has an expiration date.

Tokens obtained after an auth request are similar to authorization steps in an oAuth process. They are used for consent delegation and do not expire unless they are cancelled or deleted. They are therefore recommended for mobile apps and 3rd party usage.

## Account granularity

For compliance reasons, Pryv.IO accounts are per-user. Storing multiple people data under the same account bypasses the authorization step which is the technical equivalent of consent.

### How are users grouped to specific studies or organizations?

Pryv IO platforms are user centric, each account accessible through the https://USERNAME.DOMAIN (eg.: https://iliakebets.pryv.me) URL endpoint, the username doesn't have to be identifying. These can be stored in different locations depending on the number of core machines that are deployed in the platform, core machines are the ones actually storing the data.

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

