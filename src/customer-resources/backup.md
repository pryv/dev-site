---
id: backup
title: 'Pryv.io Backup'
layout: default.pug
customer: true
withTOC: true
---

This guide describes how to perform a backup of your Pryv.io platform and how to restore it in case of any data loss.

In v2, Pryv.io runs as a single binary. Backup covers the core data (MongoDB/PostgreSQL, InfluxDB, user files) and configuration.

We will refer to the root of your Pryv.io installation as `${PRYV_CONF_ROOT}`.

Pryv.io v2 also provides a built-in backup tool: `bin/backup.js` (see `INSTALL.md` in the repository).


## Table of contents <!-- omit in toc -->

1. [Backup](#backup)
   1. [Database exports](#database-exports)
   2. [Configuration and user files](#configuration-and-user-files)
   3. [Important notice](#important-notice)
2. [Restore](#restore)


## Backup

### Database exports

- **MongoDB** — Run the following command to export the MongoDB data:

```bash
docker exec -t pryvio_mongodb /app/bin/mongodb/bin/mongodump -d pryv-node -o /app/backup/
```

The backup folder will be located at: `${PRYV_CONF_ROOT}/pryv/mongodb/backup/`.

- **InfluxDB** — Run the following command to export the InfluxDB data:

```bash
docker exec -t pryvio_influxdb /usr/bin/influxd backup -portable /pryv/backup/
```

The backup folder will be located at: `${PRYV_CONF_ROOT}/pryv/influxdb/backup/`.

### Configuration and user files

- Backup the `${PRYV_CONF_ROOT}` folder except the following:
    - `${PRYV_CONF_ROOT}/pryv/mongodb/data/`
    - `${PRYV_CONF_ROOT}/pryv/influxdb/data`
    - `${PRYV_CONF_ROOT}/pryv/core/data/previews/`

### Important notice

During the time of the backup, if user accounts are created between database export steps, they won't be usable after a backup restoration. Attachments and High-frequency data created after the MongoDB backup won't be accessible as their corresponding Pryv.io events will not be available.

## Restore

Once you have backed up data, you can use it to restore your Pryv.io platform as described in the following procedure.

- Empty the contents of the `${PRYV_CONF_ROOT}` folder
- Copy the backed up files under the `${PRYV_CONF_ROOT}` folder
- Start the service
- Restore the MongoDB files:

```bash
docker exec -t pryvio_mongodb /app/bin/mongodb/bin/mongorestore /app/backup/
```

- Restore the InfluxDB files:

```bash
docker exec -t pryvio_influxdb /usr/bin/influxd restore -portable /pryv/backup/
```
