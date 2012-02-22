# Data types

TODO: introductory text

### Item identity

An unsigned integer number uniquely designating the item within its scope. For example:

* The identity of every activity channel must be unique within its owning user's data
* The identity of every activity state or event must be unique within its containing channel


### Timestamp

A floating-point number representing a number of seconds since any reference date and time, **independently from the time zone**. Because date and time synchronization between server time and client time is done by the client simply comparing the current server timestamp with its own, the reference date and time does not matter.


### Two-letter ISO language code

A two-letter string specifying a language following the ISO 639-1 standard (see [the related Wikipedia definition](http://en.wikipedia.org/wiki/ISO_639-1)).


### Activity channel


### Activity state


### Activity event