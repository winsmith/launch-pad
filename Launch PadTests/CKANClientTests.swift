//
//  CKANClientTests.swift
//  Launch PadTests
//
//  Created by Daniel Jilg on 15.02.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import XCTest

class CKANClientTests: XCTestCase {

    var fakePyKanAdapter: FakePyKanAdapter = FakePyKanAdapter()
    var ckanClient: CKANClient = CKANClient(pyKanAdapter: FakePyKanAdapter())

    override func setUp() {
        super.setUp()

        fakePyKanAdapter = FakePyKanAdapter()
        ckanClient = CKANClient(pyKanAdapter: fakePyKanAdapter)
    }
    
    override func tearDown() {
        super.tearDown()
    }

    // MARK: - KSP Directory
    func testListKSPDirsEmpty() {
        fakePyKanAdapter.cannedResponse = ""
        let expected = [KSPDir]()
        XCTAssertEqual(ckanClient.listKSPDirs(), expected)
    }

    func testListKSPDirs() {
        fakePyKanAdapter.cannedResponse = "Using KSP Directory:  /Applications/Kerbal Space Program\n0: /Applications/Kerbal Space Program"
        let expected = [KSPDir(path: "/Applications/Kerbal Space Program")]
        XCTAssertEqual(ckanClient.listKSPDirs(), expected)
    }

    func testCurrentKSPDirEmpty() {
        fakePyKanAdapter.cannedResponse = ""
        XCTAssertNil(ckanClient.currentKSPDir())
    }

    func testCurrentKSPDir() {
        fakePyKanAdapter.cannedResponse = "Using KSP Directory:  /Applications/Kerbal Space Program\n0: /Applications/Kerbal Space Program"
        let expected: KSPDir? = KSPDir(path: "/Applications/Kerbal Space Program")
        XCTAssertEqual(ckanClient.currentKSPDir(), expected)
    }

    // MARK: - Modules
    func testListModules() {
        fakePyKanAdapter.cannedResponse = "Using KSP Directory:  /Applications/Kerbal Space Program\nAGExt :  Action Groups Extended | 2.3.2.2 (Not installed)\nAJEExtendedConfigs :  AJE Extended | v1.1.1 (Installed)\nALCOR :  ALCOR | 0.9.7 (Not installed)"
        let expected = [
            Module(key: "AGExt", name: "Action Groups Extended", version: "2.3.2.2", installed: false),
            Module(key: "AJEExtendedConfigs", name: "AJE Extended", version: "v1.1.1", installed: true),
            Module(key: "ALCOR", name: "ALCOR", version: "0.9.7", installed: false)
        ]
        XCTAssertEqual(ckanClient.listModules(), expected)
    }
}
