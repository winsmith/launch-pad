//
//  Logger.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 25.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation
import os

/// https://developer.apple.com/documentation/os/logging
class Logger {
    let logObject: OSLog

    init(category: String, subsystem: String) {
        let subsystemPrefix = "org.breakthesystem.LaunchPad."
        let subsystem = subsystemPrefix + subsystem
        logObject = OSLog(subsystem: subsystem, category: category)
    }

    func log(_ message: StaticString, _ messageContent: String? = nil, type: OSLogType = OSLogType.default) {
        if let messageContent = messageContent {
            os_log(message, log: logObject, type: type, messageContent)
        } else {
            os_log(message, log: logObject, type: type)
        }
    }
}
