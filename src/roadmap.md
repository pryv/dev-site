---
id: roadmap
title: 'Pryv.io roadmap'
layout: default.pug
withTOC: true
---

# Future releases

- **Support oAuth 2.0 protocol for authentication and authorization**

# Released

## 07.05.2023 - 1.8.1

- Fixes migration issues found in 1.8.0  

## 07.10.2022 - Dynamic mapping support & HDS SECU_AUTH with 1.8.0

- Expose external (e.g. legacy) data warehouses through Pryv.io: [see original announcement](https://www.pryv.com/2022/01/19/pryv-personal-data-mapping-enables-automatic-integration-with-existing-warehouses-bridging-the-gap-for-privacy-compliance-and-managing-data-subject-requests-on-personal-data-access-and-proce/) (documentation on request)
- Compliance with HDS requirements SECU_AUTH 3 & 4: Enforce rules for password complexity and password age (including past passwords history)

## 12.11.2021 - Automatic SSL certificate generation with Pryv.io 1.7.4

- Pryv introduces a service that generates a SSL certificate for your running Pryv.io installation and deploys it to all machines for cluster and single-node.
See [Generate SSL certificate guide](/customer-resources/ssl-certificate/) for more information.

## 25.10.2021 - New features with Pryv.io 1.7.0

- Audit log has been rebuilt, improving performance of fetched audit data, adding granularity over which methods are audited. See the [Audit guide](/guides/audit-logs/) on how to use them and see the [Audit setup guide](/customer-resources/audit-setup/) on how to set it up on your Pryv.io platform.
- New integrity feature, computing hash for events, attachments and accesses data.
- Automated platform upgrade tool. See "Find Migrations" button in Admin panel and check [changelog](/change-log/) for API.

## 26.04.2021 - new MFA release with Pryv.io 1.6.20

New MFA release:

- New [MFA configuration guide](/customer-resources/mfa/)
- Support for simple communication services: [single mode](/customer-resources/mfa/#modes)
- Expand current implementation to template what is sent to the communcation service and store only user values in profiles.
- Deactivate MFA through the Admin panel & API. See [change log](/change-log/).

## 11.01.2021 - Complete admin and system API

[Admin](/reference-admin/) and [system](/reference-system/) API references are now complete and available through [Open API definitions](/open-api/#definition-file).

## 15.12.2020 - Stream queries

You can now query events with more precision using [Streams queries](/reference/#streams-query).

## 25.11.2020 - Open Pryv.io image for [Exoscale marketplace](https://www.exoscale.com/marketplace/)

Open Pryv.io ready-to-go on Exoscale cloud service, allowing you to deploy Open Pryv instantaneously with minimal start-up configuration from [here](https://api.pryv.com/ops-image-exoscale-open-pryv.io/).

## 22.10.2020 - React Native support for lib-js

A react native application using the [Pryv.io JavaScript library](https://github.com/pryv/lib-js) is now available in our [Github repository](https://github.com/pryv/app-react-native-example).
This app example displays an implementation of Pryv.io authentication protocol.

## 20.10.2020 - Consent implementation with Pryv.io

We have released our new [tech guide](https://api.pryv.com/guides/consent) to help developers manage consent when building personal data collecting applications to satisfy existing and forthcoming privacy regulations. It outlines the logic of managing consent with Pryv.io, and guides you through a practical hands-on example involving a consent request. More information on how to leverage your compliance in our [article](https://support.pryv.com/hc/en-us/articles/360017196459-Consent-management-with-Pryv-io).

## 28.09.2020 - System Streams with Pryv.io <span onclick="location='/concepts/#entreprise-license-open-source-license'" class="entreprise-tag"><span title="Entreprise License Only" class="label">Y</span></span>

Now user registration could be customized using the Pryv.io configuration. Either you want to have a registration without an email or
have your own unique fields, now it is possible to do so. Also, admin panel users could easily delete not active users.

## 27.08.2020 - Collect and Share High Frequency Data with Pryv.io <span onclick="location='/concepts/#entreprise-license-open-source-license'" class="entreprise-tag"><span title="Entreprise License Only" class="label">Y</span></span>

Push the boundaries of your High Frequency Data. Discover how to collect, view and share high-frequency data in our [tutorial video](https://www.youtube.com/watch?v=l6uOXr1_ivA) for our high-frequency app.
The code for the Desktop and Mobile version is available in our [Github repository](https://github.com/pryv/example-apps-web/tree/release/hf-example/hf-data).

Read more about high frequency data [here](https://support.pryv.com/hc/en-us/articles/360014131139).

## 24.08.2020 - Custom Authentication with Pryv.io

Provide your Pryv.io platform with a custom auth step to authenticate your Pryv.io API requests or authorize them against another web service. Detailed information in our [new technical guide](/guides/custom-auth/), illustrated with our [video use case](https://www.youtube.com/watch?v=Z1Ufo_9b_E4&feature=youtu.be): *How to check Alice's identity when she tries to access Bob's data for which he gave her access to ?*

## 12.08.2020 - Admin panel for Pryv.io <span onclick="location='/concepts/#entreprise-license-open-source-license'" class="entreprise-tag"><span title="Entreprise License Only" class="label">Y</span></span>

We have released a web application for your Pryv.io platform administration. It allows you to manage the platform settings of your platform. Contact us directly if you wish to get your admin panel for Pryv.io!

## 10.08.2020 - Data Modelling guide

Our new [Data modelling guide](/guides/data-modelling/) is out, illustrating multiple use cases that can be implemented using the Pryv.io API.

## 05.08.2020 - "Change password" page

The additional `/change-password.html` page has been published among our [template web pages](https://github.com/pryv/app-web-auth3) to register, authenticate and password modification for your app users.

You can discover the authentication process for your Open Pryv.io platform in our [video tutorial](https://youtu.be/MfGTAgXr2WI). and fork our [Github repository](https://github.com/pryv/app-web-auth3/fork) to customize it.

## 31.07.2020 - Develop your iOS applications with Pryv.io

Our new [Swift library](https://github.com/pryv/lib-swift) facilitates writing iOS apps for a Pryv.io platform, and provides an [Apple HealthKit bridge](https://github.com/pryv/bridge-ios-healthkit) between HealthKit data samples and Pryv.io streams.

Learn how to grow your own [iOS App(le)s](https://github.com/pryv/app-ios-swift-example) in this video: https://youtu.be/poWC__m8ZFU.

Discover Apple HealthKit bridge video here: https://youtu.be/PIBh2_joFqQ.

More on the release [here](https://support.pryv.com/hc/en-us/articles/360015645339-Develop-iOS-applications-with-our-Swift-library).

## 24.07.2020 - View and share data

Following our [Collect survey data tutorial](https://github.com/pryv/example-apps-web/tree/master/collect-survey-data), enable your users to visualize and share data with our new template web app.
- Github repository for [View and Share data](https://github.com/pryv/example-apps-web/tree/master/view-and-share) web app
- Check our [video tutorial](https://youtu.be/gEfPmkQmtAI)

## 23.07.2020 - Register and authenticate your users

Learn how to use our [template web pages](https://github.com/pryv/app-web-auth3) to register and authenticate your app users in our new [video tutorial](https://youtu.be/MfGTAgXr2WI).
Simplify your authorization process for your Open Pryv.io platform by forking our [Github repository](https://github.com/pryv/app-web-auth3/fork).

## 15.07.2020 - Dockerized Open Pryv.io

Open Pryv.io is now available through Docker containers : discover the new release [here](https://support.pryv.com/hc/en-us/articles/360015324699-Open-Pryv-io-now-available-through-Docker-containers) and [swim](https://youtu.be/RwxEo4c_ed0) with the whale.

## 14.07.2020 - Customize your Pryv.io web apps

A new tutorial on how to customize assets in your web apps is now available on [Github](https://github.com/pryv/example-apps-web/tree/master/customize-assets). Check the video tutorial [here](https://youtu.be/VI1zjLLcR9Q).

## 06.07.2020 - Pryv.io Onboarding

Learn how to implement an onboarding experience for your app users by watching our [video tutorial](https://www.youtube.com/watch?v=258UsM1Qq0o&t=12s) and the [Github implementation](https://github.com/pryv/example-apps-web/tree/master/onboarding).

## 03.07.2020 - Collect survey data with Pryv.io

Discover how to easily create a form and collect data with Pryv.io in our [tutorial video](https://www.youtube.com/watch?v=SN11LSxL8q4). The web app is available in our [Github repositery](https://github.com/pryv/example-apps-web/tree/master/collect-survey-data) to help you implement your own.

## 08.06.2020 - Pryv.io goes Open Source

Pryv releases an [Open-Source Solution](https://support.pryv.com/hc/en-us/articles/360015327139-Pryv-io-gets-Open-Source) for Personal Data & Privacy Management.

## 17.01.2020 - Pryv.io integration with Postman

Check how Postman can help to facilitate & accelerate the Pryv.io API integration [here](https://support.pryv.com/hc/en-us/articles/360015309120-Pryv-io-integration-with-Postman).

## 04.01.2020 - Webhooks at Pryv.io <span onclick="location='/concepts/#entreprise-license-open-source-license'" class="entreprise-tag"><span title="Entreprise License Only" class="label">Y</span></span>

Pryv.io notifies your app of any data changes from now. Learn more about Webhooks [here](https://support.pryv.com/hc/en-us/articles/360014071180-Webhooks-at-Pryv-io) (available for [Entreprise license](https://api.pryv.com/concepts/#entreprise-license-open-source-license) only).
Our [Webhooks technical guide](/guides/webhooks/) explains their different features and how they are set up.

## 23.11.2019 - Audit Logs in Pryv.io <span onclick="location='/concepts/#entreprise-license-open-source-license'" class="entreprise-tag"><span title="Entreprise License Only" class="label">Y</span></span>

Keep track of actions performed by your app users against Pryv.io accounts with [audit logs](https://support.pryv.com/hc/en-us/articles/360015326619-Audit-Logs-in-Pryv-io) (available for [Entreprise license](https://api.pryv.com/concepts/#entreprise-license-open-source-license) only).

## 02.06.2019 - High Frequency Data in Pryv.io <span onclick="location='/concepts/#entreprise-license-open-source-license'" class="entreprise-tag"><span title="Entreprise License Only" class="label">Y</span></span>

Learn more about how you can store data at high frequency and high data density in Pryv.io [here](https://support.pryv.com/hc/en-us/articles/360014131139-High-Frequency-data-in-Pryv-io) (available for [Entreprise license](https://api.pryv.com/concepts/#entreprise-license-open-source-license) only).