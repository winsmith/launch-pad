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
    var identifier: String { return ckanFile.identifier }
    var isInstalled: Bool { return false }
    var name: String { return ckanFile.name }
    var authors: [String]? { return ckanFile.author?.arrayValue }
    var version: String? { return ckanFile.version }
    var kspVersionMax: Version? { return Version(with: ckanFile.ksp_version_max) }
    var kspVersionMin: Version? { return Version(with: ckanFile.ksp_version_min) }
    var downloadSize: Int? { return ckanFile.download_size }
    var licenses: [String]? { return ckanFile.license.arrayValue }

    var abstract: String? { return ckanFile.abstract }
    var description: String? { return ckanFile.description }

    var resources: [String: CKANFile.ResourceURL]? { return ckanFile.resources }
    var dependencies: [CKANFile.Relationship]? { return ckanFile.depends }
    var suggestions: [CKANFile.Relationship]? { return ckanFile.suggests }

    var downloadURL: URL { return ckanFile.download }

    // MARK: - Private Properties
    private let fileManager = FileManager.default

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
extension CKANModule: Comparable {
    public static func <(lhs: CKANModule, rhs: CKANModule) -> Bool {
        guard let lhsVersion = lhs.version else { return true }
        guard let rhsVersion = rhs.version else { return false }
        return lhsVersion < rhsVersion
    }

    public static func ==(lhs: CKANModule, rhs: CKANModule) -> Bool {
        return lhs.ckanFile == rhs.ckanFile
    }
}

// MARK: - Installing
extension CKANModule {
    public func install(to kspInstallation: KSPInstallation, progress: Progress?, callback: @escaping () -> ()) {
        guard !isInstalled else { return }

        prepare()
        let downloadProgress = download() { localURL in
            let unzipProgress = Progress()
            unzipProgress.kind = ProgressKind(rawValue: "Unpacking...")
            progress?.addChild(unzipProgress, withPendingUnitCount: 20)
            let unpackSuccessful = self.unpack(zipFileURL: localURL, kspInstallation: kspInstallation, progress: unzipProgress)
            guard unpackSuccessful else { fatalError() }
            callback()
        }
        downloadProgress.kind = ProgressKind(rawValue: "Downloading...")
        if let progress = progress {
            progress.addChild(downloadProgress, withPendingUnitCount: 10)
        }
    }

    private func tempDirectoryURL() -> URL {
        return URL(fileURLWithPath: "/tmp").appendingPathComponent(identifier)
    }

    private func prepare() {
        if fileManager.fileExists(atPath: tempDirectoryURL().path) {
            do {
                try fileManager.removeItem(atPath: "subfolder")
                try fileManager.createDirectory(at: tempDirectoryURL(), withIntermediateDirectories: true, attributes: nil)
            }
            catch { print(error) }
        }
    }

    private func download(_ callback: @escaping (_ downloadedURL: URL) -> ()) -> Progress {
        let localUrl = tempDirectoryURL().appendingPathComponent(downloadURL.lastPathComponent)
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: downloadURL)
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }

                do {
                    try self.fileManager.copyItem(at: tempLocalUrl, to: localUrl)
                    callback(localUrl)
                } catch (let writeError) {
                    print("error writing file \(localUrl) : \(writeError)")
                }

            } else {
                print("Failure: \(error?.localizedDescription ?? ":("))")
            }
        }
        task.resume()
        return task.progress
    }

    private func unpack(zipFileURL: URL, kspInstallation: KSPInstallation, progress: Progress) -> Bool {
        let sourceUrl = zipFileURL
        let destinationUrl = kspInstallation.kspDirectory.appendingPathComponent("GameData")

        do {
            try fileManager.unzipItem(at: sourceUrl, to: destinationUrl, progress: progress)
            return true
        } catch CocoaError.fileWriteFileExists {
            // File Exists
            print("Nothing unpacked, file exists")
        } catch {
            print("Extraction of ZIP archive failed with error:\(error)")
        }
        return false
    }
}
