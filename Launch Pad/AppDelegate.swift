//
//  AppDelegate.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 11.02.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    public let ckanManager = CKANManager(ckanClient: CKANClient(pyKanAdapter: PyKanAdapter()))

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

