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

    init(inDirectory workingDirectory: URL, withDownloadURL downloadURL: URL) {
        self.workingDirectory = workingDirectory
        self.downloadURL = downloadURL
    }

    func downloadRepositoryArchive() {
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
                } catch (let writeError) {
                    print("error writing file \(localUrl) : \(writeError)")
                }

            } else {
                print("Failure: \(error?.localizedDescription ?? ":("))")
            }
        }
        task.resume()
    }

    func unpackRepositoryArchive(callback: () -> ()) {
        let sourceUrl = workingDirectory.appendingPathComponent(zipFileName)
        let destinationUrl = workingDirectory.appendingPathComponent("unzip")

        do {
            try fileManager.createDirectory(at: destinationUrl, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: sourceUrl, to: destinationUrl)
        } catch {
            print("Extraction of ZIP archive failed with error:\(error)")
        }
    }

    func readUnpackedRepositoryArchive() {

    }

    func readRepositoryArchiveFromCache() -> Bool {
        return false
    }

}

//extension CKANRepository: URLSessionDownloadDelegate {
//    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
//                    didFinishDownloadingTo location: URL) {
//        print("Finished downloading to \(location).")
//    }
//}

