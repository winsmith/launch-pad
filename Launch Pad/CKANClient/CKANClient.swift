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

    // MARK: - Ready
    public func isFullyInitialized() -> Bool {
        return self.currentKSPDir() != nil 
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

    public func addKSPDir(url: URL) -> Bool {
        let source = pykan(["addkspdir", url.path])
        return source.starts(with: "Using KSP Directory")
    }


    // MARK: - Modules
    public func listModules(filter: String? = nil) -> [Module] {
        let source = pykan(["list_modules"])
        let pattern = "(\\w+) :  (.+) \\| (.+) \\((.*)\\)"
        guard let formatter = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }
        let range = NSRange(location: 0, length: source.utf16.count)
        let matches = formatter.matches(in: source, options: [], range: range)

        var modules = [Module]()

        enum ModuleMatchedRange: Int {
            case key = 1
            case title = 2
            case version = 3
            case installed = 4
        }

        for match in matches {
            guard let keyRange = Range(match.range(at: 1), in: source) else { continue }
            let keyMatch = String(source[keyRange])

            guard let titleRange = Range(match.range(at: 2), in: source) else { continue }
            let titleMatch = String(source[titleRange])

            guard let versionRange = Range(match.range(at: 3), in: source) else { continue }
            let versionMatch = String(source[versionRange])

            guard let installedRange = Range(match.range(at: 4), in: source) else { continue }
            let installedMatch = String(source[installedRange])

            let isInstalled = installedMatch != "Not Installed"
            let module = Module(key: keyMatch, name: titleMatch, version: versionMatch, installed: isInstalled)
            modules.append(module)
        }

        return modules
    }
}
