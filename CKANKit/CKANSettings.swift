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

public struct KSPInstallation {
    /// KSP Installation Directory
    var kspDirectory: URL?

    /// CKAN Repository to use for this installation
    var ckanRepository: CKANRepository?

    /// Minimum KSP Version detected ("1.3.1")
    var minKSPVersion: String?

    /// Maximum KSP Version detected ("1.3.1")
    var maxKSPVersion: String?

    var isInitialized: Bool {
        return kspDirectory != nil && minKSPVersion != nil && maxKSPVersion != nil
    }
}
