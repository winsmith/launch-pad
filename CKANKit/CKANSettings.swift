//
//  CKANSettings.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 03.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

public struct CKANKitSettings {
    var currentInstallation: KSPInstallation?
}

private enum KSPInstallationKeys: String {
    case kspDirectory = "kspDirectory"
    case kspVersion = "kspVersion"
}

public struct KSPInstallation {
    /// KSP Installation Directory
    var kspDirectory: URL?

    /// CKAN Repository to use for this installation
    var ckanRepository: CKANRepository?

    /// KSP Version detected ("1.3.1")
    var kspVersion: Version?

    var isInitialized: Bool {
        return kspDirectory != nil && kspVersion != nil
    }

    public func toDictionary() -> [String: String?] {
        return [
            KSPInstallationKeys.kspDirectory.rawValue: kspDirectory?.path,
            KSPInstallationKeys.kspVersion.rawValue: kspVersion?.description
        ]
    }

    init(kspDirectory: URL?, ckanRepository: CKANRepository?, kspVersion: Version?) {
        self.kspDirectory = kspDirectory
        self.ckanRepository = ckanRepository
        self.kspVersion = kspVersion
    }

    init?(from dict: [String: String?]){
        guard let kspDirectoryString = dict[KSPInstallationKeys.kspDirectory.rawValue] else { return nil }
        if let oaijd = kspDirectoryString {
            let kspDirectoryURL = URL(fileURLWithPath: oaijd)
            self.kspDirectory = kspDirectoryURL
        }

        guard let kspVersionString = dict[KSPInstallationKeys.kspVersion.rawValue] else { return nil}
        if let kspVersionStringUnpacked = kspVersionString {
            self.kspVersion = Version(with: kspVersionStringUnpacked)
        }
    }
}
