//
//  PyKanAdapter.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 15.02.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

class PyKanAdapter {
    private let execURL = Bundle.main.resourceURL?.appendingPathComponent("pyKAN")

    private func newPyKanProcess() -> Process {
        let process = Process()
        process.executableURL = execURL
        return process
    }

    public func pykan(_ arguments: [String]) -> String {
        let process = newPyKanProcess()
        let pipe = Pipe()
        process.standardOutput = pipe
        process.arguments = arguments

        do {
            try process.run()
        } catch {
            debugPrint("Process crashed")
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)!
    }
}
