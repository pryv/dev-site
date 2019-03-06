---
id: create-user
title: 'Create a user'
template: customer.jade
withTOC: true
---

To create a new user, you will need 2 specific information:

- appId: this identifier is chosen by you and has to be unique for the application interacting with Pryv.io, be it a web application, a mobile application or anything else.
- hosting: this piece of information will tell Pryv.io on which storage system to create and link the user. More information is available at the [API concepts](http://api.pryv.com/concepts/#servers) page.

## Get existing hostings

You can query Pryv.io to list the existings hostings know to the system.

Execute the following cURL request to the register URL of your installation.

```bash
curl -X GET \
     -H 'Content-Type: application/json' \
     https://reg.pryv.domain/hostings
```

An example of an answer follows:

```json
{
  "regions": {
    "pilot": {
      "name": "Pilot",
      "localizedName": { "fr": "Pilot" },
      "zones": {
        "pilot": {
          "name": "Pilot Core",
          "localizedName": { "fr": "Pilot Core" },
          "hostings": {
            "pilot": {
              "url": "http://pryv.domain",
              "name": "Self-Contained Pilot Core",
              "description": "Local core inside the pilot deployment",
              "localizedDescription": {},
              "available": true
            }
          }
        }
      }
    }
  }
}
```

In the previous example, the `hostings` part only contains one hosting deployment which name is `pilot`.

## New user creation

Using the previously found `pilot` hosting and a custom appid `my-own-app`, let's create a new user by sending the following request to the register.

```bash
curl -X POST \
     -H 'Content-Type: application/json' \
     -d '{
         "appid": "my-own-app",
         "username": "jsmith",
         "password": "password",
         "email": "jsmith@example.com",
         "hosting": "pilot"
     }' \
     https://reg.pryv.domain/user
```

The answer returned will contain the username of the account created and the URL to start using it and manage data for this user.

```json
{
  "username": "jsmith",
  "server": "jsmith.pryv.domain"
}
```

From this point onward, all queries to Pryv.io will be done using the URL returned, indicating how to interact with a specific user's data.
