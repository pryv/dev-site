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
  ]