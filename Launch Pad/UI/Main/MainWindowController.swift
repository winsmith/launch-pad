//
//  MainWindowController.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 26.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
    }

    @IBAction func updateRepository(_ sender: NSToolbarItem) {
        (contentViewController as? MainViewController)?.updateRepository()
    }

    @IBAction func filter(_ sender: NSSearchField) {
        let searchValue = sender.stringValue
        (contentViewController as? MainViewController)?.filterModules(by: searchValue)
    }
}
