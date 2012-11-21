---
structureId: diary 
structureOrder: 2
---

# Default Channels and Folders

## ```diary``` Channel 

The diary channel aggregates all the thoughts and notes of a user, including her social activities.

### ```notes``` Folder 

For all text notes.

#### Examples:

1. Simple text note:
```json 
{
  value: {
    type: "note:TEXT",
    value: "I like cheese"
  },
  comment: "",
  date: "20110512 12:12:12",
  duration: null,
  tags: [],
  attach: null 
}
```

2. Html note with  an attached picture ```sunset.jpg```:
```json      
{
  value: {
    type: "note:HTML",
    value: "<p><img src="sunset.jpg" /> My nice poem goes here</p>"
  },
  comment: "",
  date: "20110512 12:12:12",
  duration: null,
  tags: [],
  attach: "sunset.jpg" 
}
```

### ```social``` Folder 

For all social content. Events are usually saved in the subfolder corresponding to the concerned social network.

### ```social/facebook``` Folder  

For all facebook events.

#### Examples:

1. A facebook post with attached picture ```zz.jpg```:
```json      
{
  value: {
    type: "note:facebook",
    value: {
      fbid: "609329217"
      value: "blah blah <b>blah</b> <img src=zz.jpg>"
    }
  },
  comment: "",
  date: "20110512 12:12:12",
  duration: null,
  tags: [],
  attach: "zz.jpg" 
}
```

2. A facebook friend with attached avatar ```pict1.jpg```:
```json
{
  value: {
    type: "relation:facebook",
    value: {
      fbid:"8912819d21", 
      name:"Toby", 
      class:"friend", 
      avatar:"pict1.jpg"
    }
  },
  comment: "",
  date: "20110512 12:12:12",
  duration: null,
  tags: [],
  attach: "pict1.jpg" 
}
```

### ```social/twitter``` Folder 

For all twitter-related events.

#### Examples:

1. A tweet:
```json         
{
  value: {
    type: "note:tweet",
    value: {
      from:"pryv", 
      content:"Blah blah .. love Pryv .. so cool for you!"
    }  
  },
  comment: "",
  date: "20110512 12:12:12",
  duration: null,
  tags: [],
  attach: null 
}
```

### ```social/twitter/followers``` Folder 

To keep track of the user's number of followers at a given time.

#### Examples:

1. Number of followers:
```json         
{
  value: {
    type: "dimensionless",
    value: 45 
  },
  comment: "followers",
  date: "20110512 12:12:12",
  duration: null,
  tags: [],
  attach: null 
}
```

### ```social/conversation``` Folder 

In this folder, the user can keep track of her discussions on the phone, on skype, etc.

#### Examples:
1. A phone call:
```json
{
  value: {
    type: "call:tel",
    value: [{tel:"+41.765766535"}]
  },
  comment: "",
  date: "20110512 12:12:12",
  duration: 360000,
  tags: ["person:tom"],
  attach: null 
}
```

### ```position``` Folder 

A user can save geolocation data in this folder.

#### Examples:
TODO
