//
//  MainViewController.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 17.02.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import AppKit

class MainViewController: NSTabViewController {
    private let currentInstallationKey = "launchpadCurrentInstallation"

    lazy var ckanClient: CKANClient = {
        guard let appDelegate = NSApplication.shared.delegate as? AppDelegate else { fatalError("Could not get AppDelegate! I am confused!") }
        return appDelegate.ckanClient
    }()

    lazy var welcomeSheetViewController: WelcomeSheetViewController = {
        let welcomeSheetViewController = self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "WelcomeSheetViewController"))
            as! WelcomeSheetViewController
        welcomeSheetViewController.ckanClient = ckanClient
        welcomeSheetViewController.delegate = self
        return welcomeSheetViewController
    }()

    lazy var updateRepositoryViewController: UpdateRepositoryViewController = {
        let updateRepositoryViewController = self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "UpdateRepositoryViewController"))
            as! UpdateRepositoryViewController
        updateRepositoryViewController.delegate = self
        return updateRepositoryViewController
    }()

    override func viewDidAppear() {
        super.viewDidAppear()

        if let installationDict = UserDefaults.standard.value(forKey: currentInstallationKey) as? [String: String?],
            let kspInstallation = KSPInstallation.init(from: installationDict) {
            ckanClient.ckanKitSettings.currentInstallation = kspInstallation
        }

        if !ckanClient.isFullyInitialized {
            self.presentViewControllerAsSheet(welcomeSheetViewController)
        }
    }
}

extension MainViewController: WelcomeSheetViewControllerDelegate {
    func didFinishSelectingKSPDir(sender: WelcomeSheetViewController) {
        dismissViewController(sender)

        // Save Settings
        UserDefaults.standard.setValue(ckanClient.ckanKitSettings.currentInstallation?.toDictionary(), forKey:  currentInstallationKey)

        // Next Step
        updateRepositoryViewController.ckanClient = ckanClient
        self.presentViewControllerAsSheet(updateRepositoryViewController)
    }
}

extension MainViewController: UpdateRepositoryViewControllerDelegate {
    func didFinishUpdating(_ sender: UpdateRepositoryViewController) {
        dismissViewController(sender)
    }


}
