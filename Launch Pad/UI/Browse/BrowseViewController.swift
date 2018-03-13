//
//  BrowseViewController.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 13.02.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import AppKit
import WebKit

class BrowseViewController: NSViewController {
    @IBOutlet private weak var collectionView: NSCollectionView!
    @IBOutlet weak var welcomeBox: NSBox!
    private var moduleDetailViewController: ModuleDetailViewController?
    private let appDelegate = NSApplication.shared.delegate as? AppDelegate
    private let notificationCenter = NotificationCenter.default
    private var modules: [CKANModule] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNotifications()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    private func configureCollectionView() {
        view.wantsLayer = true
        collectionView.enclosingScrollView?.borderType = .noBorder

        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 300.0, height: 60.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 1.0
        collectionView.collectionViewLayout = flowLayout
    }

    private func configureNotifications() {
        notificationCenter.addObserver(self, selector: #selector(updateData), name: CKANRepository.allModulesUpdatedNotification, object: nil)
    }

    @objc func updateData() {
        DispatchQueue.main.async {
            self.modules = self.appDelegate?.ckanClient?.newestCompatibleModules ?? []
            self.collectionView.reloadData()
        }
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let destination = segue.destinationController
        if let moduleDetailViewController = destination as? ModuleDetailViewController {
            self.moduleDetailViewController = moduleDetailViewController
        }
    }
}

// MARK: - NSCollectionViewDataSource
extension BrowseViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return modules.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ModuleCollectionViewItem"), for: indexPath)
        guard let moduleCollectionViewItem = item as? ModuleCollectionViewItem else { return item }

        moduleCollectionViewItem.module = modules[indexPath.item]
        return moduleCollectionViewItem
    }
}

extension BrowseViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard
            let indexPath = indexPaths.first,
            modules.count > indexPath.item
        else { return }

        let module = modules[indexPath.item]
        moduleDetailViewController?.kspInstallation = self.appDelegate?.ckanClient?.kspInstallation
        moduleDetailViewController?.module = module
        welcomeBox.isHidden = true
        deselectAllItems()
        selectItem(at: indexPath)
    }

    func deselectAllItems() {
        collectionView.visibleItems().forEach { item in
            item.isSelected = false
        }
    }

    func selectItem(at indexPath: IndexPath) {
        collectionView.item(at: indexPath)?.isSelected = true
    }
}
