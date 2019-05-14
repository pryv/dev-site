module.exports =
  hostings: [
    regions:
      europe:
        name: "Europe"
        localizedName:
          fr: "Europe"
        zones:
          switzerland:
            name: "Switzerland"
            localizedName:
              fr: "Suisse"
            hostings:
              core1:
                url: "https://my-hosting-provider.ch"
                name: "Pilot core server"
                description: "The single PoC core server"
                available: true
  ]
  platforms: [
    "pryv.me"
  ]
  appids: [
    "default"
  ],
  invitationTokens: [
    "o3in4o2"
  ],
  languageCodes: [
    "en",
    "fr"
  ],
  referers: [
    "hospital-A"
  ],
  servers: [
    "core1",
    "core2"
  ],
  serviceInfos:
    version: "0.1.0",
    register: "https://reg.pryv.me",
    access: "https://access.pryv.io/access",
    api: "https://{username}.pryv.io/",
    name: "Pryv Lab",
    home: "https://sw.pryv.me",
    support: "http://pryv.com/helpdesk",
    terms: "http://pryv.com/pryv-lab-terms-of-use/"
