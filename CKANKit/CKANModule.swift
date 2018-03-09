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
    var version: String { return ckanFile.version }

    // MARK: - Installation, etc
}

// MARK: - Equatable
extension CKANModule: Equatable {
    public static func ==(lhs: CKANModule, rhs: CKANModule) -> Bool {
        return lhs.ckanFile == rhs.ckanFile
    }
}
