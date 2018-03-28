//
//  Version.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 09.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

public struct VersionNumber: Equatable, Comparable, CustomStringConvertible {
    let major: Int
    let minor: Int
    let bugfix: Int

    init?(with versionString: String?) {
        guard let versionString = versionString else { return nil }

        let components = versionString.split(separator: ".")
        let digitOnlyComponents = components.map { String($0).digits }

        major = components.count > 0 ? Int(digitOnlyComponents[0])! : 0
        minor = components.count > 1 ? Int(digitOnlyComponents[1])! : 0
        bugfix = components.count > 2 ? Int(digitOnlyComponents[2])! : 0
    }

    public static func ==(lhs: VersionNumber, rhs: VersionNumber) -> Bool {
        return (
            lhs.major == rhs.major &&
            lhs.minor == rhs.minor &&
            lhs.bugfix == rhs.bugfix
        )
    }

    public static func <(lhs: VersionNumber, rhs: VersionNumber) -> Bool {
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
