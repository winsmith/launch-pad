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
    @IBOutlet weak var suggestionListLabel: NSTextField!
    @IBOutlet weak var installSuggestionsCheckBox: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let release = releaseToInstall {
            titleLabel.stringValue = "Install \(release.name) \(release.version ?? "")"
            dependencyListLabel.stringValue = release.dependencies.map({ $0.name }).joined(separator: ", ") 
            suggestionListLabel.stringValue = release.suggestions.map({ $0.name }).joined(separator: ", ")  
        }
    }
    
    @IBAction func beginInstallation(_ sender: Any) {
        delegate?.userRequestedInstallation(includingSuggestions: installSuggestionsCheckBox.state == .on, self)
    }
    
    @IBAction func cancel(_ sender: Any) {
        delegate?.userDidCancel(self)
    }
}

protocol InstallModulePreparationViewControllerDelegate: class {
    func userRequestedInstallation(includingSuggestions: Bool, _ installModulePreparationViewController: InstallModulePreparationViewController)
    func userDidCancel(_ installModulePreparationViewController: InstallModulePreparationViewController)
}
