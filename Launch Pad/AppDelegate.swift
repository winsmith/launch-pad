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
    // public let ckanManager = CKANManager(ckanClient: CKANClient(pyKanAdapter: PyKanAdapter()))

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let repository = CKANRepository(inDirectory: URL.init(fileURLWithPath: "/Applications/Kerbal Space Program/temp"), withDownloadURL: URL(string: "https://github.com/KSP-CKAN/CKAN-meta/archive/master.zip")!)
        repository.downloadRepositoryArchive() {
            print("Download complete")
            repository.unpackRepositoryArchive {
                print("unpack complete")
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

