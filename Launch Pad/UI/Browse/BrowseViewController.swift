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
    @IBOutlet weak var collectionView: NSCollectionView!
    let ckanClient = CKANClient(pyKanAdapter: PyKanAdapter())
    var modules_list = [Module]() {
        didSet {
            guard modules_list != oldValue else { return }
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        DispatchQueue.main.async {
            self.modules_list = self.ckanClient.listModules()
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
    }

    private func configureCollectionView() {
        view.wantsLayer = true
        collectionView.enclosingScrollView?.borderType = .noBorder

        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 280.0, height: 120.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 10.0, left: 20.0, bottom: 10.0, right: 20.0)
        flowLayout.minimumInteritemSpacing = 20.0
        flowLayout.minimumLineSpacing = 20.0
        collectionView.collectionViewLayout = flowLayout
    }
}

extension BrowseViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return modules_list.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ModuleCollectionViewItem"), for: indexPath)
        guard let moduleCollectionViewItem = item as? ModuleCollectionViewItem else { return item }
        moduleCollectionViewItem.module = modules_list[indexPath.item]
        return moduleCollectionViewItem
    }
}
