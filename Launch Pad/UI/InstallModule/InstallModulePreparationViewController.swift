//
//  InstallModulePreparationViewController.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 26.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Cocoa

class InstallModulePreparationViewController: NSViewController {
    var releaseToInstall: Release?
    var kspInstallation: KSPInstallation?
    weak var delegate: InstallModulePreparationViewControllerDelegate?

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var dependencyListLabel: NSTextField!
    @IBOutlet weak var recommendationsListLabel: NSTextField!
    @IBOutlet weak var suggestionListLabel: NSTextField!
    @IBOutlet weak var installSuggestionsCheckBox: NSButton!
    @IBOutlet weak var installRecommendationsCheckBox: NSButton!
    @IBOutlet weak var beginInstallationButton: NSButton!

    private var releasesToInstall: [Release] {
        var releasesToInstall = [Release]()
        releasesToInstall += releaseToInstall!.dependencies
        releasesToInstall.append(releaseToInstall!)

        if installRecommendationsCheckBox.state == .on {
            releasesToInstall += releaseToInstall!.recommendations
        }

        if installSuggestionsCheckBox.state == .on {
            releasesToInstall += releaseToInstall!.suggestions
        }

        return releasesToInstall
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let release = releaseToInstall!

        titleLabel.stringValue = "Install \(release.name) \(release.version ?? "")"

        dependencyListLabel.stringValue = " - " + release.dependencies.map({ "\($0.name) \($0.version ?? "")" }).joined(separator: "\n - ")
        recommendationsListLabel.stringValue = " - " + release.recommendations.map({ "\($0.name) \($0.version ?? "")" }).joined(separator: "\n - ")
        suggestionListLabel.stringValue = " - " + release.suggestions.map({ "\($0.name) \($0.version ?? "")" }).joined(separator: "\n - ")

        updateUI()
    }

    func updateUI() {
        dependencyListLabel.backgroundColor = NSColor.color(named: .DrunkOnWhite)
        recommendationsListLabel.backgroundColor = installRecommendationsCheckBox.state == .on ? NSColor.color(named: .DrunkOnWhite) : NSColor.clear
        suggestionListLabel.backgroundColor = installSuggestionsCheckBox.state == .on ? NSColor.color(named: .DrunkOnWhite) : NSColor.clear

        beginInstallationButton.title = "Begin Installation of \(releasesToInstall.count) Modules"
    }

    // MARK: - Actions
    @IBAction func checkInstallRecommendations(_ sender: NSButton) { updateUI() }
    @IBAction func checkInstallSuggestions(_ sender: NSButton) { updateUI() }
    
    @IBAction func beginInstallation(_ sender: Any) {
        delegate?.userRequestedInstallation(releasesToInstall: releasesToInstall, self)
    }
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.userDidCancel(self)
    }
}

protocol InstallModulePreparationViewControllerDelegate: class {
    func userRequestedInstallation(releasesToInstall: [Release], _ installModulePreparationViewController: InstallModulePreparationViewController)
    func userDidCancel(_ installModulePreparationViewController: InstallModulePreparationViewController)
}
