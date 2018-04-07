//
//  BrowseViewController.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 13.02.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import AppKit

class BrowseViewController: NSViewController {
    @IBOutlet private weak var collectionView: NSCollectionView!
    @IBOutlet weak var welcomeBox: NSBox!
    private var moduleDetailViewController: ModuleDetailViewController?
    private let appDelegate = NSApplication.shared.delegate as? AppDelegate
    private let notificationCenter = NotificationCenter.default
    internal var modules: [Module] = []
    public var filter: String? { didSet { updateData() } }
    internal var filteredModules: [Module] {
        guard let filter = filter else { return modules }
        guard filter != "" else { return modules }
        return self.modules.filter { $0.name.contains(filter) || $0.latestRelease.authors?.joined(separator: " ").contains(filter) == true }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureNotifications()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        updateData()
    }

    private func configureCollectionView() {
        view.wantsLayer = true
        collectionView.enclosingScrollView?.borderType = .noBorder

        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 300.0, height: 60.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0)
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
        return filteredModules.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ModuleCollectionViewItem"), for: indexPath)
        guard let moduleCollectionViewItem = item as? ModuleCollectionViewItem else { return item }

        moduleCollectionViewItem.module = filteredModules[indexPath.item]
        return moduleCollectionViewItem
    }
}

extension BrowseViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard
            let indexPath = indexPaths.first,
            filteredModules.count > indexPath.item
        else { return }

        let module = filteredModules[indexPath.item]
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
