//
//  CKANSettings.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 03.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

private enum KSPInstallationKeys: String {
    case kspDirectory = "kspDirectory"
    case kspVersion = "kspVersion"
}

public struct KSPInstallation {
    /// KSP Installation Directory
    var kspDirectory: URL

    /// CKAN Repository to use for this installation
    var ckanRepository: CKANRepository

    /// KSP Version detected ("1.3.1")
    var kspVersion: VersionNumber

    public func toDictionary() -> [String: String?] {
        return [
            KSPInstallationKeys.kspDirectory.rawValue: kspDirectory.path,
            KSPInstallationKeys.kspVersion.rawValue: kspVersion.description
        ]
    }

    init?(kspDirectory: URL) {
        // check for readme.txt
        let readmeFileURL = kspDirectory.appendingPathComponent("readme.txt")
        guard FileManager.default.fileExists(atPath: readmeFileURL.path) else { return nil }


        // parse readme.txt
        guard let readmeContents = try? String(contentsOf: readmeFileURL, encoding: .ascii) else {
            print("Error while reading readme.txt")
            return nil
        }

        guard let versionString = KSPInstallation.versionFromReadme(readmeContents: readmeContents) else {
            print("failed to retrieve version number from readme file")
            return nil
        }

        guard let version = VersionNumber(with: versionString) else {
            print("Failed to parse '\(versionString)' as Version")
            return nil
        }

        // Initialize
        self.kspDirectory = kspDirectory
        self.ckanRepository = CKANRepository(inDirectory: kspDirectory.appendingPathComponent("LaunchPad"))
        self.kspVersion = version
    }

    init?(from dict: [String: String?]){
        guard let kspDirectoryString = dict[KSPInstallationKeys.kspDirectory.rawValue] else { return nil }
        guard let kspDirectoryStringUnpacked = kspDirectoryString else { return nil }
        guard let kspVersionString = dict[KSPInstallationKeys.kspVersion.rawValue] else { return nil}
        guard let kspVersionStringUnpacked = kspVersionString else { return nil }
        guard let version = VersionNumber(with: kspVersionStringUnpacked) else { return nil }

        let kspDirectoryURL = URL(fileURLWithPath: kspDirectoryStringUnpacked)
        self.kspDirectory = kspDirectoryURL
        self.ckanRepository = CKANRepository(inDirectory: kspDirectoryURL.appendingPathComponent("LaunchPad"))
        self.kspVersion = version
    }

    private static func versionFromReadme(readmeContents: String) -> String? {
        for line in readmeContents.split(separator: "\n") {
            if line.starts(with: "Version") {
                let versionNumber = line.split(separator: " ")[1]
                return String(versionNumber)
            }
        }

        return nil
    }
}
