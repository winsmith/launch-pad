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
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        } else if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        } else {
            return lhs.bugfix < rhs.bugfix
        }
    }

    public var description: String {
        return "\(major).\(minor).\(bugfix)"
    }
}
