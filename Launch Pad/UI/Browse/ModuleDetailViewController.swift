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
    private let byteFormatter = ByteCountFormatter()
    private var installModuleCoordinator: InstallModuleCoordinator?

    // MARK: - Outlets
    @IBOutlet weak var installButton: NSButton!
    @IBOutlet weak var uninstallButton: NSButton!
    @IBOutlet weak var upgradeButton: NSButton!

    @IBOutlet weak var iconImageView: NSImageView!
    @IBOutlet weak var moduleNameLabel: NSTextField!
    @IBOutlet weak var moduleVersionLabel: NSTextField!
    @IBOutlet weak var authorsLabel: NSTextField!
    @IBOutlet weak var incompatibilityWarningLabel: NSTextField!
    @IBOutlet weak var incompatibilityWarningLabelContainer: NSView!
    @IBOutlet weak var downloadSizeLabel: NSTextField!
    @IBOutlet weak var maxKSPVersionLabel: NSTextField!
    @IBOutlet weak var minKSPVersionLabel: NSTextField!
    @IBOutlet weak var licenseLabel: NSTextField!
    @IBOutlet weak var abstractLabel: NSTextField!
    @IBOutlet weak var descriptionLabel: NSTextField!
    @IBOutlet weak var relatedModulesTitleLabel: NSTextField!
    @IBOutlet weak var dependenciesStackView: NSStackView!
    @IBOutlet weak var dependenciesContainer: NSStackView!
    @IBOutlet weak var recommendationsStackView: NSStackView!
    @IBOutlet weak var recommendationsContainer: NSStackView!
    @IBOutlet weak var suggestionsStackView: NSStackView!
    @IBOutlet weak var suggestionsContainer: NSStackView!
    @IBOutlet weak var supportsStackView: NSStackView!
    @IBOutlet weak var supportsContainer: NSStackView!
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

    // MARK: - Setup
    override func viewWillAppear() {
        super.viewWillAppear()
        installButton.attributedTitle = attributedTitle("INSTALL", textColor: NSColor.white)
        uninstallButton.attributedTitle = attributedTitle("UNINSTALL", textColor: NSColor.white)
        upgradeButton.attributedTitle = attributedTitle("UPGRADE", textColor: NSColor.white)
    }

    func attributedTitle(_ title: String, textColor: NSColor) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center

        let attributes =
            [
                NSAttributedStringKey.foregroundColor: textColor,
                NSAttributedStringKey.font: NSFont.systemFont(ofSize: 13),
                NSAttributedStringKey.paragraphStyle: style
                ] as [NSAttributedStringKey : Any]

        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        return attributedTitle
    }
    
    // MARK: - Updating
    func updateUI() {
        guard let module = module else {
            installButton.isHidden = true
            uninstallButton.isHidden = true
            upgradeButton.isHidden = true
            return
        }

        let reasonsForIncompatibility = reasonsForInCompatibilityWithLaunchpad(module.latestRelease)
        incompatibilityWarningLabel.isHidden = reasonsForIncompatibility.isEmpty
        incompatibilityWarningLabel.stringValue = "Warning: This Release or one of its dependencies contains installation directives that are not yet supported by Launch Pad. The installation might fail silently. (The unsupported directives are: \(reasonsForIncompatibility.joined(separator: ", ")))"

        if !module.isInstalled {
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

        // Related Modules
        relatedModulesTitleLabel.isHidden = (
            module.latestRelease.dependencies.isEmpty &&
            module.latestRelease.recommendations.isEmpty &&
            module.latestRelease.suggestions.isEmpty &&
            module.latestRelease.supports.isEmpty
        )

        for arrangedSubview in dependenciesStackView.arrangedSubviews + recommendationsStackView.arrangedSubviews + suggestionsStackView.arrangedSubviews + supportsStackView.arrangedSubviews {
            arrangedSubview.removeFromSuperview()
        }

        dependenciesContainer.isHidden = module.latestRelease.dependencies.isEmpty
        for relationship in module.latestRelease.dependencies {
            let button = NSButton.init(title: relationship.name, target: self, action: #selector(openRelationship(_:)))
            button.font = NSFont.boldSystemFont(ofSize: NSFont.smallSystemFontSize)
            button.bezelStyle = .inline
            dependenciesStackView.addArrangedSubview(button)
        }

        recommendationsContainer.isHidden = module.latestRelease.recommendations.isEmpty
        for relationship in module.latestRelease.recommendations {
            let button = NSButton.init(title: relationship.name, target: self, action: #selector(openRelationship(_:)))
            button.font = NSFont.boldSystemFont(ofSize: NSFont.smallSystemFontSize)
            button.bezelStyle = .inline
            recommendationsStackView.addArrangedSubview(button)
        }

        suggestionsContainer.isHidden = module.latestRelease.suggestions.isEmpty
        for relationship in module.latestRelease.suggestions {
            let button = NSButton.init(title: relationship.name, target: self, action: #selector(openRelationship(_:)))
            button.font = NSFont.boldSystemFont(ofSize: NSFont.smallSystemFontSize)
            button.bezelStyle = .inline
            suggestionsStackView.addArrangedSubview(button)
        }

        supportsContainer.isHidden = module.latestRelease.supports.isEmpty
        for relationship in module.latestRelease.supports {
            let button = NSButton.init(title: relationship.name, target: self, action: #selector(openRelationship(_:)))
            button.font = NSFont.boldSystemFont(ofSize: NSFont.smallSystemFontSize)
            button.bezelStyle = .inline
            supportsStackView.addArrangedSubview(button)
        }

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

    /// Check if the release contains installation directives we don't support yet.
    private func isCompatibleWithLaunchPad(_ theRelease: Release) -> Bool {
        return reasonsForInCompatibilityWithLaunchpad(theRelease).isEmpty == true
    }

    private func reasonsForInCompatibilityWithLaunchpad(_ theRelease: Release) -> [String] {
        var reasons: [String] = []

        for releaseDependency in theRelease.dependencies {
            let subReasons = reasonsForInCompatibilityWithLaunchpad(releaseDependency)
            reasons += subReasons.filter { !reasons.contains($0) }
        }

        for installationDirective in theRelease.ckanFile.install ?? [] {
            var subReasons: [String] = []
            if installationDirective.as != nil { subReasons.append("as") }
            if installationDirective.filter_regexp != nil { subReasons.append("filter_regexp") }
            if installationDirective.include_only != nil { subReasons.append("include_only") }
            if installationDirective.include_only_regexp != nil { subReasons.append("include_only_regexp") }
            reasons += subReasons.filter { !reasons.contains($0) }
        }

        return reasons
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

    @objc func openRelationship(_ sender: NSButton) {
        let release = self.release(for: sender)
        if let moduleForRelease = release?.module {
            module = moduleForRelease
        }
    }

    func release(for button: NSButton) -> Release? {
        if dependenciesStackView.arrangedSubviews.contains(button) {
            let possibleReleases = module!.latestRelease.dependencies
            if let indexOfRelease = dependenciesStackView.arrangedSubviews.index(of: button) {
                return possibleReleases[indexOfRelease]
            }
        }

        else if recommendationsStackView.arrangedSubviews.contains(button) {
            let possibleReleases = module!.latestRelease.recommendations
            if let indexOfRelease = recommendationsStackView.arrangedSubviews.index(of: button) {
                return possibleReleases[indexOfRelease]
            }
        }

        else if suggestionsStackView.arrangedSubviews.contains(button) {
            let possibleReleases = module!.latestRelease.suggestions
            if let indexOfRelease = suggestionsStackView.arrangedSubviews.index(of: button) {
                return possibleReleases[indexOfRelease]
            }
        }

        else if supportsStackView.arrangedSubviews.contains(button) {
            let possibleReleases = module!.latestRelease.supports
            if let indexOfRelease = supportsStackView.arrangedSubviews.index(of: button) {
                return possibleReleases[indexOfRelease]
            }
        }

        return nil
    }
}

extension ModuleDetailViewController: InstallModuleCoordinatorDelegate {
    func didFinishInstallingModules(installModuleCoordinator: InstallModuleCoordinator) {
        DispatchQueue.main.async {
            self.updateUI()
        }
    }
}
