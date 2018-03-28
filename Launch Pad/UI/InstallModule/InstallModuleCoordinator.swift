//
//  InstallModuleCoordinator.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 26.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import AppKit
import Foundation

class InstallModuleCoordinator {
    let module: Module
    let kspInstallation: KSPInstallation
    let parentViewController: NSViewController

    public weak var delegate: InstallModuleCoordinatorDelegate?

    private let installModulePreparationViewController: InstallModulePreparationViewController
    private let installModuleViewController: InstallModuleViewController

    init(module: Module, kspInstallation: KSPInstallation, parentViewController: NSViewController) {
        self.module = module
        self.kspInstallation = kspInstallation
        self.parentViewController = parentViewController

        let storyboard = parentViewController.storyboard!
        self.installModulePreparationViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "InstallModulePreparationViewController"))
            as! InstallModulePreparationViewController
        self.installModuleViewController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "InstallModuleViewController"))
            as! InstallModuleViewController
    }

    public func begin() {
        showInstallModulePreparationViewController()
    }

    // MARK: - Show View Controllers
    private func showInstallModulePreparationViewController() {
        installModulePreparationViewController.delegate = self
        installModulePreparationViewController.releaseToInstall = module.latestRelease
        installModulePreparationViewController.kspInstallation = kspInstallation
        parentViewController.presentViewControllerAsSheet(installModulePreparationViewController)
    }

    private func showInstallModuleViewController(releases: [Release]) {
        installModuleViewController.delegate = self
        installModuleViewController.releasesToInstall = releases
        installModuleViewController.kspInstallation = kspInstallation
        parentViewController.presentViewControllerAsSheet(installModuleViewController)
    }
}

extension InstallModuleCoordinator: InstallModuleViewControllerDelegate {
    func didFinishInstallingModules(installModuleViewController: InstallModuleViewController) {

    }
}

extension InstallModuleCoordinator: InstallModulePreparationViewControllerDelegate {
    func userRequestedInstallation(releasesToInstall: [Release], _ installModulePreparationViewController: InstallModulePreparationViewController) {
        installModulePreparationViewController.dismiss(self)
        showInstallModuleViewController(releases: releasesToInstall)
    }

    func userDidCancel(_ installModulePreparationViewController: InstallModulePreparationViewController) {
        installModulePreparationViewController.dismiss(self)
    }


}

protocol InstallModuleCoordinatorDelegate: class {
    func didFinishInstallingModules(installModuleCoordinator: InstallModuleCoordinator)
}
