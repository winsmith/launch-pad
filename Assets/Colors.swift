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
    case AngryMushroom = "AngryMushroom"
    case BackgroundColor = "BackgroundColor"
    case DarkAccent = "DarkAccent"
    case DarkGray = "DarkGray"
    case DrunkOnWhite = "DrunkOnWhite"
    case FightToothpast = "FightToothpast"
    case LightAccent = "LightAccent"
    case WarningLabel = "WarningLabel"
}

extension NSColor {
    static func color(named color: Color) -> NSColor {
        guard let theColor = NSColor(named: NSColor.Name(rawValue: color.rawValue)) else { return NSColor.systemBlue }
        return theColor
    }
}
