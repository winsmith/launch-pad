//
//  CKANSettings.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 03.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

public struct CKANKitSettings {
    var installations: [CKANInstallation]
    var selectedInstallationIndex: Int?
}

public struct CKANInstallation {
    /// KSP Installation Directory
    var kspDirectory: String?

    /// List of CKAN Repo URLs that are available for this KSP Installation
    var ckanRepositories: [URL] = [URL(string: "https://github.com/KSP-CKAN/CKAN-meta/archive/master.tar.gz")!]

    /// Minimum KSP Version detected ("1.3.1")
    var minKSPVersion: String?

    /// Maximum KSP Version detected ("1.3.1")
    var maxKSPVersion: String?

    var isInitialized: Bool {
        return kspDirectory != nil
    }
}
