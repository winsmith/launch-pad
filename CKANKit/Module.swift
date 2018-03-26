//
//  Module.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 21.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

public class Module {
    public private(set) var releases: [Release]
    var latestRelease: Release { return releases.first! }

    var identifier: String { return latestRelease.identifier }
    var name: String { return latestRelease.name }
    var installedRelease: Release? {
        guard let metadata = ckanRepository?.metadataManager.metadata(for: self) else { return nil }
        return releases.filter { $0.version == metadata.installedVersion }.first
    }

    internal weak var ckanRepository: CKANRepository?

    init(firstRelease: Release) {
        releases = [firstRelease]
        firstRelease.module = self
    }

    func add(release: Release) {
        releases.append(release)
        releases.sort { $0 > $1 }
        release.module = self
    }

    func getLatestCompatibleRelease(with installation: KSPInstallation) -> Release? {
        return getCompatibleReleases(with: installation).first
    }

    func getCompatibleReleases(with installation: KSPInstallation) -> [Release] {
        return releases.filter { $0.isCompatible(with: installation) }
    }
}

extension Module: Comparable {
    public static func <(lhs: Module, rhs: Module) -> Bool {
        return lhs.name.replacingOccurrences(of: "'", with: "").trimmed < rhs.name.replacingOccurrences(of: "'", with: "").trimmed
    }

    public static func ==(lhs: Module, rhs: Module) -> Bool {
        return lhs.releases == rhs.releases
    }

    
}
