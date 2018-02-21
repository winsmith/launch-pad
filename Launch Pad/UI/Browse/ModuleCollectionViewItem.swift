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
    @IBOutlet weak var installedLabel: NSTextField!

    var module: Module? {
        didSet {
            guard module != oldValue else { return }
            nameLabel.stringValue = module?.name ?? ""
            versionLabel.stringValue = module?.version ?? ""
            installedLabel.stringValue = module?.isInstalled == true ? "Installed ✅" : "Not Installed"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.color(named: .BackgroundColor).cgColor
        view.layer?.cornerRadius = 5.0
        view.layer?.borderColor = NSColor.color(named: .DarkAccent).cgColor
        view.layer?.borderWidth = 1.0
    }
    
}
