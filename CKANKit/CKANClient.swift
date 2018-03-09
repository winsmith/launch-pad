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
    public var isFullyInitialized: Bool {
        return ckanKitSettings.currentInstallation?.isInitialized == true
    }

    public var ckanKitSettings: CKANKitSettings

    init(ckanKitSettings: CKANKitSettings) {
        self.ckanKitSettings = ckanKitSettings
    }

    public func addKSPDir(url: URL) -> Bool {
        // check for readme.txt
        let readmeFileURL = url.appendingPathComponent("readme.txt")
        guard FileManager.default.fileExists(atPath: readmeFileURL.path) else { return false }

        // parse readme.txt
        guard let readmeContents = try? String(contentsOf: readmeFileURL, encoding: .ascii) else {
            print("Error while reading readme.txt")
            return false
        }

        guard let version = versionFromReadme(readmeContents: readmeContents) else {
            print("failed to retrieve version number from readme file")
            return false
        }

        let installation = KSPInstallation(kspDirectory: url, ckanRepository: CKANRepository(inDirectory: url.appendingPathComponent("LaunchPad")), minKSPVersion: version, maxKSPVersion: version)
        ckanKitSettings.currentInstallation = installation

        // TODO: Save version
        return true
    }

    private func versionFromReadme(readmeContents: String) -> String? {
        for line in readmeContents.split(separator: "\n") {
            if line.starts(with: "Version") {
                let versionNumber = line.split(separator: " ")[1]
                return String(versionNumber)
            }
        }

        return nil
    }
}
