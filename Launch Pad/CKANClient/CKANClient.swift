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
    let execURL = Bundle.main.resourceURL?.appendingPathComponent("pyKAN")

    init() {
    }

    func newPyKanProcess() -> Process {
        let process = Process()
        process.executableURL = execURL
        return process
    }

    func listModules() -> [String] {
        let process = newPyKanProcess()
        process.arguments = ["list_modules"]//  ["addkspdir", "/Applications/Kerbal Space Program"]
        let pipe = Pipe()
        process.standardOutput = pipe

        do {
            try process.run()
        } catch {
            debugPrint("Process crashed")
        }

        // Get the data
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        return [output]
    }
}
