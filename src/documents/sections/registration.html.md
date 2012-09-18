---
sectionId: registration
sectionOrder: 3
---

# Registration service

TODO: review the entire chapter

The register service handles user's directory and manages user creation.

Registration of users is normally done manually from the [Pryv https://pryv.io](https://pryv.io) homepage.

Read this document **if you plan to write a registration client** or for your own curiosity.


### Common error codes

* 500 (internal error), code `INTERNAL_ERROR`: Something went bad on the server.


### <a id="registration-translations"></a>Messages translations
We offer key based translations files for messages.

As today only the folowing languages are availables

 * English: **"en"** /messages-en.js
 * French: **"fr"** /messages-fr.js


### <a id="registration-rules"></a>User name and password rules


* User name: `/^[a-zA-Z0-9]{5,21}$/`(alphanumeric between 5 an 21 chars) case-insensitive.
* Password: Any chars between 6 and 99 chars, with no trailing or starting spaces.



## HTTP API


### <a id="registration-server"></a>GET the server of a userName
This is normaly handled by DNS queries as **userName**.pryv.io should point to a *xyz*.pryv.net server.

You may use this as a fallback in case of DNS inconsistency.

Like for [Confirm](#registration-confirm) there is two methods

* GET will do a redirect
* POST will return JSON data.


#### GET `/{user-name}/server`
Responses as redirects

##### Response (JSON)

* 200 to https://*xyz*.pryv.net/?userName=.....

##### Specific errors

* 200 to https://pryv.io/?error=UNKOWN_USER_NAME


#### POST `/{user-name}/server`


##### Response (JSON)

* 200 `server`: may be an IPv4, iPv6 or a fully qualified hostname

exemple : (everything went fine)

	{"server": "xyz.pryv.net", "alias", "userName.pryv.io"}

##### Specific errors

* 400 (bad request), code `INVALID_USER_NAME`
* 404 (not found), code `UNKOWN_USER_NAME`


### Check if username exists

#### <a id="registration-check"></a>GET `/{user-name}/check`

Checks whether the given user name already exists.

##### Response (JSON)

* 200 `exists` (`true` or `false`): `true` if the given user name is already in use

exemple :

	{"exists": "true"}

##### Specific errors

* 400 (bad request), id `INVALID_USER_NAME`: The given name cannot be used as a user name see: [Rules](#registration-rules).

exemple :

	{"message": "Invalid user name",
	  "detail": "User name must be made of 5 to 21 alphanumeric characters.",
	      "id": "INVALID_USER_NAME"}


### Register a new User: Confirmation, Step 1 / 2
#### POST `/init`

Initializes user creation, will be confirmed by POST `/challengeToken/confirm`, see: [Confirm](#registration-confirm).

The __challengeToken__ is sent by mail. Unconfirmed user creations are deleted after 24 hours.

If your software runs on a platform on which you can trust the user identity, you may skip the confirm step. For this, please contact our devloppement team.

##### Post parameters (JSON)

* `userName` (string): The user's unique name.
* `password` (string): The user's password for accessing administration functions.
* `email` (string): The user's e-mail address, unique to that user.
* `languageCode` ([two-letter ISO language code](/DataTypes#TODO)): The user's preferred language. TODO: note about actual usage in service and clients.

##### Response (JSON)

* 200 id `INIT_DONE` : Registration started

exemple :

	{"message": "Registration started",
      "detail": "An e-mail has been sent, check your mailbox to confirm."
          "id": "INIT_DONE"}

##### Specific errors

* 400 (bad request), id `INVALID_DATA`: with a set of errors
	* id `EXISTING_USER_NAME`: The requested userName is alerady used. You may check avalability with `GET /{user-name}/check`, see: [Check](#registration-check).
	* id `INVALID_USER_NAME`: The given name cannot be used as a user name, see: [Rules](#registration-rules).
	* id `INVALID_PASSWORD`: The given password does not fit password policy see: [Rules](#registration-rules).
	* id `INVALID_EMAIL`: The given email is not recognized as valid.

see: [messages translations](#registration-translations)

exemple : (all requested data are empty)

	{"message": "Invalid Data",
	  "detail": "Some of the data transmited is invalid.",
	      "id": "INVALID_DATA",
	  "errors":[{"message": "Invalid user name",
	              "detail": "User name must be made of 5 to 21 alpha...",
	                  "id": "INVALID_USER_NAME"},
	            {"message": "Invalid password",
	              "detail": "Password must be between 6 and 50 characters",
	                  "id": "INVALID_PASSWORD"},
	            {"message": "Invalid email adress",
	              "detail": "E-mail address format not recognized",
	                  "id": "INVALID_EMAIL"}
	           ]
     }


### <a id="registration-confirm"></a>Register a new User: Confirmation, Step 2 / 2
Confirms user creation for the given user.

For now the token is sent by mail, this step is usually handeled by our web page.

Note: if the user is already confirmed, this will send an error, but also the server hostname to use.


**Two methods: **

* GET is designed to triggered by a single link (from an e-mail). So it does a redirect to the user web page in case of success.
* POST will return JSON data.



#### GET `/{challenge}/confirm`

##### Response (REDIRECT)

* 200 `server`: may be an IPv4, iPv6 or a fully qualified hostname

exemple : (everything went fine)

	{"server": "test1.pryv.net", "alias": "userName.pryv.io"}


#### POST `/{challenge}/confirm`
See GET for a redirect to web site solution

Confirms user creation for the given user.

For now the token is sent by mail, this step is usually handeled by our web page.

Note: if user is already confirmed, this will send an error, but also the server hostname to use.

##### Post parameters (JSON)

* `challenge` (string): The code sent by e-mail to user to confirm it's registration

##### Response (JSON)

* 200 `server`: may be an IPv4, iPv6 or a fully qualified hostname

exemple : (everything went fine)

	{"server": "xyz.pryv.net", "alias": "userName.pryv.io"}

##### Specific errors

* 400 (bad request), code `INVALID_CHALLENGE`: the response is badly formatted.
* 404 (not found), code `NO_PENDING_CREATION`: There is no pending user creation for the given user name. Confirmations must be done within 24 hours.
* 400 (bad request), code `ALREADY_CONFIRMED`: This user has allready been confirmed. **!! but you may proceed to server !!**

exemple : This username has already been confirmed

	{"message": "Already confirmed",
	  "detail": "The registration for this user has already been confirmed.",
	      "id": "ALREADY_CONFIRMED",
	  "server": "test2.pryv.net",
	   "alias": "userName.pryv.io"}


## WEB access

TODO: remove or put elsewhere?

### The Homepage
http://pryv.io

### Error fallback
#### https://pryv.io/error.html?id=NO_PENDING_CREATION
Confirmation failed: `GET /{challenge}/confirm`

#### https://pryv.io/error.html?id=INVALID_CHALLENGE
Confirmation failed: `GET /{challenge}/confirm`

#### https://pryv.io/error.html?id=INVALID_USER_NAME
Server request failed: `GET /{username}/server`

#### https://pryv.io/error.html?id=UNKOWN_USER_NAME
Server request  failed: `GET /{challenge}/server`

