//
//  CKANModule.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 09.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation
import os

public class Release {
    // MARK: - Private Properties
    let ckanFile: CKANFile

    // MARK: - Init
    init(ckanFile: CKANFile) {
        self.ckanFile = ckanFile
        self.logger = Logger(category: "\(ckanFile.identifier) \(ckanFile.version)", subsystem: "CKANKit")
    }

    // MARK: - Properties
    var identifier: String { return ckanFile.identifier }
    var isInstalled: Bool { return false }
    var name: String { return ckanFile.name }
    var authors: [String]? { return ckanFile.author?.arrayValue }
    var version: String? { return ckanFile.version }
    var kspVersionMax: VersionNumber? { return VersionNumber(with: ckanFile.ksp_version_max) }
    var kspVersionMin: VersionNumber? { return VersionNumber(with: ckanFile.ksp_version_min) }
    var downloadSize: Int? { return ckanFile.download_size }
    var licenses: [String]? { return ckanFile.license.arrayValue }

    var abstract: String? { return ckanFile.abstract }
    var detailDescription: String? { return ckanFile.description }

    var resources: [String: CKANFile.ResourceURL]? { return ckanFile.resources }
    var dependencies: [CKANFile.Relationship]? { return ckanFile.depends }
    var suggestions: [CKANFile.Relationship]? { return ckanFile.suggests }

    var downloadURL: URL { return ckanFile.download }

    // MARK: - Private Properties
    private let fileManager = FileManager.default
    private let logger: Logger

    // MARK: - Meta, etc
    public func isCompatible(with installation: KSPInstallation) -> Bool {
        guard let kspVersionMax = kspVersionMax, let kspVersionMin = kspVersionMin else { return false }
        
        return (
            kspVersionMax >= installation.kspVersion &&
            kspVersionMin <= installation.kspVersion
        )
    }
}

// MARK: - Equatable
extension Release: Comparable {
    public static func <(lhs: Release, rhs: Release) -> Bool {
        // TODO: Check that only Releases of the same module are compared

        guard let lhsVersion = lhs.version else { return true }
        guard let rhsVersion = rhs.version else { return false }
        return lhsVersion < rhsVersion
    }

    public static func ==(lhs: Release, rhs: Release) -> Bool {
        return lhs.ckanFile == rhs.ckanFile
    }
}

// MARK: - CustomStringConvertible
extension Release: CustomStringConvertible {
    public var description: String {
        return "Release: \(identifier) (\(version ?? "no version specified"))"
    }
}

// MARK: - Installing
extension Release {
    public func install(to kspInstallation: KSPInstallation, progress: Progress?, callback: @escaping () -> ()) {
        logger.log("Beginning install into %@", kspInstallation.kspDirectory.path)

        guard !isInstalled else {
            logger.log("Cancelling installation because the release is already installed")
            return
        }

        prepareTempDirectories()
        let downloadProgress = downloadReleaseArchive() { localURL in
            let unzipProgress = Progress()
            unzipProgress.localizedDescription = "Unpacking..."
            progress?.addChild(unzipProgress, withPendingUnitCount: 3)
            self.unpackReleaseArchive(kspInstallation: kspInstallation, progress: unzipProgress)
            callback()
        }
        downloadProgress.localizedDescription = "Downloading..."
        if let progress = progress {
            progress.addChild(downloadProgress, withPendingUnitCount: 2)
        }
    }

    // MARK: URLs
    private var tempDirectoryURL: URL { return URL(fileURLWithPath: "/tmp").appendingPathComponent(identifier) }
    private var localDownloadedArchiveURL: URL { return tempDirectoryURL.appendingPathComponent(downloadURL.lastPathComponent) }

    private func prepareTempDirectories() {
        logger.log("Preparing Temp Directory at %@ ...", tempDirectoryURL.path)

        if fileManager.fileExists(atPath: tempDirectoryURL.path) {
            logger.log("Temp directory already exists, removing...")
            do {
                try fileManager.removeItem(atPath: tempDirectoryURL.path)
                logger.log("Removed old temp directory.")
            }
            catch {
                logger.log("Error while removing previous temp directory: %@", error.localizedDescription)
                print(error)
            }
        }

        do {
            logger.log("Creating Temp directory...")
            try fileManager.createDirectory(at: tempDirectoryURL, withIntermediateDirectories: true, attributes: nil)
            logger.log("Created Temp directory.")
        }
        catch {
            logger.log("Error while creating temp directory: %@", error.localizedDescription)
            print(error)
        }

        logger.log("Preparing Temp Directory complete.")
    }

    private func downloadReleaseArchive(_ callback: @escaping (_ downloadedURL: URL) -> ()) -> Progress {
        logger.log("Downloading %@ ...", downloadURL.absoluteString)

        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.downloadTask(with: URLRequest(url: downloadURL)) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                do {
                    try self.fileManager.copyItem(at: tempLocalUrl, to: self.localDownloadedArchiveURL)
                    self.logger.log("Download successful.")
                    callback(self.localDownloadedArchiveURL)
                } catch (let writeError) {
                    self.logger.log("Failed to save downloaded file: %@", writeError.localizedDescription)
                    print("error writing file \(self.localDownloadedArchiveURL) : \(writeError)")
                }
            } else {
                let errorString = error?.localizedDescription ?? "Unknown Error"
                self.logger.log("Download failed: %@", errorString)
            }
        }
        task.resume()
        return task.progress
    }

    private func unpackReleaseArchive(kspInstallation: KSPInstallation, progress: Progress) {
        logger.log("Unpacking into %@ ...", tempDirectoryURL.path)

        do {
            try fileManager.unzipItem(at: localDownloadedArchiveURL, to: tempDirectoryURL, progress: progress)
            logger.log("Unpacking successful")
        } catch CocoaError.fileWriteFileExists {
            logger.log("Unpacking failed because a file already exists at the target path.")
        } catch {
            logger.log("Unpacking failed with error: %@", error.localizedDescription)
        }
    }
}
