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

    override func viewDidAppear() {
        super.viewDidAppear()

        // Get KSP Installation from UserDefaults
        if let installationDict = UserDefaults.standard.value(forKey: currentInstallationKey) as? [String: String?],
            let kspInstallation = KSPInstallation.init(from: installationDict) {
            appDelegate.ckanClient = CKANClient(kspInstallation: kspInstallation)
        }

        // Nothing found in UserDefaults, ask the user for the KSP Directory
        if appDelegate.ckanClient == nil {
            self.presentViewControllerAsSheet(selectKSPDirViewController)
        }

        // Installation is there, but no Repository yet
        else if appDelegate.ckanClient?.isRepositoryInitialized != true {
            updateRepositoryViewController.ckanClient = appDelegate.ckanClient
            self.presentViewControllerAsSheet(updateRepositoryViewController)
        }
    }

    public func updateRepository() {
        updateRepositoryViewController.ckanClient = appDelegate.ckanClient
        self.presentViewControllerAsSheet(updateRepositoryViewController)
    }

    public func filterModules(by filterString: String) {
        let selectedTabViewItem = tabViewItems[selectedTabViewItemIndex]

        if let browseViewController = selectedTabViewItem.viewController as? BrowseViewController {
            browseViewController.filter = filterString
        }
    }
}

extension MainViewController: WelcomeSheetViewControllerDelegate {
    func didFinishSelectingKSPDir(sender: WelcomeSheetViewController, kspInstallation: KSPInstallation) {
        dismissViewController(sender)

        // Save Settings
        UserDefaults.standard.setValue(kspInstallation.toDictionary(), forKey:  currentInstallationKey)

        // Next Step
        appDelegate.ckanClient = CKANClient(kspInstallation: kspInstallation)

        // TODO: extract into function
        updateRepositoryViewController.ckanClient = appDelegate.ckanClient
        self.presentViewControllerAsSheet(updateRepositoryViewController)
    }
}

extension MainViewController: UpdateRepositoryViewControllerDelegate {
    func didFinishUpdating(_ sender: UpdateRepositoryViewController) {
        dismissViewController(sender)
    }


}
