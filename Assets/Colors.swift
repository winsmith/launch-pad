//
//  Colors.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 21.02.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import AppKit
import Foundation

enum Color: String {
    case AlmostBlack = "AlmostBlack"
    case BackgroundColor = "BackgroundColor"
    case DarkGray = "DarkGray"
    case DarkAccent = "DarkAccent"
    case LightGray = "LightGray"
    case MediumGray = "MediumGray"
}

extension NSColor {
    static func color(named color: Color) -> NSColor {
        guard let theColor = NSColor(named: NSColor.Name(rawValue: color.rawValue)) else { return NSColor.systemBlue }
        return theColor
    }
}
