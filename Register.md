# Register module

The register service handles user's directory and manages user creation.   
[TOC]

## Common error codes

* 500 (internal error), code `INTERNAL_ERROR`: Something went bad on the server.

<a name="mtranslation"/>
## Messages translations
We offer key based translations files for messages.

As today only the folowing languages are availables

 * English: **"en"** /messages-en.js
 * French: **"fr"** /messages-fr.js

<a name="rules"/>
## User name and password rules


* User name: `/^[a-zA-Z0-9]{5,21}$/`(alphanumeric between 5 an 21 chars) case-insensitive.
* Password: Any chars between 6 and 99 chars, with no trailing or starting spaces.

<a name="rules"/>
### GET `/<user name>/check`

Checks whether the given user name already exists.

#### Response (JSON)

* 200 `exists` (`true` or `false`): `true` if the given user name is already in use

exemple :
	
	{"exists": "true"}

#### Specific errors

* 400 (bad request), id `INVALID_USER_NAME`: The given name cannot be used as a user name see: [Rules](#rules).

exemple :
	
	{"message": "Invalid user name",
	  "detail": "User name must be made of 5 to 21 alphanumeric characters.",
	      "id": "INVALID_USER_NAME"}

### POST `/init`

Initializes user creation, will be confirmed by POST `/challengeToken/confirm`, see: [Confirm](#confirm).

The __challengeToken__ is sent by mail. Unconfirmed user creations are deleted after 24 hours.

If your software runs on a platform on which you can trust the user identity, you may skip the confirm step. For this, please contact our devloppement team. 

#### Post parameters (JSON)

* `userName` (string): The user's unique name.
* `password` (string): The user's password for accessing administration functions.
* `email` (string): The user's e-mail address, unique to that user.
* `languageCode` ([two-letter ISO language code](/DataTypes#TODO)): The user's preferred language. TODO: note about actual usage in service and clients.

#### Response (JSON)

* 200 id `INIT_DONE` : Registration started

exemple :
	
	{"message": "Registration started", 
      "detail": "An e-mail has been sent, check your mailbox to confirm."
          "id": "INIT_DONE"}
   
#### Specific errors

* 400 (bad request), id `INVALID_DATA`: with a set of errors
	* id `EXISTING_USER_NAME`: The requested userName is alerady used. You may check avalability with `GET /<user name>/check`, see: [Check](#check).
	* id `INVALID_USER_NAME`: The given name cannot be used as a user name, see: [Rules](#rules).
	* id `INVALID_PASSWORD`: The given password does not fit password policy see: [Rules](#rules).
	* id `INVALID_EMAIL`: The given email is not recognized as valid.
	
see: [messages translations](#mtranslation)

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

<a name="confirm"/>
### GET `/<challenge>/confirm` 

Confirms user creation for the given user. 

For now the token is sent by mail, this step is usually handeled by our web page.

Note: if user is already confirmed, this will send an error, but also the server hostname to use.


#### Response (JSON)

* 200 `server`: may be an IPv4, iPv6 or a fully qualified hostname

exemple : (everything went fine)

	{"server": "test1.edelwatch.net"}
	


#### Specific errors

* 400 (bad request), code `INVALID_CHALLENGE`: the response is badly formatted.
* 404 (not found), code `NO_PENDING_CREATION`: There is no pending user creation for the given user name. Confirmations must be done within 24 hours.
* 400 (bad request), code `ALREADY_CONFIRMED`: This user has allready been confirmed. **!! but you may proceed to server !!**

exemple : This username has already been confirmed

	{"message": "Already confirmed",
	  "detail": "The registration for this user has already been confirmed.",
	      "id": "ALREADY_CONFIRMED",
	  "server": "test2.edelwatch.net"}


### GET `/<user name>/server`

Used to grad a user server hostname. This may be used as fallback instead of the usual DNS mapping: *userName*.__service__.com //TODO change service name

#### Response (JSON)

* 200 `server`: may be an IPv4, iPv6 or a fully qualified hostname

exemple : (everything went fine)

	{"server": "test1.edelwatch.net"}
	
#### Specific errors

* 400 (bad request), code `INVALID_USER_NAME`
* 404 (not found), code `UNKOWN_USER_NAME`
