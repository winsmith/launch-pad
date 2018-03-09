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
    private var byteFormatter = ByteCountFormatter()

    // MARK: - Outlets
    @IBOutlet weak var installButton: NSButton!
    @IBOutlet weak var uninstallButton: NSButton!
    @IBOutlet weak var upgradeButton: NSButton!

    @IBOutlet weak var moduleNameLabel: NSTextField!
    @IBOutlet weak var moduleVersionLabel: NSTextField!
    @IBOutlet weak var moduleVersionLabel2: NSTextField!
    @IBOutlet weak var authorsLabel: NSTextField!
    @IBOutlet weak var downloadSizeLabel: NSTextField!
    @IBOutlet weak var minKSPVersionLabel: NSTextField!
    @IBOutlet weak var licenseLabel: NSTextField!
    @IBOutlet weak var abstractLabel: NSTextField!
    @IBOutlet weak var descriptionLabel: NSTextField!

    // MARK: - Updating
    func updateUI() {
        guard let module = module else {
            installButton.isHidden = true
            uninstallButton.isHidden = true
            upgradeButton.isHidden = true
            return
        }

        installButton.isHidden = module.isInstalled
        uninstallButton.isHidden = !module.isInstalled
        upgradeButton.isHidden = !module.isInstalled

        moduleNameLabel.stringValue = module.name
        moduleVersionLabel.stringValue = module.version?.description ?? ""
        moduleVersionLabel2.stringValue = module.version?.description ?? ""
        authorsLabel.stringValue = module.authors?.joined(separator: ", ") ?? "–"

        minKSPVersionLabel.stringValue = module.kspVersionMin?.description ?? "–"
        licenseLabel.stringValue = module.licenses?.joined(separator: ", ") ?? "–"
        abstractLabel.stringValue = module.abstract ?? ""
        descriptionLabel.stringValue = module.description ?? ""

        if let downloadSizeBytes = module.downloadSize {
            downloadSizeLabel.stringValue = byteFormatter.string(fromByteCount: Int64(downloadSizeBytes))
        } else {
            downloadSizeLabel.stringValue = "o_o"
        }
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
