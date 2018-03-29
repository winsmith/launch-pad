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
            guard module != oldValue else { return }
            updateUI()
        }
    }
    public var kspInstallation: KSPInstallation?
    private var byteFormatter = ByteCountFormatter()
    private var installModuleCoordinator: InstallModuleCoordinator?

    // MARK: - Outlets
    @IBOutlet weak var installButton: NSButton!
    @IBOutlet weak var uninstallButton: NSButton!
    @IBOutlet weak var upgradeButton: NSButton!

    @IBOutlet weak var iconImageView: NSImageView!
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
    @IBOutlet weak var recommendationsLabel: NSTextField!
    @IBOutlet weak var supportLabel: NSTextField!
    @IBOutlet weak var debugLabel: NSTextField!
    @IBOutlet weak var debugContainer: NSView!

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

        if module.installedRelease == nil {
            installButton.isHidden = false
            uninstallButton.isHidden = true
            upgradeButton.isHidden = true
        } else if let installedRelease = module.installedRelease {
            installButton.isHidden = true

            if installedRelease == module.latestRelease {
                uninstallButton.isHidden = false
                upgradeButton.isHidden = true
            } else {
                uninstallButton.isHidden = true
                upgradeButton.isHidden = false
                upgradeButton.stringValue = "Upgrade from \(installedRelease.version ?? "0") to \(module.latestRelease.version ?? "0")"
            }
        }

        moduleNameLabel.stringValue = module.name
        moduleVersionLabel.stringValue = module.latestRelease.version?.description ?? ""
        authorsLabel.stringValue = module.latestRelease.authors?.joined(separator: ", ") ?? "–"

        minKSPVersionLabel.stringValue = module.latestRelease.kspVersionMin?.description ?? "–"
        maxKSPVersionLabel.stringValue = module.latestRelease.kspVersionMax?.description ?? "–"
        licenseLabel.stringValue = module.latestRelease.licenses?.joined(separator: ", ") ?? "–"

        if let abstract = module.latestRelease.abstract {
            abstractLabel.stringValue = abstract
            abstractLabel.isHidden = false
        } else {
            abstractLabel.isHidden = true
        }

        if let detailDescription = module.latestRelease.detailDescription {
            descriptionLabel.stringValue = detailDescription
            descriptionLabel.isHidden = false
        } else {
            descriptionLabel.isHidden = true
        }

        if Settings.shouldDisplayDebugInformation {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let debugData = try? jsonEncoder.encode(module.latestRelease.ckanFile)
            debugLabel.stringValue = debugData != nil ? String(data: debugData!, encoding: .utf8)! : ""
            debugContainer.isHidden = false
        } else {
            debugContainer.isHidden = true
        }

        if let downloadSizeBytes = module.latestRelease.downloadSize {
            downloadSizeLabel.stringValue = byteFormatter.string(fromByteCount: Int64(downloadSizeBytes))
        } else {
            downloadSizeLabel.stringValue = "o_o"
        }

        // Update Resources Buttons
        for button in resourcesButtons {
            button.isHidden = true
        }

        if let resources = module.latestRelease.resources {
            for (button, resourceKey) in zip(resourcesButtons, resources.keys.filter { $0 != "x_screenshot" }) {
                button.title = resourceKey.firstUppercased
                button.isHidden = false
            }
        }

        // Dependencies
        dependenciesLabel.stringValue = " - " + module.latestRelease.dependencies.map({ "\($0.name) \($0.version ?? "")" }).joined(separator: "\n - ")
        suggestionsLabel.stringValue = " - " + module.latestRelease.suggestions.map({ "\($0.name) \($0.version ?? "")" }).joined(separator: "\n - ")
        recommendationsLabel.stringValue = " - " + module.latestRelease.recommendations.map({ "\($0.name) \($0.version ?? "")" }).joined(separator: "\n - ")
        supportLabel.stringValue = " - " + module.latestRelease.supports.map({ "\($0.name) \($0.version ?? "")" }).joined(separator: "\n - ")

        // Screenshot
        if let resources = module.latestRelease.resources, let screenshot = resources["x_screenshot"], let screenshotURL = screenshot.urlValue() {

            iconImageView.image = NSImage(named: NSImage.Name(rawValue: "Box"))
            self.iconImageView.isHidden = false

            URLSession.shared.dataTask(with: screenshotURL) { data, response, error in
                guard error == nil, let data = data else { return }
                DispatchQueue.main.async {
                    self.iconImageView.image = NSImage(data: data)
                }
            }.resume()
        } else {
            iconImageView.image = NSImage(named: NSImage.Name(rawValue: "Box"))
            iconImageView.isHidden = true
        }
    }

    // MARK: - Actions
    @IBAction func install(_ sender: Any) {
        guard module?.installedRelease == nil else { return }
        guard let module = module, let kspInstallation = kspInstallation, let parent = parent else { return }
        installModuleCoordinator = InstallModuleCoordinator(module: module, kspInstallation: kspInstallation, parentViewController: parent)
        installModuleCoordinator!.delegate = self
        installModuleCoordinator!.begin()
    }

    @IBAction func uninstall(_ sender: Any) {
        module?.installedRelease?.uninstall()
        updateUI()
    }

    @IBAction func upgrade(_ sender: Any) {
    }

    // MARK: - Resources Buttons
    @IBAction func resourcesButton(_ sender: NSButton) {
        guard let resourceURLDict = module?.latestRelease.resources?[sender.title.lowercased()] else { return }
        guard let resourceURL = resourceURLDict.urlValue() else { return }
        NSWorkspace.shared.open(resourceURL)
    }
}

extension ModuleDetailViewController: InstallModuleCoordinatorDelegate {
    func didFinishInstallingModules(installModuleCoordinator: InstallModuleCoordinator) {
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
}
