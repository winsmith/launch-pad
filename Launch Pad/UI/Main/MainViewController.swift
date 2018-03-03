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

    override func viewDidAppear() {
        super.viewDidAppear()
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
