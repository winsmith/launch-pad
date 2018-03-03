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
    private var moduleDetailViewController: ModuleDetailViewController?
    private let appDelegate = NSApplication.shared.delegate as? AppDelegate
    private let notificationCenter = NotificationCenter.default

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNotifications()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // appDelegate?.ckanManager.refreshModules()
    }

    private func configureCollectionView() {
        view.wantsLayer = true
        collectionView.enclosingScrollView?.borderType = .noBorder

        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 280.0, height: 120.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 10.0
        collectionView.collectionViewLayout = flowLayout
    }

    private func configureNotifications() {
        notificationCenter.addObserver(self, selector: #selector(updateData), name: CKANManager.allModulesUpdatedNotification, object: nil)
    }

    @objc func updateData() {
        self.collectionView.reloadData()
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
        // return appDelegate?.ckanManager.modules.count ?? 0
        return 0
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ModuleCollectionViewItem"), for: indexPath)
//        guard let modules_list = nil else { return item }
        guard let moduleCollectionViewItem = item as? ModuleCollectionViewItem else { return item }

//        moduleCollectionViewItem.module = modules_list[indexPath.item]
        return moduleCollectionViewItem
    }
}

extension BrowseViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        let modules = [Module]()
        guard
            // let modules = appDelegate?.ckanManager.modules,
            let indexPath = indexPaths.first,
            modules.count > indexPath.item
        else { return }

        let module = modules[indexPath.item]
        moduleDetailViewController?.module = module
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
