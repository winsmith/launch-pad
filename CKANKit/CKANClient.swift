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
    public var kspInstallation: KSPInstallation
    public var isRepositoryInitialized: Bool { return kspInstallation.ckanRepository.modules?.count ?? 0 > 0 }
    public var modules: [CKANModule]? { return kspInstallation.ckanRepository.modules }
    public var newestCompatibleModules: [CKANModule] {
        return kspInstallation.ckanRepository.newestCompatibleModules(with: kspInstallation)
    }

    init(kspInstallation: KSPInstallation) {
        self.kspInstallation = kspInstallation
    }
}
