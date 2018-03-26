//
//  String+Uppercased.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 11.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

extension String {
    var firstUppercased: String {
        guard let first = first else { return "" }
        return String(first).uppercased() + dropFirst()
    }

    var trimmed: String {
        return trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
}
