//
//  File.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 13.02.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import AppKit
import Foundation

class CKANClient {
    private let pyKanAdapter: PyKanAdapter

    init(pyKanAdapter: PyKanAdapter) {
        self.pyKanAdapter = pyKanAdapter
    }

    private func pykan(_ arguments: [String]) -> String {
        return pyKanAdapter.pykan(arguments)
    }

    // MARK: - KSP Dirs
    public func listKSPDirs() -> [KSPDir] {
        let source = pykan(["listkspdirs"])
        let pattern = "\\d+: (.*)"
        guard let formatter = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }
        let range = NSRange(location: 0, length: source.utf16.count)
        let matches = formatter.matches(in: source, options: [], range: range)

        var kspDirs = [KSPDir]()
        for match in matches {
            let matchedRange = match.range(at: 1) // 0 seems to be the entire string, 1 the first capture group
            guard let range = Range(matchedRange, in: source) else { continue }
            let matchedSubString = source[range]
            kspDirs.append(KSPDir(path: String(matchedSubString)))
        }

        return kspDirs
    }

    public func currentKSPDir() -> KSPDir? {
        let source = pykan(["listkspdirs"])
        let pattern = "Using KSP Directory:  (.+)"
        guard let formatter = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        let range = NSRange(location: 0, length: source.utf16.count)
        let matches = formatter.matches(in: source, options: [], range: range)

        guard let match = matches.first else { return nil }
        let matchedNSRange = match.range(at: 1) // 0 seems to be the entire string, 1 the first capture group
        guard let matchedRange = Range(matchedNSRange, in: source) else { return nil }
        let matchedSubString = source[matchedRange]
        return KSPDir(path: String(matchedSubString))
    }


    // MARK: - Modules
    public func listModules() -> [String] {
        let output = pykan(["list_modules"])
        return [output]
    }
}
