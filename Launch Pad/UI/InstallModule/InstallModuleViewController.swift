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

    // MARK: Private Properties
    private var progress = Progress(totalUnitCount: 5)
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

        if let firstModule = releasesToInstall?.first {
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

        if kspInstallation == nil {
            fatalError("KSP Installation not set")
        }

        installModules()
    }

    private func updateUI() {
        DispatchQueue.main.async {
            self.progressBar.doubleValue = self.progress.fractionCompleted * 100

            if self.progress.completedUnitCount < 2 {
                self.statusLabel.stringValue = "Downloading..."
            } else if self.progress.completedUnitCount < 4 {
                self.statusLabel.stringValue = "Unpacking..."
            } else {
                self.statusLabel.stringValue = "Installing..."
            }
        }
    }

    private func installModules() {
        isWorking = true

        for module in releasesToInstall ?? [] {
            install(module)
        }
    }

    private func install(_ release: Release) {
        release.install(to: kspInstallation!, progress: progress) {
            guard self.releasesToInstall != nil else { return }
            self.releasesToInstall!.remove(at: self.releasesToInstall!.index(of:release)!)
            if self.releasesToInstall!.isEmpty {
                self.isWorking = false
                self.delegate?.didFinishInstallingModules(installModuleViewController: self)
            }
        }
    }
}

protocol InstallModuleViewControllerDelegate: class {
    func didFinishInstallingModules(installModuleViewController: InstallModuleViewController)
}
