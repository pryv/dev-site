---
id: customer-resources
title: 'Customer Resources'
layout: default.pug
customer: true
withTOC: true
---

In this space you will find documents, files and guides for the installation and support of the **Pryv.io enterprise** version.

In February 2025, the closed-sourced version of Pryv.io was released under [BSD-3-Clause](https://opensource.org/license/bsd-3-clause) license. Open-Pryv.io and the Enterprise version share the same codebase but are substantially different to be kept alongside. The name "Enterprise version", is kept to distinguish the two distributions.  

The source code of the different Entreprise version components:
- [service-core](https://github.com/pryv/service-core): Main API component
- [service-register](https://github.com/pryv/service-register): Register and DNS
- [service-mail](https://github.com/pryv/service-mail): E-mail & template service
- [service-mfa](https://github.com/pryv/service-mfa): Mutli-factor authentication service
- [service-config-leader](https://github.com/pryv/service-config-leader): Configuration management centralization
- [service-config-follower](https://github.com/pryv/service-config-follower): Subscribe to config-leader
- [service-ssl-certificate](https://github.com/pryv/service-ssl-certificate): Let's encrypt automated certificate request


## Documents

- Functional Requirement Specification: [pryv.github.io/functional-specifications](/functional-specifications/)

  Functional specifications for the Pryv.io middleware system: the capabilities and functions that the system must be capable of performing.

- Tests Results: [tests](/tests)

  Result of tests suite on `service-core` for the latest Pryv.io version


## Files

- Pryv.io configuration files: [HTML](https://pryv.github.io/config-template-pryv.io/)

  Configuration files to install Pryv.io Entrepise Version.


## Guides

- Pryv.io platform setup guide: [HTML](/customer-resources/pryv.io-setup/)

- Infrastructure procurement (Previously "Deployment design guide"): [HTML](/customer-resources/infrastructure-procurement/)

  This document describes how to deploy a Pryv.io platform as well as essential information to help you decide on your infrastructure and sizing needs.
  You will also find information about how to operate your Pryv.io platform.

- Generate SSL certificate: [HTML](/customer-resources/ssl-certificate/)

  This document describes how to obtain a wildcard SSL certificate for your running Pryv.io platform using Let's Encrypt.

- Installation validation: [HTML](/customer-resources/platform-validation/)

  This document describes the steps to validate that a Pryv.io platform is up and running after deployment.

- System monitoring: [HTML](/customer-resources/healthchecks/)

  This document describes the steps to perform regular healthchecks on a running Pryv.io platform.

- System streams: [HTML](/customer-resources/system-streams/)

  This document describes how to setup and configure your platform's system streams.

- DNS configuration: [HTML](/customer-resources/dns-config/)

  This document describes how to add entries in your Pryv.io associated domain DNS zone.

- Emails configuration: [HTML](/customer-resources/emails-setup/)

  This document describes how to configure the sending of Pryv.io emails for welcoming new users or resetting lost passwords.

- Audit configuration: [HTML](/customer-resources/audit-setup/)

  This document describes how to setup audit capabilities for your Pryv.io platform.

- Core migration: [HTML](/customer-resources/core-migration/)

  This document describes how to migrate a Pryv.io core service to a different machine.

- Register migration: [HTML](/customer-resources/register-migration/)

  This document describes how to migrate a Pryv.io register service to a different machine.

- Single-node to Cluster upgrade: [HTML](/customer-resources/single-node-to-cluster/)

  This document describes how to upgrade a Pryv.io single-node installation to a cluster one.

- (deprecated) User deletion: [PDF](/assets/docs/20190919-pryv.io-delete-user-v1.pdf)

  This document presents a tool which allows to delete Pryv.io users. From Pryv.io 1.6, user deletion is available through the [admin API](/reference-admin/#delete-user)

- How to backup: [HTML](/customer-resources/backup/)

  This document describes how to perform a backup of your Pryv.io platform and how to restore it.

- MFA configuration: [HTML](/customer-resources/mfa/)

  This document describes how to enable and configure multi-factor authentication on top of the Pryv.io login.


## Contact and support

You can get in touch with Pryv's support at [Open Pryv - Issues and question](https://github.com/pryv/open-pryv.io/issues)
