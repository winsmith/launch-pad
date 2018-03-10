//
//  CKANModule.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 09.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

public class CKANModule {
    // MARK: - Private Properties
    let ckanFile: CKANFile

    // MARK: - Init
    init(ckanFile: CKANFile) {
        self.ckanFile = ckanFile
    }

    // MARK: - Properties
    var isInstalled: Bool { return false }
    var name: String { return ckanFile.name }
    var authors: [String]? { return ckanFile.author?.arrayValue }
    var version: String? { return ckanFile.version }
    var kspVersionMax: Version? { return Version(with: ckanFile.ksp_version_max) }
    var kspVersionMin: Version? { return Version(with: ckanFile.ksp_version_min) }
    var downloadSize: Int? { return ckanFile.download_size }
    var licenses: [String]? { return ckanFile.license.arrayValue }

    var abstract: String? { return ckanFile.abstract }
    var description: String? { return ckanFile.description }

    // MARK: - Installation, etc
    public func isCompatible(with installation: KSPInstallation) -> Bool {
        guard let kspVersionMax = kspVersionMax, let kspVersionMin = kspVersionMin else { return false }
        return (
            kspVersionMax <= installation.kspVersion &&
            kspVersionMin >= installation.kspVersion
        )
    }
}

// MARK: - Equatable
extension CKANModule: Equatable {
    public static func ==(lhs: CKANModule, rhs: CKANModule) -> Bool {
        return lhs.ckanFile == rhs.ckanFile
    }
}
