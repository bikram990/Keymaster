import Foundation
import Basic
import Utility
import Process

public enum ProvisioningProfileError: Swift.Error {
    case decodeError(error: String)
    case parseError
    case missingKey(key: ProvisioningProfileKey)
}

public enum Platform: String {
    case iOS, macOS, tvOS
}

public enum Type {
    case development, adhoc, appstore, enterprise
}

public enum EntitlementKey: String {
    case getTaskAllow = "get-task-allow"
    case betaReportsActive = "beta-reports-active"
}

public enum ProvisioningProfileKey: String {
    case uuid = "UUID"
    case platform = "Platform"
    case developerCertificates = "DeveloperCertificates"
    case teamName = "TeamName"
    case expirationDate = "ExpirationDate"
    case creationDate = "CreationDate"
    case entitlements = "Entitlements"
    case applicationIdentifierPrefix = "ApplicationIdentifierPrefix"
    case teamIdentifier = "TeamIdentifier"
    case name = "Name"
    case provisionedDevices = "ProvisionedDevices"
    case version = "Version"
    case appIDName = "AppIDName"
    case timeToLive = "TimeToLive"
    case provisionsAllDevices = "ProvisionsAllDevices"
}

public struct ProvisioningProfile {

    public let uuid: String
    public let platform: [Platform]
    public let developerCertificates: [Data]
    public let teamName: String
    public let expirationDate: Date
    public let creationDate: Date
    public let entitlements: [String: Any]
    public let applicationIdentifierPrefix: [String]
    public let teamIdentifier: [String]
    public let name: String
    public let provisionedDevices: [String]
    public let version: Int
    public let appIDName: String
    public let timeToLive: Int
    public let type: Type
    
    public init(with url: AbsolutePath) throws {
        // Decode provisioning profile first
        let result = Process.exec("\(Security.tool) cms -D -i \(url.asString)")
        
        guard result.exitStatus == 0 else {
            throw ProvisioningProfileError.decodeError(error: result.stderr)
        }
        
        // Now parse provisioning profile into something useful
        guard let data = result.stdout.data(using: .utf8),
            let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            throw ProvisioningProfileError.parseError
        }
        
        guard let uuid = plist[ProvisioningProfileKey.uuid.rawValue] as? String else {
            throw ProvisioningProfileError.missingKey(key: .uuid)
        }
        self.uuid = uuid
        
        guard let platform = plist[ProvisioningProfileKey.platform.rawValue] as? [String] else {
            throw ProvisioningProfileError.missingKey(key: .platform)
        }
        self.platform = platform.flatMap {
            return Platform(rawValue: $0)
        }
        
        self.developerCertificates = plist[ProvisioningProfileKey.developerCertificates.rawValue] as? [Data] ?? []
        
        guard let teamName = plist[ProvisioningProfileKey.teamName.rawValue] as? String else {
            throw ProvisioningProfileError.missingKey(key: .teamName)
        }
        self.teamName = teamName
        
        guard let expirationDate = plist[ProvisioningProfileKey.expirationDate.rawValue] as? Date else {
            throw ProvisioningProfileError.missingKey(key: .expirationDate)
        }
        self.expirationDate = expirationDate
        
        guard let creationDate = plist[ProvisioningProfileKey.creationDate.rawValue] as? Date else {
            throw ProvisioningProfileError.missingKey(key: .creationDate)
        }
        self.creationDate = creationDate
        
        self.entitlements = plist[ProvisioningProfileKey.entitlements.rawValue] as? [String: Any] ?? [:]
        
        guard let applicationIdentifierPrefix = plist[ProvisioningProfileKey.applicationIdentifierPrefix.rawValue] as? [String] else {
            throw ProvisioningProfileError.missingKey(key: .applicationIdentifierPrefix)
        }
        self.applicationIdentifierPrefix = applicationIdentifierPrefix
        
        guard let teamIdentifier = plist[ProvisioningProfileKey.teamIdentifier.rawValue] as? [String] else {
            throw ProvisioningProfileError.missingKey(key: .teamIdentifier)
        }
        self.teamIdentifier = teamIdentifier
        
        guard let name = plist[ProvisioningProfileKey.name.rawValue] as? String else {
            throw ProvisioningProfileError.missingKey(key: .name)
        }
        self.name = name
        
        self.provisionedDevices = plist[ProvisioningProfileKey.provisionedDevices.rawValue] as? [String] ?? []
        
        guard let version = plist[ProvisioningProfileKey.version.rawValue] as? Int else {
            throw ProvisioningProfileError.missingKey(key: .version)
        }
        self.version = version
        
        guard let appIDName = plist[ProvisioningProfileKey.appIDName.rawValue] as? String else {
            throw ProvisioningProfileError.missingKey(key: .appIDName)
        }
        self.appIDName = appIDName
        
        guard let timeToLive = plist[ProvisioningProfileKey.timeToLive.rawValue] as? Int else {
            throw ProvisioningProfileError.missingKey(key: .timeToLive)
        }
        self.timeToLive = timeToLive
        
        // Determine type of provisioning profile
        if let getTaskAllow = self.entitlements[EntitlementKey.getTaskAllow.rawValue] as? Bool, getTaskAllow {
            self.type = .development
        } else if let provisionsAllDevices = plist[ProvisioningProfileKey.provisionsAllDevices.rawValue] as? Bool, provisionsAllDevices {
            self.type = .enterprise
        } else if let betaReportsActive = self.entitlements[EntitlementKey.betaReportsActive.rawValue] as? Bool, betaReportsActive {
            self.type = .appstore
        } else {
            // Default to normal ad-hoc
            self.type = .adhoc
        }
    }
    
}
