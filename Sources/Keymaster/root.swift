import Foundation
import Guaka
import Apple
import Basic

var rootCommand = Command(usage: "Keymaster", configuration: configuration, run: execute)

private func configuration(command: Command) {
    // Setup flags
    let path = Flag(shortName: "p", longName: "profilePath",
                         value: "", description: "Path to a provisioning profile.")
    
    command.add(flags: [path])
}

private func execute(flags: Flags, args: [String]) {
    let path = flags.getString(name: "profilePath") ?? ""
    let profilePath = AbsolutePath(path)
    do {
        let profile = try ProvisioningProfile(with: profilePath)
        print(profile.uuid)
        print(profile.platform)
        print(profile.developerCertificates)
        print(profile.teamName)
        print(profile.expirationDate)
        print(profile.creationDate)
        print(profile.type)
    } catch ProvisioningProfileError.decodeError(let error) {
        print(error)
    } catch ProvisioningProfileError.missingKey(let key) {
        print("Missing key: \(key)")
    } catch {
        print("Another error!")
    }
}
