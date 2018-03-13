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
    public var modulesToInstall: [CKANModule]?
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

        if let firstModule = modulesToInstall?.first {
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
        }
    }

    private func installModules() {
        isWorking = true

        for module in modulesToInstall ?? [] {
            install(module)
        }

        isWorking = false
        delegate?.didFinishInstallingModules(installModuleViewController: self)
    }

    private func install(_ module: CKANModule) {
        let filename = module.downloadURL.lastPathComponent
        statusLabel.stringValue = "Downloading \(filename) ..."

        // TODO: Progress
        module.install(to: kspInstallation!, progress: nil, callback: {})
    }
}

protocol InstallModuleViewControllerDelegate: class {
    func didFinishInstallingModules(installModuleViewController: InstallModuleViewController)
}
