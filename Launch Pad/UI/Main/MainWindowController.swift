//
//  MainWindowController.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 26.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {
    @IBOutlet weak var searchBar: NSToolbar!

    private var mainViewController: NSViewController?
    
    override func windowDidLoad() {
        super.windowDidLoad()
    }

    @IBAction func updateRepository(_ sender: NSToolbarItem) {
        (contentViewController as? MainViewController)?.updateRepository()
    }
}
