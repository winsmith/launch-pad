//
//  ModuleDetailViewController.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 03.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Cocoa

class ModuleDetailViewController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Properties
    public var module: CKANModule? {
        didSet {
            updateUI()
        }
    }

    // MARK: - Outlets
    @IBOutlet weak var moduleNameLabel: NSTextField!
    @IBOutlet weak var moduleVersionLabel: NSTextField!
    @IBOutlet weak var installButton: NSButton!
    @IBOutlet weak var uninstallButton: NSButton!
    @IBOutlet weak var upgradeButton: NSButton!

    // MARK: - Updating
    func updateUI() {
        guard let module = module else {
            moduleNameLabel.isHidden = true
            moduleVersionLabel.isHidden = true
            installButton.isHidden = true
            uninstallButton.isHidden = true
            upgradeButton.isHidden = true
            return
        }

        moduleNameLabel.isHidden = false
        moduleVersionLabel.isHidden = false
        moduleNameLabel.stringValue = module.name
        moduleVersionLabel.stringValue = module.version?.description ?? ""

        installButton.isHidden = module.isInstalled
        uninstallButton.isHidden = !module.isInstalled
        upgradeButton.isHidden = !module.isInstalled
    }

    // MARK: - Actions
    @IBAction func install(_ sender: Any) {
        guard module?.isInstalled == false else { return }

        
    }

    @IBAction func uninstall(_ sender: Any) {
    }

    @IBAction func upgrade(_ sender: Any) {
    }
}
