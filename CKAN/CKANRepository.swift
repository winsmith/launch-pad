//
//  CKANRepository.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 03.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation
import ZIPFoundation

class CKANRepository {
    let workingDirectory: URL
    let downloadURL: URL

    private let fileManager = FileManager.default
    private let zipFileName = "ckan_meta.zip"
    private let decoder = JSONDecoder()

    init(inDirectory workingDirectory: URL, withDownloadURL downloadURL: URL) {
        self.workingDirectory = workingDirectory
        self.downloadURL = downloadURL
    }

    func downloadRepositoryArchive(callback: @escaping (_ localArchiveURL: URL) -> ()) {
        let localUrl = workingDirectory.appendingPathComponent(zipFileName)

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

    func unpackRepositoryArchive(callback: (_ unzippedURL: URL) -> ()) {
        let sourceUrl = workingDirectory.appendingPathComponent(zipFileName)
        let destinationUrl = workingDirectory

        do {
            try fileManager.unzipItem(at: sourceUrl, to: destinationUrl)
            callback(destinationUrl)
        } catch {
            print("Extraction of ZIP archive failed with error:\(error)")
        }
    }

    func readUnpackedRepositoryArchive(rootDirectoryURL: URL) {
        let enumerator = fileManager.enumerator(at: rootDirectoryURL, includingPropertiesForKeys: [], options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
            print("directoryEnumerator error at \(url): ", error)
            return true
        })!

        for case let fileURL as URL in enumerator {
            if fileURL.pathExtension == "ckan" {
                print("Decoding", fileURL.path)
                do {
                    let fileData = try Data(contentsOf: fileURL)
                    let ckanFile = try decoder.decode(CKANFile.self, from: fileData)
                } catch let error {
                    print(error)
                    fatalError()
                }

            }
        }
    }

    func readRepositoryArchiveFromCache() -> Bool {
        return false
    }

}
