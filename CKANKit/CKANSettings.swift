//
//  CKANSettings.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 03.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

struct CKANSharedSettings {
    let kspDirectories: [String]
}

struct CKANInstallationSettings {
    /// KSP Installation Directory
    let kspDirectory: String

    /// List of CKAN Repo URLs that are available for this KSP Install
    /// Default is "https://github.com/KSP-CKAN/CKAN-meta/archive/master.tar.gz"
    let ckanRepositories: [URL]

    /// Minimum KSP Version detected ("1.3.1")
    let minKSPVersion: String

    /// Maximum KSP Version detected ("1.3.1")
    let maxKSPVersion: String
}
