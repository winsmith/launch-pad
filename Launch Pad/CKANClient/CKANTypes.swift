//
//  CKANTypes.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 15.02.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

public struct KSPDir: Equatable {
    public static func ==(lhs: KSPDir, rhs: KSPDir) -> Bool {
        return lhs.path == rhs.path
    }

    var path: String
}

public struct Module: Equatable {
    var key: String
    var name: String
    var version: String
    var isInstalled: Bool

    public static func ==(lhs: Module, rhs: Module) -> Bool {
        return lhs.key == rhs.key && lhs.version == rhs.version
    }
}
