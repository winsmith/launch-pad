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
