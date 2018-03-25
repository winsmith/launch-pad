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

    // MARK: - Internal CKANFile Properties
    private var installationInstructions: [CKANFile.InstallationDirective] { return ckanFile.install ?? [CKANFile.InstallationDirective]() }

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

            let copyProgress = Progress()
            copyProgress.localizedDescription = "Installing into \(kspInstallation.kspDirectory.path)..."
            progress?.addChild(copyProgress, withPendingUnitCount: 1)
            self.copyReleaseFilesToInstallation(kspInstallation: kspInstallation, progress: copyProgress)
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

    private func copyReleaseFilesToInstallation(kspInstallation: KSPInstallation, progress: Progress) {
        for installationInstruction in installationInstructions {
            self.install(installationInstruction, toInstallation: kspInstallation)
        }
    }

    /// https://github.com/KSP-CKAN/CKAN/blob/master/Spec.md#install
    private func install(_ installation: CKANFile.InstallationDirective, toInstallation: KSPInstallation) {
        logger.log("Processing installation directive...")

        let urlsToCopy = getSourceURLSFromInstallation(installation, withKSPInstallation: toInstallation)
        guard let destinationURL = getDestinationURLFromInstallationDirective(installation, withKSPInstallation: toInstallation) else {
            fatalError()
        }

        // TODO: as, filter, filter_regexp, include_only, include_only_regexp, find_matches_files

        for urlToCopy in urlsToCopy {
            do {
                let finalDestinationURL = destinationURL.appendingPathComponent(urlToCopy.lastPathComponent)
                logger.log("Creating all subdirectories of %@ ...", finalDestinationURL.path)
                try fileManager.createParentDirectoryStructure(for: finalDestinationURL)
                logger.log("Copying to %@ ...", finalDestinationURL.path)
                try fileManager.moveItem(at: urlToCopy, to: finalDestinationURL)
                logger.log("Copied to %@.", finalDestinationURL.path)
            } catch {
                logger.log("Failed to copy: %@", error.localizedDescription)
            }
        }

        logger.log("Done processing installation directive.")
    }

    private func getSourceURLSFromInstallation(_ installationDirective: CKANFile.InstallationDirective, withKSPInstallation kspInstallation: KSPInstallation) -> [URL] {
        var urlsToCopy = [URL]()

        // file: The file or directory root that this directive pertains to
        if let file = installationDirective.file {
            urlsToCopy.append(tempDirectoryURL.appendingPathComponent(file))
        }

        // find: Locate the top-most directory which exactly matches the name specified.
        else if let findDirective = installationDirective.find {
            guard let directoryEnumerator = fileManager.enumerator(atPath: tempDirectoryURL.path) else { return urlsToCopy }
            var mostFittingPath: String?
            var mostFittingPathDepth: Int = 99999

            while let element = directoryEnumerator.nextObject() as? String {
                if element.hasSuffix(findDirective) && mostFittingPathDepth > directoryEnumerator.level {
                    mostFittingPath = element
                    mostFittingPathDepth = directoryEnumerator.level
                }
            }
            if let mostFittingPath = mostFittingPath {
                let mostFittingPathURL = tempDirectoryURL.appendingPathComponent(mostFittingPath)
                urlsToCopy.append(mostFittingPathURL)
            }
        }

        // find_regexp: Locate the top-most directory which matches the specified regular expression
        else if let find_regexp = installationDirective.find_regexp {
            // TODO
        }

        logger.log("Generated %@ source URLs.", "\(urlsToCopy.count)")
        for urlToCopy in urlsToCopy {
            logger.log(" - %@", urlToCopy.path)
        }
        return urlsToCopy
    }

    private func getDestinationURLFromInstallationDirective(_ installationDirective: CKANFile.InstallationDirective, withKSPInstallation kspInstallation: KSPInstallation) -> URL? {
        logger.log("Parsing destination URL from '%@'...", "\(installationDirective.install_to)")

        let valid_values_that_allow_subdirectories = ["GameData", "Tutorial", "Scenarios"]
        let valid_values = valid_values_that_allow_subdirectories + ["GameRoot", "Missions", "Ships", "Ships/SPH", "Ships/VAB", "Ships/@thumbs/VAB", "Ships/@thumbs/SPH"]

        guard installationDirective.install_to.hasPrefix("GameData") || valid_values.contains(installationDirective.install_to) else {
            logger.log("Destination URL is invalid")
            return nil
        }
        guard installationDirective.install_to.contains("..") == false else {
            logger.log("Destination URL tries to traverse upward. Failing.")
            return nil
        }

        if installationDirective.install_to == "GameRoot" {
            logger.log("Destination URL is Game Root.")
            return kspInstallation.kspDirectory
        } else {
            let destinationURL = kspInstallation.kspDirectory.appendingPathComponent(installationDirective.install_to)
            logger.log("Destination URL is %@.", destinationURL.path)
            return destinationURL
        }
    }
}
