//
//  ModuleItem.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 19.02.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Cocoa

class ModuleCollectionViewItem: NSCollectionViewItem {
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var versionLabel: NSTextField!

    var module: Module? {
        didSet {
            guard module != oldValue else { return }
            nameLabel.stringValue = module?.name ?? ""
            versionLabel.stringValue = module?.version ?? ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
}
