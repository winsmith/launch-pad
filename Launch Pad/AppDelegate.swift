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
        let downloadPath = "/tmp"
        let repository = CKANRepository(inDirectory: URL.init(fileURLWithPath: downloadPath), withDownloadURL: URL(string: "https://github.com/KSP-CKAN/CKAN-meta/archive/master.zip")!)

        let doUnpack = {
            print("Unpacking Repository Zip File to \(downloadPath)... ")
            // https://developer.apple.com/documentation/foundation/progress
            let progress = Progress()
            let success = repository.unpackRepositoryArchive(progress: progress)
            print("Call returned \(success ? "success" : "nothing unpacked")")
        }

        let doParse = {
            print("Parsing unpacked Repository...")
            repository.readUnpackedRepositoryArchive()
            print("Parsing Done")
        }

        if repository.repositoryZIPFileExists() {
            print("Repository ZIP File already exists")
            doUnpack()
            doParse()
        } else {
            print("Downloading Repository ZIP File to \(downloadPath)...")
            repository.downloadRepositoryArchive() {
                print("Downloading Repository ZIP File Complete")
                doUnpack()
                doParse()
            }
        }

        // repository.readUnpackedRepositoryArchive(rootDirectoryURL: URL.init(fileURLWithPath: "/Applications/Kerbal Space Program/temp/CKAN-meta-master"))
        // repository.saveToCache()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

