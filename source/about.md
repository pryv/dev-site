---
id: about
titleShort: About
titleFull: About the API
template: default.jade
---

Pryv is a service empowering people with a simple, trusted space reuniting the streams that matter under their control. It handles any type of timestamped data, modeling individual pieces as **events** (stuff that happens) and contextualizing them into **streams** and **tags** (the circumstances in which stuff happens).

The Pryv API is an HTTP and web sockets API that enables apps & services to interact with Pryv events and contexts.

## The basics

Pryv is a decentralized service: you access each user account on the server hosting its data (`https://{username}.pryv.io/`). There can be as many servers as there are accounts.

Users collect, manipulate and view events on their account (or other users' accounts) via apps, which are granted access to the parts of user data they need (e.g. specific streams). Apps can interoperate provided they support the same event types and are granted access to the same data.

Stored data is all private by default. Users share data by explicitly opening read-only or collaborative accesses to specific parts of their data (**slices of life**).


## What you can build with it

Despite the name "Pryv", which reflects our primary intent to stand for user privacy and control, you can build mostly anything on top of the API. Everyone will benefit most if your apps are designed for interoperability—possibly making use of and enriching data from other sources—and so we recommend the use of standard types and contexts, but this is by no means an obligation.
Our dearest hope, though, is that whatever you contribute will work to help people reclaim control over their digital lives, cultivating simplicity, honesty and trust, and putting human relationships at the forefront.

Let's just underline the fundamental principle all apps running on Pryv are built on, which can represent a significant change of perspective: Pryv users own and control their data. Pryv is set to ensure that apps are built with the sole focus of bringing value to users, to avoid users ever becoming the product again.

<!-- TODO: link to the charter of Pryv app development -->


## Now what?

Learn more about the [core concepts](/concepts), or jump straight to the [API reference](/reference).