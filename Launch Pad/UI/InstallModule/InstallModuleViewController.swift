//
//  InstallModuleViewController.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 11.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Cocoa

class InstallModuleViewController: NSViewController {
    // MARK: - Properties
    public weak var delegate: InstallModuleViewControllerDelegate?
    public var releasesToInstall: [Release]?
    public var kspInstallation: KSPInstallation?
    private var remainingReleasesToInstall: [Release]?

    // MARK: Private Properties
    private var progress = Progress(totalUnitCount: 1)
    private var progressKeyValueObservation: NSKeyValueObservation?
    private var isWorking = false
    private var bleepBloopTimer: Timer?

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var beepBoopLabel: NSTextField!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if let firstModule = remainingReleasesToInstall?.first {
            titleLabel.stringValue = "Installing \(firstModule.name)"
        }

        progressKeyValueObservation = progress.observe(\.fractionCompleted) { [weak self] _, _ in
            self?.updateUI()
        }

        bleepBloopTimer = Timer.scheduledTimer(withTimeInterval: 0.9, repeats: true) { _ in
            if self.isWorking {
                if self.beepBoopLabel.stringValue == "Beep" {
                    self.beepBoopLabel.stringValue = "booP"
                } else {
                    self.beepBoopLabel.stringValue = "Beep"
                }
            }
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        progress.totalUnitCount = Int64(releasesToInstall!.count)

        if kspInstallation == nil {
            fatalError("KSP Installation not set")
        }

        installModules()
    }

    private func updateUI() {
        DispatchQueue.main.async {
            self.progressBar.doubleValue = self.progress.fractionCompleted * 100
            self.statusLabel.stringValue = "Doing Things ..."

            if let firstModule = self.remainingReleasesToInstall?.first {
                self.titleLabel.stringValue = "Installing \(firstModule.name)"
            }
        }
    }

    private func installModules() {
        isWorking = true
        remainingReleasesToInstall = releasesToInstall
        installFirstRemainingRelease()
    }

    private func installFirstRemainingRelease() {
        let release = remainingReleasesToInstall!.first!
        let releaseProgress = Progress(totalUnitCount: 5)
        self.progress.addChild(releaseProgress, withPendingUnitCount: 1)
        release.install(to: kspInstallation!, progress: releaseProgress) {
            self.remainingReleasesToInstall!.remove(at: self.remainingReleasesToInstall!.index(of:release)!)
            if self.remainingReleasesToInstall!.isEmpty {
                self.isWorking = false
                DispatchQueue.main.async {
                    self.delegate?.didFinishInstallingModules(installModuleViewController: self)
                }
            } else {
                self.installFirstRemainingRelease()
            }
        }
    }
}

protocol InstallModuleViewControllerDelegate: class {
    func didFinishInstallingModules(installModuleViewController: InstallModuleViewController)
}
