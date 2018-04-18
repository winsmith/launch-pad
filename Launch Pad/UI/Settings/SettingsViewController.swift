//
//  SettingsViewController.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 25.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController {
    private let currentInstallationKey = "launchpadCurrentInstallation"
    var appDelegate: AppDelegate { return NSApplication.shared.delegate as! AppDelegate }

    lazy var selectKSPDirViewController: WelcomeSheetViewController = {
        let welcomeSheetViewController = self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "WelcomeSheetViewController"))
            as! WelcomeSheetViewController
        welcomeSheetViewController.delegate = self
        return welcomeSheetViewController
    }()

    lazy var updateRepositoryViewController: UpdateRepositoryViewController = {
        let updateRepositoryViewController = self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "UpdateRepositoryViewController"))
            as! UpdateRepositoryViewController
        updateRepositoryViewController.delegate = self
        return updateRepositoryViewController
    }()

    @IBOutlet weak var showDebugInformationCheckbox: NSButton!
    @IBOutlet weak var kspDirectoryLabel: NSTextField!

    override func viewWillAppear() {
        super.viewWillAppear()
        updateUI()
    }

    func updateUI() {
        showDebugInformationCheckbox.state = Settings.shouldDisplayDebugInformation ? .on : .off
        kspDirectoryLabel.stringValue = appDelegate.ckanClient?.kspInstallation.kspDirectory.path ?? "(not set)"
    }

    @IBAction func toggleShowDebugInformation(_ sender: NSButton) {
        Settings.shouldDisplayDebugInformation = sender.state == .on
    }
    
    @IBAction func changeKSPDirectory(_ sender: NSButton) {
        self.presentViewControllerAsSheet(selectKSPDirViewController)
    }

    @IBAction func updateCKANMetadata(_ sender: NSButton) {
        updateRepositoryViewController.ckanClient = appDelegate.ckanClient
        self.presentViewControllerAsSheet(updateRepositoryViewController)
    }
}

extension SettingsViewController: WelcomeSheetViewControllerDelegate {
    func didFinishSelectingKSPDir(sender: WelcomeSheetViewController, kspInstallation: KSPInstallation) {
        dismissViewController(sender)

        // Save Settings
        UserDefaults.standard.setValue(kspInstallation.toDictionary(), forKey:  currentInstallationKey)

        // Next Step
        appDelegate.ckanClient = CKANClient(kspInstallation: kspInstallation)
        updateRepositoryViewController.ckanClient = appDelegate.ckanClient
        self.presentViewControllerAsSheet(updateRepositoryViewController)
    }
}

extension SettingsViewController: UpdateRepositoryViewControllerDelegate {
    func didFinishUpdating(_ sender: UpdateRepositoryViewController) {
        dismissViewController(sender)
        updateUI()
    }
}
