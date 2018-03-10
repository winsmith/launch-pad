//
//  Version.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 09.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

public struct Version: Equatable, Comparable, CustomStringConvertible {
    let major: Int
    let minor: Int
    let bugfix: Int

    init?(with versionString: String?) {
        guard let versionString = versionString else { return nil }

        let components = versionString.split(separator: ".")
        major = components.count > 0 ? Int(components[0])! : 0
        minor = components.count > 1 ? Int(components[1])! : 0
        bugfix = components.count > 2 ? Int(components[2])! : 0
    }

    public static func ==(lhs: Version, rhs: Version) -> Bool {
        return (
            lhs.major == rhs.major &&
            lhs.minor == rhs.minor &&
            lhs.bugfix == rhs.bugfix
        )
    }

    public static func <(lhs: Version, rhs: Version) -> Bool {
        // TODO: This seems to be not entirely correct
        // e.g. 1.0.5 > 1.3.1 somehow

        if lhs.major >= rhs.major { return false }
        if lhs.minor >= rhs.minor { return false }
        if lhs.bugfix >= rhs.bugfix { return false }
        return true
    }

    public var description: String {
        return "\(major).\(minor).\(bugfix)"
    }
}
