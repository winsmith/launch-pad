//
//  CopyOperation.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 18.04.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

/// Encapsulates the copying of files from the unpacked mod archive to the KSP Directory.
struct CopyOperation {
    let source: URL
    let destination: URL

    var description: String {
        return "\(source.path) -> \(destination.path)"
    }

    // todo: "perform" function
}
