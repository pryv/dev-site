---
id: faq
title: 'FAQ - API'
template: default.jade
withTOC: true
---


## Streams

### Is the structure of streams defined locally at the level of each user or is the stream structure defined globally and all the users get the same streams and substreams structure ?

The stream structure is declared and managed by apps. We advise you to maintain a list of streams following [this template](https://docs.google.com/spreadsheets/d/1UUb94rovSegFucEUtl9jcx4UcTAClfkKh9T2meVM5Zo/edit?usp=sharing).

### Is there a limit in the number of child streams that a stream can have ?

There is no limit to the number of substreams of a stream. As a general rule it is preferable to multiply the number of streams and to minimize the creation of different event types.

For example, if you want to enter data measurements for different types of allergens, it is preferable to create one substream per allergen type (`Cereal crops`, `Pollen`, `Hazelnut Tree`, etc) with a single event type (`density/kg-m3`) instead of multiplying event types (`density/pollen`, `density/cereal`, etc) under a single stream `Allergens`.


## Event Types


### How can I define custom event types?

You can define any custom type as long as it follows [this structure](/event-types/#basics). See the [Getting started guide - Data modelling](/getting-started/#events/) for more information.

### Is there a limit in the number of event types to be used in a stream ?

There is no limitation in terms of event types per stream. A stream acts like a “folder” in which you can put any type of information.
If you wish to give a Pryv access token to an external service and to control its use of the access, you can give it a “limited” access type- `create-only`- which allows it to only create events in the streams.

### Are my events content validated?

The default set of validated types is defined in [https://api.pryv.com/event-types](/event-types/), they are validated upon creation and modification. To validate custom types, it is possible to provide a different source of event types, following the [JSON schema format](/event-types/#format-specification).

### What kind of validation do you perform?

Depending on the `type` field of the event, the content of the fields `content` and `attachments` are validated.

## Other data structures

### What information should be contained in the “Profile” section of the user ?

Profile sets are plain key-value structure in which you can store any user-level settings (e.g. credentials).   
This structure is likely to be deprecated soon, and with the exception of the “Public profile set”, we recommend our customers to use dedicated streams to store account information of their users. 

### What are “Followed slices” that can be stored in Pryv accounts ? 

These are [data structures](http://pryv.github.io/reference-full/#followed-slice) that can store subscriptions to resources in other accounts.

For example, a doctor can store all the tokens to patients’ accounts for which he has been granted the access in a **Followed Slice**.  
However this data structure has a limitation: it is only accessible with a “personal token” which requires a password every time.
In some cases it can be more practical (but less safe) to store these access tokens in a dedicated stream.

## API methods

### What is the exact structure of the create attachment call?

If you are having issues creating the package for the create attachment call with the client/framework/library you are using, you can print the details of the call by using cURL with the `-v` verbose option.

## User creation

### Can we restrict access to user creation?

The user creation API call uses a token, by not making this token public, it is possible to make account creation available to select users.

### Is there an API call for user creation?

The API call for user creation is defined in [API system reference](/reference-system/#account-creation), please contact us for more information.

### What if I don't want to provide an email registration phase?

Account must have an email-like string attached to them. You can make up an email address for you internal app usage, depending on your requirements. Please note that you will not be able to retrieve a lost password using the [reset password request](/reference-full/#request-password-reset).

We suggest using the following format as a placeholder: `${USERNAME}@${DOMAIN}`.

### How can I programmatically create user accounts?

It is possible to create users with an API call, without having to fill the fields manually.

## Authentication

### I'm getting the "invalid credentials" error on the auth.login call although my fields are correct

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

API methods such as `auth.login` marked as _TRUSTED APPS ONLY_ on [the _full_ API reference](/reference-full/) require to have the `Origin` or `Referer` headers matching the domain or one defined in the configuration. This field is not changeable in browser as it is a security measure. We use this to prevent phishing attacks that would allow attackers to impersonate Pryv.io connected apps to steal user credentials.

In order for this to work, the web app must be running on a domain allowed by the configuration. By default, this contains: `https://*.${DOMAIN}*, https://*.rec.la*, https://*.pryv.github.io*`.

In mobile apps, the `Origin` and `Referer` headers can be set manually in the HTTP request. For example: `Origin: "auth.${DOMAIN}"`.

In addition to the host, it is possible to allow this call for a defined set of `appId`.

### What authentication should I use in a mobile app?

You should implement the [auth request](/reference/#auth-request), displaying the provided `url` in a web view. Once you obtain the token, save it into the local app storage so you will not have to authenticate each time.

### Is it possible to add an additional layer of authentification?

Pryv.io login implies a username/password login. It is possible to transform this login into a challenge-response authentication and add an authentication overlayer in the challenge. 

It is also possible to add multiple authentication factors : http://pryv.github.io/assets/docs/20191205-pryv.io-mfa-v2.pdf


## Account granularity

### Should I store the data of more than one person in a single Pryv.io account?

For compliance reasons, Pryv.io accounts are per-user. Storing multiple people data under the same account bypasses the authorization step which is the technical equivalent of consent.

## Access sharing

### How does a person give access to his data?

Using a token previously obtained, you can generate a new one using the [accesses.create](/reference/#create-access) API call to generate a new token. The permission set associated to this token must be a subset of the permissions set of the access token used for the call.

### How can I request access to someone's data?

In order to request an access to someone's data, one must implement a page that makes an [auth request](/reference/#auth-request) when loaded. The `url` in the response must be displayed to the user. The web page will ask him for his credentials as well as display the list of requested permissions. Upon approval, the app will obtain a valid token in the polling url response.

A simple web app demonstrating this implementation can be seen [here](https://github.com/pryv/app-web-access).

### What are the different access types ? 

There are three main access types (see more info [here](https://api.pryv.com/concepts/#accesses)):

- **Personal accesses** are used by apps that need to access the entirety of the user's data and/or manage account settings. They grant full permissions, including management of other accesses. This type of access can create app accesses.
- **App accesses** are used by the majority of apps which do not need full, unrestricted access to the user's data. They grant access to a specific set of data and/or with limited permission levels (e.g. read-only), according to the app's needs; this includes the management of shared accesses with lower or equivalent permissions. This type of access can create shared accesses. 
- **Shared accesses** are used for person-to-person sharing. They grant access to a specific set of data and/or with limited permission levels (e.g. read-only), depending on the sharing user's choice. This type of access can not create other accesses.

## How long should I keep an access token valid ?

Accesses are not systematically set with an expiry date. The optional field `expireAfter` of an [Access token](https://api.pryv.com/reference/#access) allows you to set an expiry date for the token if you want to. 
It is important to bear in mind that if a token expires, you will need to keep a “master token” to be able to generate new ones. 

If you are concerned with the security of the accesses, we provide you with monitoring tools to detect fraudulent use of tokens [here](https://api.pryv.com/reference/#audit).

### How can I access Pryv.io resources from another app?

This can be done by using the auth request through a consent step or by generating a token directly through an API call using a token obtained previously.

### Is it possible for a user to delegate the access to his data (or part of it) to another user for a limited amount of time ?

Let’s imagine that the users' from the app you created won’t be connecting on the app for a while. You cannot afford to wait until they finally reconnect to authorize apps and grant access to their data.

It is possible to "delegate" the access by using an "app" token which will act as an “authorization account” and accept access requests on behalf of the user. An “app” token can generate sub-tokens of a “shared” type and therefore share the access to data that was in the scope of the “app” token. 

### What level of permissions do I need to create/delete/modify streams in a user’s account ? 

The access level “manage” (see more details [here](https://api.pryv.com/reference/#access)) on a stream gives you the permission to manipulate (create, modify, delete) all the substreams of this stream. 
It is possible to request an access on all streams (`*`) at once with the following : 
```json
{
  "name": "Access on all streams",
  "permissions": [
    {
      "streamId": "*",
      "level": "manage"
    }
  ]
}
```
### Can I limit the number of apps that can send an auth request to users ? 

To do so, you can either :
- Maintain a register of authorized *appIds* that can send auth requests and launch a verification protol every time an app is requesting access to users' data from the [Token generator page](https://api.pryv.com/app-web-access/?pryvServiceInfoUrl=https://reg.pryv.me/service/info). You can implement it by modifying the source code of the [app-web-auth3-flow](https://github.com/pryv/app-web-auth3) and adding a frontend web app that performs this validation step.
- Or limit the use of some API methods (such as [authentication methods](https://api.pryv.com/reference/#authentication) or [create.access](https://api.pryv.com/reference/#create-access)) to specific IP addresses. In this way, you can control who can create accesses for apps. 

## Notification system

### Should I use “websockets” or “webhooks” to subscribe to changes ?

**Websockets** should be used to get notified of data changes in a web application (on the frontend side). It requires to establish a connection between the client and the server and to subscribe to one of the following events : `eventsChanged`, `streamsChanged`, `accessesChanged` (see more details [here](https://api.pryv.com/reference/#subscribe-to-changes)).
**Webhooks** are more suited to get notified of data changes in a web service (on the backend side).

### What type of information do webhooks/websockets contain ?

These notifications do not include the contents of the change, but they describe what type of resource has been changed (created, updated or deleted).
They inform the server that it needs to fetch new or updated data through the API by doing a HTTP GET request with a valid access token. 

### Is the server notified of data changes in all streams of the account or only the streams for which permission was granted in the provided access token ?

Notifications are sent as soon as there is a data change in the "events", "streams" or "accesses" for the whole user account. It is therefore possible to get notified of a data change that would not be in the scope of the access token.
Notifications are likely to be scoped in the near future. 


## Do you have a test setup where I could experiment with your API?

You can try out Pryv.io using our demo platform pryv.me: [https://pryv.com/pryvlab/](https://pryv.com/pryvlab/)
