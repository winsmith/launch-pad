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

    public func pykan(_ arguments: [String], inputString: String?) -> String {
        let process = newPyKanProcess()
        let outputPipe = Pipe()
        let inputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardInput = inputPipe
        process.arguments = arguments

        do {
            if let inputString = inputString {
                let inputData = inputString.data(using: .utf8)!
                inputPipe.fileHandleForWriting.write(inputData)
            }

            try process.run()
        } catch {
            debugPrint("Process crashed")
        }

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let returnString = String(data: data, encoding: .utf8)!
        debugPrint(returnString)
        return returnString
    }
}
