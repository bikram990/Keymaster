import PackageDescription
let package = Package(
  name: "Keymaster",
  dependencies: [
    .Package(url: "https://github.com/oarrabi/Guaka.git", majorVersion: 0),
    .Package(url: "https://github.com/onevcat/Rainbow", majorVersion: 2),
    .Package(url: "https://github.com/oarrabi/Process.git", majorVersion: 0),
    .Package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", majorVersion: 0),
    .Package(url: "https://github.com/oarrabi/FileUtils.git", majorVersion: 0),
    ]
)
