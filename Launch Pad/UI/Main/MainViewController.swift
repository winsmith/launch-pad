//
//  MainViewController.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 17.02.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import AppKit

class MainViewController: NSTabViewController {
    // let ckanClient = CKANClient(pyKanAdapter: PyKanAdapter())

    lazy var welcomeSheetViewController: WelcomeSheetViewController = {
        let welcomeSheetViewController = self.storyboard!.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "WelcomeSheetViewController"))
            as! WelcomeSheetViewController
//        welcomeSheetViewController.ckanClient = ckanClient
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
        presentViewControllerAsSheet(updateRepositoryViewController)
//        if !ckanClient.isFullyInitialized() {
//            self.presentViewControllerAsSheet(welcomeSheetViewController)
//        }
    }
}

extension MainViewController: WelcomeSheetViewControllerDelegate {
    func didFinishSelectingKSPDir(sender: WelcomeSheetViewController) {
        dismissViewController(sender)
    }
}

extension MainViewController: UpdateRepositoryViewControllerDelegate {
    func didDismiss(sender: WelcomeSheetViewController) {
        dismissViewController(sender)
    }


}
