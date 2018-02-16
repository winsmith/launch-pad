//
//  FakePyKanAdapter.swift
//  Launch PadTests
//
//  Created by Daniel Jilg on 15.02.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Foundation

class FakePyKanAdapter: PyKanAdapter {
    public var cannedResponse: String = ""

    override public func pykan(_ arguments: [String]) -> String {
        return cannedResponse
    }
}
