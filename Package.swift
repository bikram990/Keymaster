import PackageDescription
let package = Package(
	name: "Keymaster",
    targets: [
    	Target(
            /** Cross-platform access to bare `libc` functionality. */
            name: "libc",
            dependencies: []),
        Target(
            /** “Swifty” POSIX functions from libc */
            name: "POSIX",
            dependencies: ["libc"]),
        Target(
            /** Basic support library */
            name: "Basic",
            dependencies: ["libc", "POSIX"]),
        Target(
            /** Abstractions for common operations, should migrate to Basic */
            name: "Utility",
            dependencies: ["POSIX", "Basic"]),
        Target(
            /** Source control operations */
            name: "SourceControl",
            dependencies: ["Basic", "Utility"]),
        Target(
            /** Source control operations */
            name: "Apple",
            dependencies: ["Basic", "Utility"]),
        Target(
            /** Source control operations */
            name: "Keymaster",
            dependencies: ["Basic", "SourceControl", "Apple"]),
    ],
    dependencies: [
    	.Package(url: "https://github.com/oarrabi/Guaka.git", majorVersion: 0),
    	.Package(url: "https://github.com/onevcat/Rainbow", majorVersion: 2),
    	.Package(url: "https://github.com/oarrabi/Process.git", majorVersion: 0),
    	.Package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", majorVersion: 0),
    ]
)
