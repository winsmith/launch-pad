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

    // MARK: Private Properties
    private var repository: CKANRepository?
    private var progress = Progress()
    private var progressKeyValueObservation: NSKeyValueObservation?

    // MARK: - Outlets
    @IBOutlet weak var updateRepositoryButton: NSButton!
    @IBOutlet weak var progressBar: NSProgressIndicator!
    @IBOutlet weak var statusLabel: NSTextField!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        progressKeyValueObservation = progress.observe(\.completedUnitCount) { [weak self] _, _ in
            self?.updateUI()
        }

        let downloadPath = "/tmp"
        repository = CKANRepository(inDirectory: URL.init(fileURLWithPath: downloadPath), withDownloadURL: URL(string: "https://github.com/KSP-CKAN/CKAN-meta/archive/master.zip")!)
    }

    private func updateUI() {
        DispatchQueue.main.async {
            self.progressBar.minValue = 0
            self.progressBar.maxValue = Double(self.progress.totalUnitCount)
            self.progressBar.doubleValue = Double(self.progress.completedUnitCount)
        }
    }

    // MARK: - Actions
    @IBAction func updateRepository(button: NSButton) {
        statusLabel.stringValue = "Downloading File..."

        if repository?.repositoryZIPFileExists() == true {
            repository?.deleteZipFile()
            repository?.deleteUnzippedDirectory()
        }

        repository!.downloadRepositoryArchive() {
            self.processDownloadedFile()
        }
    }

    private func updateStatusLabel(_ newStatus: String) {
        DispatchQueue.main.async {
            self.statusLabel.stringValue = newStatus
        }
    }

    // MARK: - Repository Handling
    private func processDownloadedFile() {
        // unpack
        // https://developer.apple.com/documentation/foundation/progress
        updateStatusLabel("Unpacking File...")
        let success = repository!.unpackRepositoryArchive(progress: progress)
        if success == false {
            fatalError()
        }
        
        repository!.deleteZipFile()

        // parse
        updateStatusLabel("Parsing unpacked Repository...")
        repository!.readUnpackedRepositoryArchive()
        repository!.deleteUnzippedDirectory()

        // save to cache
        // repository.saveToCache()

        if let modCount = repository?.ckanFiles?.count {
            updateStatusLabel("Done. \(modCount) files decoded.")
        } else {
            updateStatusLabel("Done, but something is fishy")
        }
    }
}

protocol UpdateRepositoryViewControllerDelegate: class {
    func didDismiss(sender: WelcomeSheetViewController)
}
