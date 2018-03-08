//
//  CKANClient.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 08.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

public class CKANClient {
    /// If true, the client has all the settings available to start installing mods
    public var isFullyInitialized: Bool {
        guard let installationIndex = ckanKitSettings.selectedInstallationIndex else { return false }
        let currentInstallation = ckanKitSettings.installations[installationIndex]
        return currentInstallation.isInitialized
    }

    public let ckanKitSettings: CKANKitSettings

    init(ckanKitSettings: CKANKitSettings) {
        self.ckanKitSettings = ckanKitSettings
    }
}
