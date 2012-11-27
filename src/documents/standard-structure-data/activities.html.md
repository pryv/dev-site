---
structureId: activities
structureOrder: 3
---

## ```activities``` Channel

The activities channel is a default channel where a user can save her various work and leisure activities.

### ```entertainment``` Folder

### ```sport``` Folder

### ```work``` Folder

This folder contains all events related to the user's work. The user should be able to save her work activities in different subfolders depending on the type of work she is achieving.

### ```work/projectA``` Folder

This is an example of folder you could create in this channel for a specific project the user has been working on that would perfectly fit inside ```work```.

#### Examples:
1. The user has fixed a bug:
```json
{
  value: {
    type: "activity",
    value: null
  },
  description: "Bug #123",
  date: "20110512 12:12:12",
  duration: 360000,
  tags: ["task:development"],
  attach: null
}
```

2. The user has worked on a report for Mr. A:
```json
{
  value: {
    type: "activity",
    value: null
  },
  description: "report for Mr A.",
  date: "20110512 12:12:12",
  duration: 123712,
  tags: ["task:reporting"],
  attach: null
}
```

### ```parties``` Folder

A perfect place to save all party pictures for instance.

#### Examples:
1. A picture from the user's latest fun activity.
```json
{
  value: {
    type: "picture",
    value: {
      file: "pic1.jpg",
      dimension: .... TODO
    }
  },
  description: "",
  date: "20110512 12:12:12",
  duration: null,
  tags: ["event:john's wedding"],
  attach: "pict1.jpg"
}
```
