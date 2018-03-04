//
//  CKANRepository.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 03.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

class CKANRepository {
    let sharedSettings: CKANSharedSettings
    let installationSettings: CKANInstallationSettings

    init(sharedSettings: CKANSharedSettings, installationSettings: CKANInstallationSettings) {
        self.sharedSettings = sharedSettings
        self.installationSettings = installationSettings
        self.read_repository_data()
    }

    func read_repository_data() {
        
    }
}
