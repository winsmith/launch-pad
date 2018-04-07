//
//  InstalledViewController.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 29.03.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import AppKit

class InstalledViewController: BrowseViewController {
    override internal var filteredModules: [Module] {
        return modules.filter { $0.isInstalled }
    }
}
