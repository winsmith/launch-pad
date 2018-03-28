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
    @IBOutlet weak var authorLabel: NSTextField!
    @IBOutlet weak var versionLabel: NSTextField!

    var module: Module? {
        didSet {
            guard module != oldValue else { return }
            nameLabel.stringValue = module?.name ?? ""

            versionLabel.stringValue = module?.releases.first?.version ?? ""
            authorLabel.stringValue = module?.releases.first?.authors?.joined(separator: ", ") ?? ""
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.color(named: .BackgroundColor).cgColor
    }

    override var isSelected: Bool {
        didSet {
            view.wantsLayer = true

            let lightColor = NSColor.color(named: .BackgroundColor)
            let darkColor = NSColor.color(named: .DarkAccent)
            view.layer?.backgroundColor = isSelected ? darkColor.cgColor : lightColor.cgColor
            nameLabel.textColor = isSelected ? lightColor : darkColor
            versionLabel.textColor = isSelected ? lightColor : darkColor
        }
    }
}
