---
id: backup
title: 'Pryv.io Backup'
template: default.jade
customer: true
withTOC: true
---

## Table of contents

1. [Introduction](#introduction)
2. [Backup](#backup)
  1. [Core](#core)
  2. [Register](#register)
  3. [Static-web](#static-web)
3. [Restore](#restore)
  1. [Core](#core)
  2. [Register](#register)
  3. [Static-web](#static-web)


## Introduction

This guide describes how to perform a backup of your Pryv.io platform and how to restore it in case of any data loss. You will have to backup user data as well as configuration files of each role: core, register, static-web.

We will refer to the root of your Pryv.io installation on each role (usually /var/pryv/) as ${PRYV_CONF_ROOT}.

## Backup

You should first backup core data, starting with MongoDB.

### Core

- Run the following command to export the MongoDB data: 
    ` $ docker exec -t pryvio_mongodb /app/bin/mongodb/bin/mongodump -d pryv-node -o /app/backup/ `
The backup folder will be located at: `${PRYV_CONF_ROOT}/pryv/mongodb/backup/`.

- Run the following command to export the InfluxDB data: 
    `$ docker exec -t pryvio_influxdb /usr/bin/influxd backup -portable /pryv/backup/ `
The backup folder will be located at: `${PRYV_CONF_ROOT}/pryv/influxdb/backup/`.

- Backup the ${PRYV_CONF_ROOT} folder except the following:
    - `${PRYV_CONF_ROOT}/pryv/mongodb/data/`
    - `${PRYV_CONF_ROOT}/pryv/influxdb/data`
    - `${PRYV_CONF_ROOT}/pryv/core/data/previews/`

### Register

- Backup the ${PRYV_CONF_ROOT} folder

### Static-web

- Backup the ${PRYV_CONF_ROOT} folder  

### Important notice

During the time of the backup, if user accounts are created between the core and register backup times, they won't be usable after a backup restoration. Attachments and High-frequency data created after the MongoDB backup won't be accessible as their corresponding Pryv.io events will not be available.

## Restore

Once you have backed up data, you can use it to restore your Pryv.io platform as described in the following procedure.

### Core

- Empty the contents of the ${PRYV_CONF_ROOT} folder  
- Copy the backed up files under the ${PRYV_CONF_ROOT} folder  
- Start the service  
- Restore the MongoDB files: `$ docker exec -t pryvio_mongodb /app/bin/mongodb/bin/mongorestore /app/backup/`  
- Restore the InDuxDB files: `$ docker exec -t pryvio_influxdb /usr/bin/influxd restore -portable /pryv/backup/`  

### Register

- Empty the contents of the ${PRYV_CONF_ROOT} folder  
- Copy the backed up files under the ${PRYV_CONF_ROOT} folder  
- Start the service  

### Static-web

- Empty the contents of the ${PRYV_CONF_ROOT} folder  
- Copy the backed up files under the ${PRYV_CONF_ROOT} folder  
- Start the service  
