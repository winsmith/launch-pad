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
        let repository = CKANRepository(inDirectory: URL.init(fileURLWithPath: "/tmp"), withDownloadURL: URL(string: "https://github.com/KSP-CKAN/CKAN-meta/archive/master.zip")!)
        if repository.repositoryZIPFileExists() {
            print("Repository ZIP File already exists")
            print("Unpacking Repository Zip File...")
            repository.unpackRepositoryArchive()
        } else {
            print("Downloading Repository ZIP File...")
            repository.downloadRepositoryArchive() { localArchiveURL in
                print("Downloading Repository ZIP File Complete")
                print("Unpacking Repository Zip File...")
                repository.unpackRepositoryArchive()
            }
        }

        // repository.readUnpackedRepositoryArchive(rootDirectoryURL: URL.init(fileURLWithPath: "/Applications/Kerbal Space Program/temp/CKAN-meta-master"))
        // repository.saveToCache()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

