//
//  UpdateRepositoryViewController.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 07.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Cocoa

class UpdateRepositoryViewController: NSViewController {
    // MARK: - Properties
    public weak var delegate: UpdateRepositoryViewControllerDelegate?
    public var ckanClient: CKANClient?

    // MARK: Private Properties
    private var progress = Progress(totalUnitCount: 198)
    private var progressKeyValueObservation: NSKeyValueObservation?
    private var isWorking = false
    private var bleepBloopTimer: Timer?
    private var repository: CKANRepository? { return ckanClient?.ckanKitSettings.currentInstallation?.ckanRepository }

    // MARK: - Outlets
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var statusLabel: NSTextField!
    @IBOutlet weak var bleepBloopLabel: NSTextField!

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        progressKeyValueObservation = progress.observe(\.fractionCompleted) { [weak self] _, _ in
            self?.updateUI()
        }

        bleepBloopTimer = Timer.scheduledTimer(withTimeInterval: 0.9, repeats: true) { _ in
            if self.isWorking {
                if self.bleepBloopLabel.stringValue == "Beep" {
                    self.bleepBloopLabel.stringValue = "Boop"
                } else {
                    self.bleepBloopLabel.stringValue = "Beep"
                }
            }
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        updateRepository()
    }

    private func updateUI() {
        DispatchQueue.main.async {
            self.progressBar.doubleValue = self.progress.fractionCompleted * 100
        }
    }

    // MARK: - Actions
    func updateRepository() {
        isWorking = true
        statusLabel.stringValue = "Downloading File..."

        if repository?.repositoryZIPFileExists() == true {
            repository?.deleteZipFile()
        }

        let downloadProgress = repository!.downloadRepositoryArchive() {
            self.processDownloadedFile()
        }
        progress.addChild(downloadProgress, withPendingUnitCount: 66)
    }

    private func updateStatusLabel(_ newStatus: String) {
        DispatchQueue.main.async {
            self.statusLabel.stringValue = newStatus
        }
    }

    private func updateBleepBloopLabel(_ newStatus: String) {
        DispatchQueue.main.async {
            self.bleepBloopLabel.stringValue = newStatus
        }
    }

    // MARK: - Repository Handling
    private func processDownloadedFile() {
        // unpack
        // https://developer.apple.com/documentation/foundation/progress
        updateStatusLabel("Unpacking File...")
        let unpackingProgress = Progress()
        progress.addChild(unpackingProgress, withPendingUnitCount: 66)
        let success = repository!.unpackRepositoryArchive(progress: unpackingProgress)
        if success == false {

        }

        // repository!.deleteZipFile()

        // parse
        updateStatusLabel("Parsing unpacked Repository...")
        let parsingProgress = Progress()
        progress.addChild(parsingProgress, withPendingUnitCount: 66)
        repository!.readUnpackedRepositoryArchive(progress: parsingProgress)
        repository!.deleteUnzippedDirectory()

        // save to cache
        // repository.saveToCache()

        if let modCount = repository?.ckanFiles?.count {
            updateStatusLabel("Done. \(modCount) files decoded.")
        } else {
            updateStatusLabel("Done, but something is fishy")
        }

        DispatchQueue.main.async {
            self.isWorking = false
            self.delegate?.didFinishUpdating(self)
        }
    }
}

protocol UpdateRepositoryViewControllerDelegate: class {
    func didFinishUpdating(_ sender: UpdateRepositoryViewController)
}
