//
//  ReleaseMetaData.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 26.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

class ModuleMetadataManager {
    // MARK: - Internal Struct Type
    struct ModuleMetadata: Codable {
        let installedVersion: String
        let installedFiles: [String]
    }

    // MARK: - Properties
    public private(set) var moduleMetadata = [String: ModuleMetadata]()

    // MARK: - Private Properties]
    private let logger = Logger(category: "ModuleMetadataManager", subsystem: "CKANKit")
    private let workingDirectory: URL
    private let cacheFileName = "ckan_metadata_cache.json"
    private var cacheFileURL: URL { return workingDirectory.appendingPathComponent(cacheFileName) }
    private let jsonDecoder = JSONDecoder()
    private let jsonEncoder = JSONEncoder()


    // MARK: - Initialization
    init(inDirectory workingDirectory: URL) {
        self.workingDirectory = workingDirectory
        self.retrieveFromCache()
    }

    // MARK: - Getting and Setting Metadatra
    func metadata(for module: Module) -> ModuleMetadata? {
        return moduleMetadata[module.identifier]
    }

    func saveMetadata(for module: Module, _ metadata: ModuleMetadata) {
        moduleMetadata[module.identifier] = metadata
        saveToCache()
    }

    // MARK: - Saving and Retrieving from Cache
    func saveToCache() {
        do {
            let data = try jsonEncoder.encode(moduleMetadata)
            try data.write(to: cacheFileURL)
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func retrieveFromCache() {
        do {
            let cacheData = try Data(contentsOf: cacheFileURL)
            let metadata = try jsonDecoder.decode([String: ModuleMetadata].self, from: cacheData)
            moduleMetadata = metadata
        } catch {
            logger.log("Could not retrieve Metadata from cache: %@", error.localizedDescription)
        }
    }
}
