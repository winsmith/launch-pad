//
//  SettingsViewController.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 25.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    @IBOutlet weak var showDebugInformationCheckbox: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        showDebugInformationCheckbox.state = Settings.shouldDisplayDebugInformation ? .on : .off
    }

    @IBAction func toggleShowDebugInformation(_ sender: NSButton) {
        Settings.shouldDisplayDebugInformation = sender.state == .on
    }
}
