---
id: pryv.io-infrastructure-procurement
title: 'Pryv.io infrastructure procurement'
layout: default.pug
customer: true
withTOC: true
---

In this document we address system administrators or equivalent that need to provision virtual machines and other web resources to run a Pryv.io platform.  
It will guide you through the process of deciding which platform setup you require, what virtual machines to provision to host your Pryv.io platform, firewalling settings, OS compatibility and other operational concerns.

## Table of contents <!-- omit in toc -->
<!-- no toc -->
- 1 [Platform setup](#platform-setup)
- 2 [Business requirements](#business-requirements)
- 3 [Core number considerations](#core-number-considerations)
- 4 [System requirements](#system-requirements)
- 5 [Operational concerns](#operational-concerns)
- 6 [Previous version](#previous-version)

## Platform setup

A Pryv.io platform is composed of 3 roles: register, core and static-web.

- The **register** component contains the DNS indicating the core machine for a user account.
- The **core** service stores user data.
- The **static-web** is used to proxy web applications over the same domain and holds default authentication and administration applications.

Pryv.io can be deployed in various ways, depending on requirements of your business case. This ranges from a starting phase where all components live on one virtual machine in a single location, to a deployment spanning many machines across the globe. The present document guides the implementor through the different stages of his project.

### Single-node mode

![single-node](/assets/images/infrastructure/single-node-new.svg)

The diagram above shows deployment of Pryv.io on a single node, all services running on the same VM.

### Cluster with a single core

![cluster-single-core](/assets/images/infrastructure/single-core.svg)

Here we install all roles on separate machines. This variant is useful for when you intend to quickly scale the number of users as shown in the following diagrams.

### Cluster with partitioning for load

![cluster-load](/assets/images/infrastructure/cluster.svg)

When partitioning for load, multiple *core* servers will receive user accounts in a round-robin fashion. Any number of users can coexist on a *core*, up to the extreme of 1 user per machine. Please refer to the [Core number considerations](#core-number-considerations) section for how to compute the amount of cores you will need for your particular load. 

When partitioning for load, we recommend the creation of one or more follower nodes for *register* roles. This avoids creating a single point of failure.

### Cluster with partitioning for geographical compliance

![cluster-compliance-zones](/assets/images/infrastructure/cluster-compliance-zones-new.svg)

The diagram above shows a Pryv.io system designed to partition data into multiple compliance zones. In practice, these will often correspond to countries (legislations) or smaller entities that handle data (and data privacy) differently.

Being able to store data in different locations might even be the reason you're using Pryv.io. In systems where Pryv.io coexists with other server components, it is important to apply the same logic to all the components - e.g. an SMTP server through which sensitive data transits would have to be deployed in multiple versions across compliance zones as well. Pryv offers consulting on the various legal and technical aspects of preserving user privacy and protecting data.

Keep in mind that the granularity of distribution in this kind of scenario is always the user account. In extreme cases a compliance zone might contain data for a single user only.

## Business Requirements

The size of any deployment will be determined by the business requirements that the Pryv.io infrastructure needs to meet. In this section, we aim to show what factors are relevant for designing a Pryv.io infrastructure. 

### Granularity

Pryv.io's fundamental entity is the user; data is kept vertically and not spread out. For this reason, the guidelines in this section will ask for requirements to be specified per user. 

### Data Production

| Metric                                   | Your Values Here |
| ---------------------------------------- | ---------------- |
| Expected Write Requests Per Second (max rqps) |                  |
| Attachment Writes (max MB/s)             |                  |
| Volume (data points per day)             |                  |
| Volume (MB per day)                      |                  |
| Retention of data (years)                |                  |

The above table sums up the factors that influence the expected write load per user for your cluster. The first two metrics will influence the number of users that can be cohosted on a single core; the last two metrics will give you an estimation of disk space consumed per day per user. 

### Data Consumption

| Metric                                   | Your Values Here |
| ---------------------------------------- | ---------------- |
| Expected Read Requests Per Second (max rqps) |                  |
| Number of Points retrieved per Request (scalar) |                  |
| Attachment Reads (max rqps)                  |                  |
| Volume (data points per day)             |                  |
| Volume (MB per day)                      |                  |

This table should help you to quantify the load generated by reading data back per user. 

## Core number considerations

This section aims to guide you through the sizing of your virtual machines, using the key metrics you compiled in the last section.

Once a system gets bigger than a single node (see above), at least 3 machines will be required: one for the *static-web* role, one for *register* and one for *core*.

If your system is distributed among multiple compliance zones, you will need at least one core per such zone. Inside of every compliance zone, the number of cores should be derived from the following maximum values for a single core: 

| Metric                                 | Max Performance of a Single Core                             |
| -------------------------------------- | ------------------------------------------------------------ |
| Write Requests Per Second              | 2000 requests per second                                     |
| Attachment Writes                      | Depends heavily on network path<br />roughly speed of underlying storage system / 2 |
| Data Points Per Day                    | Sustained write increases total data points per user, which will use more disk space. |
| Volume (MB per day)                    | See above.                                                   |
| Expected Read Requests Per Second      | 2000 requests per second<br />Latency has a long tail distribution, depending on your query. |
| Number of Points retrieved per Request | Big (>10000 points) result sets should use paging.<br />See Read Requests per Second. |
| Attachment Reads                       | 600 requests per second                                      |

Additionally, you should consider load distribution across your user base. Depending on homogeneity, you might add safety margins to the above numbers to allow for inter-user differences.  

Users will be assigned to the core that has the least amount of users in the same compliance zone. This results in a round-robin behaviour for a stable set of servers. In the presence of user deletion or when adding servers to an existing cluster, this will skew the distribution of users towards machines that have less users than the others.

## System requirements

The previous section should have allowed you to calculate how many cores to deploy in each compliance zone. The purpose of this section is to give you specifications for each machine in the three roles.

### Operating systems

Linux:

- Ubuntu 16.04, 18.04, 20.04

### Docker

Docker versions:

- Docker v19 or later
- Docker-compose 1.21 or later

### Single Node

| Aspect                | Minimal Requirement              |
| --------------------- | -------------------------------- |
| RAM                   | 4 GB                             |
| CPU Cores             | 2                                |
| Pryv.io services size | 30 GB                            |
| Data size             | Depending on storage needs       |
| Service ports         | tcp/443, udp/53                  |

### Static-web

| Aspect               | Minimal Requirement  |
| -------------------- | -------------------- |
| RAM                  | 512 MB               |
| CPU Cores            | 1                    |
| Pryv.io services size | 10 GB               |
| Data size             | not needed          |
| Service ports        | tcp/443              |

### Register

| Aspect               | Minimal Requirement  |
| -------------------- | -------------------- |
| RAM                  | 2 GB                  |
| CPU Cores            | 1                    |
| Pryv.io services size | 20 GB               |
| Data size             | 15 GB                 |
| Service ports        | tcp/443, udp/53      |

If you foresee a big number of user accounts (> 100'000), please increase the data disk space.

### Core

| Aspect               | Minimal Requirement       |
| -------------------- | ------------------------- |
| RAM                  | 4 GB                       |
| CPU Cores            | 2                         |
| Pryv.io services size | 30 GB               |
| Data size             | Depending on storage needs |
| Service ports        | tcp/443                   |

Here's a matrix that shows how various load situations affect the resource needs of your *core* server(s):

| Load Situation               | Resource Needs                                               |
| ---------------------------- | ------------------------------------------------------------ |
| Large data per user          | Data Disk Space: Increase per data usage predictions         |
| High Requests Per Second     | CPU Cores: Increase to at least 4                            |
| Image uploads                | CPU Cores: Increase to at least 4. RAM: Increase depending on needs |

## Operational Concerns

This section will introduce additional operational concerns not covered by your Pryv.io base installation. We recommend implementing measures to address these topics in order to guarantee safe operation and traceability of issues. 

### System Hardening

We recommend you to follow a system hardening guide for the operating system of your choice. This should include installing firewalls, denying SSH access using passwords and other measures that form best practices. 

Administrators accessing a regulated system must themselves conform to the regulations and have received adequate training. 

### Backups

See the [backup guide](/customer-resources/backup/). Making a copy of private user data is regulated by law. Please make sure you know the ramifications of making backup copies. 

### Node Monitoring

Make sure you monitor key performance metrics of your Pryv nodes and keep a history of these metrics for later viewing. This helps in tracking down performance issues and is considered a best practice. Your metrics should include: 

* Load, CPU (system, user, iowait, idle, load1, load5, load15)
* Disk (space left on devices, iops read and write)
* RAM (swapping activity, reserved, free)
* Network Interfaces (Packets, Bytes, Errors)

## Previous version

The previous version of this document, named "Deployment design guide" is still available [here](/assets/docs/deployment_design_guide_v6.pdf).
