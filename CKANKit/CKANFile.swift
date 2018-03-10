//
//  CKANFile.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 05.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

struct CKANFile: Codable {
    
    /// Accepts both `["String", "String"]` and `"String"` as decodable input
    struct StringOrArray: Codable {
        let arrayValue: [String]
        var stringValue: String {
            return arrayValue.joined(separator: ", ")
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                arrayValue = try container.decode(Array.self)
            } catch DecodingError.typeMismatch {
                do {
                    arrayValue = try [container.decode(String.self)]
                } catch DecodingError.typeMismatch {
                    throw DecodingError.typeMismatch(StringOrArray.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Encoded payload not of an expected type"))
                }
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(arrayValue)
        }
    }

    struct Installation: Codable {
        // Source
        let file: String?
        let find: String?
        let find_regexp: String?

        // Destination
        let install_to: String

        // Directives
        let `as`: String?
        let filter: StringOrArray?
        let filter_regexp: StringOrArray?
        let include_only: StringOrArray?
        let include_only_regexp: StringOrArray?
        let find_matches_files: Bool?
    }

    struct Relationship: Codable {
        let name: String
        let min_version: String?
        let max_version: String?
        let version: String?
    }

    // This whole specialized struct extists so we can parse Kerbal Engineer Redux's resource section.
    // You are welcome, CYBUTEK :D~
    enum ResourceURL: Codable {
        case dictionary([String: String])
        case string(String)

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            do {
                self = try .dictionary(container.decode(Dictionary.self))
            } catch DecodingError.typeMismatch {
                do {
                    self = try .string(container.decode(String.self))
                } catch DecodingError.typeMismatch {
                    // Special case for ModuleRCSFX
                    self = .string("Could not decode JSON")
                }
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .dictionary(let dictionary):
                try container.encode(dictionary)
            case .string(let string):
                try container.encode(string)
            }
        }
    }

    // Spec Version
    let spec_version: Int = 1

    // Mandatory Fields
    let name: String
    let abstract: String
    let identifier: String
    let download: URL
    let license: StringOrArray
    let version: String

    // Optional Fields
    let install: [Installation]?
    let comment: String?
    let author: StringOrArray?
    let description: String?
    let release_status: String?
    let ksp_version: String?
    let ksp_version_min: String?
    let ksp_version_max: String?
    let ksp_version_strict: Bool? = false
    let tags: [String]?

    // Relationships
    let depends: [Relationship]?
    let recommends: [Relationship]?
    let suggests: [Relationship]?
    let supports: [Relationship]?
    let conflicts: [Relationship]?

    // Resources
    let resources: [String: ResourceURL]?

    // Special Use Fields
    let kind: String?
    let provides: [String]?
    let download_size: Int?
    let download_hash: [String: String]?
    let download_content_type: String?
}

// MARK: - Equatable
extension CKANFile: Equatable {
    static func ==(lhs: CKANFile, rhs: CKANFile) -> Bool {
        return lhs.identifier == rhs.identifier && lhs.version == rhs.version
    }


}
