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
    public var module: Module? {
        didSet {
            updateUI()
        }
    }

    // MARK: - Outlets
    @IBOutlet weak var moduleNameLabel: NSTextField!
    @IBOutlet weak var moduleVersionLabel: NSTextField!

    // MARK: - Updating
    func updateUI() {
        guard let module = module else {
            moduleNameLabel.isHidden = true
            moduleVersionLabel.isHidden = true
            return
        }


        moduleNameLabel.isHidden = false
        moduleVersionLabel.isHidden = false
        moduleNameLabel.stringValue = module.name
        moduleVersionLabel.stringValue = module.version
    }
}
