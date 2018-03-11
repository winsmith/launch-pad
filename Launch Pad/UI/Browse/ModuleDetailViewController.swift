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
    @IBOutlet weak var authorsLabel: NSTextField!
    @IBOutlet weak var downloadSizeLabel: NSTextField!
    @IBOutlet weak var maxKSPVersionLabel: NSTextField!
    @IBOutlet weak var minKSPVersionLabel: NSTextField!
    @IBOutlet weak var licenseLabel: NSTextField!
    @IBOutlet weak var abstractLabel: NSTextField!
    @IBOutlet weak var descriptionLabel: NSTextField!
    @IBOutlet weak var dependenciesLabel: NSTextField!
    @IBOutlet weak var suggestionsLabel: NSTextField!

    // Resources
    @IBOutlet weak var resourcesStackView: NSStackView!
    @IBOutlet weak var resourcesButton1: NSButton!
    @IBOutlet weak var resourcesButton2: NSButton!
    @IBOutlet weak var resourcesButton3: NSButton!
    @IBOutlet weak var resourcesButton4: NSButton!
    @IBOutlet weak var resourcesButton5: NSButton!
    @IBOutlet weak var resourcesBUtton6: NSButton!
    @IBOutlet weak var resourcesButton7: NSButton!
    @IBOutlet weak var resourcesButton8: NSButton!
    lazy var resourcesButtons: [NSButton] = { return [resourcesButton1, resourcesButton2, resourcesButton3, resourcesButton4,
                                                      resourcesButton5, resourcesBUtton6, resourcesButton7, resourcesButton8] }()

    
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
        authorsLabel.stringValue = module.authors?.joined(separator: ", ") ?? "–"

        minKSPVersionLabel.stringValue = module.kspVersionMin?.description ?? "–"
        maxKSPVersionLabel.stringValue = module.kspVersionMax?.description ?? "–"
        licenseLabel.stringValue = module.licenses?.joined(separator: ", ") ?? "–"
        abstractLabel.stringValue = module.abstract ?? ""
        descriptionLabel.stringValue = module.description ?? ""

        if let downloadSizeBytes = module.downloadSize {
            downloadSizeLabel.stringValue = byteFormatter.string(fromByteCount: Int64(downloadSizeBytes))
        } else {
            downloadSizeLabel.stringValue = "o_o"
        }

        // Update Resources Buttons
        for button in resourcesButtons {
            button.isHidden = true
        }

        if let resources = module.resources {
            for (button, resourceKey) in zip(resourcesButtons, resources.keys) {
                button.title = resourceKey.firstUppercased
                button.isHidden = false
            }
        }

        // Dependencies
        dependenciesLabel.stringValue = module.dependencies?.map({ $0.name }).joined(separator: ", ") ?? "–"
        suggestionsLabel.stringValue = module.suggestions?.map({ $0.name }).joined(separator: ", ")  ?? "–"
    }

    // MARK: - Actions
    @IBAction func install(_ sender: Any) {
        guard module?.isInstalled == false else { return }
        guard module?.dependencies?.isEmpty != false else { fatalError("Cannot yet install modules with dependencies")}

        let installModuleViewController = self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "InstallModuleViewController"))
            as! InstallModuleViewController
        installModuleViewController.delegate = self
        installModuleViewController.modulesToInstall = [module!]

        self.presentViewControllerAsSheet(installModuleViewController)
    }

    @IBAction func uninstall(_ sender: Any) {
    }

    @IBAction func upgrade(_ sender: Any) {
    }

    // MARK: - Resources Buttons
    @IBAction func resourcesButton(_ sender: NSButton) {
        guard let resourceURLDict = module?.resources?[sender.title.lowercased()] else { return }
        switch resourceURLDict {
        case .dictionary(let value):
            guard let firstKey = value.keys.first else { return }
            guard let urlString = value[firstKey] else { return }
            guard let resourceURL = URL(string: urlString) else { return }
            NSWorkspace.shared.open(resourceURL)

        case .string(let value):
            guard let resourceURL = URL(string: value) else { return }
            NSWorkspace.shared.open(resourceURL)
        }
    }
}

extension ModuleDetailViewController: InstallModuleViewControllerDelegate {
    func didFinishInstallingModules(installModuleViewController: InstallModuleViewController) {
        fatalError("Need to reload")
    }
}
