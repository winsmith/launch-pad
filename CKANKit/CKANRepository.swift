//
//  CKANRepository.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 03.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation
// import ZIPFoundation

class CKANRepository {
    // MARK: - Properties
    // MARK: Configuration
    let downloadURL: URL
    let workingDirectory: URL

    // MARK: CKANFiles
    var ckanFiles: [CKANFile]?

    // MARK: URLs
    private let zipFileName = "ckan_meta.zip"
    private let cachePlistFileName = "ckan_cache.plist"
    private var zipFileURL: URL { return workingDirectory.appendingPathComponent(zipFileName) }
    private var cachePlistURL: URL { return workingDirectory.appendingPathComponent(cachePlistFileName) }

    // MARK: Private
    private let fileManager = FileManager.default
    private let decoder = JSONDecoder()

    // MARK: - Initialization
    init(inDirectory workingDirectory: URL, withDownloadURL downloadURL: URL) {
        self.workingDirectory = workingDirectory
        self.downloadURL = downloadURL
    }

    func repositoryZIPFileExists() -> Bool {
        return fileManager.fileExists(atPath: zipFileURL.path)
    }

    func downloadRepositoryArchive(callback: @escaping (_ localArchiveURL: URL) -> ()) {
        let localUrl = zipFileURL
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
    }

    func unpackRepositoryArchive() -> Bool {
        let sourceUrl = zipFileURL
        let destinationUrl = workingDirectory

        do {
            try fileManager.unzipItem(at: sourceUrl, to: destinationUrl)
            return true
        } catch CocoaError.fileWriteFileExists {
            // File Exists
            print("Nothing unpacked, file exists")
        } catch {
            print("Extraction of ZIP archive failed with error:\(error)")
        }
        return false
    }

    func readUnpackedRepositoryArchive(rootDirectoryURL: URL) {
        let enumerator = fileManager.enumerator(at: rootDirectoryURL, includingPropertiesForKeys: [], options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
            print("directoryEnumerator error at \(url): ", error)
            return true
        })!

        var newCkanFiles = [CKANFile]()
        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension == "ckan" {
                print("Decoding", fileURL.path)
                do {
                    let fileData = try Data(contentsOf: fileURL)
                    let ckanFile = try decoder.decode(CKANFile.self, from: fileData)
                    newCkanFiles.append(ckanFile)
                } catch let error {
                    print(error)
                    fatalError()
                }
            }
        }

        print("Decoding complete! \(newCkanFiles.count) files decoded")
        ckanFiles = newCkanFiles
    }

    struct FakeCKANFile {
        let spec_version: Int = 1
    }

    /// Burp the current CKAN Files into a cache file
    func saveToCache() {
        // Not implemented
    }

    /// Unburp the contents of the cache file into the ckanFiles array
    func readRepositoryArchiveFromCache() -> Bool {
        // Not implemented
        return false
    }

}
