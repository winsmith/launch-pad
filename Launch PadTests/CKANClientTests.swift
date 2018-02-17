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

    func testListKSPDirs() {
        fakePyKanAdapter.cannedResponse = "Using KSP Directory:  /Applications/Kerbal Space Program\n0: /Applications/Kerbal Space Program"
        let expected = [KSPDir(path: "/Applications/Kerbal Space Program")]
        XCTAssertEqual(ckanClient.listKSPDirs(), expected)
    }

    func testCurrentKSPDir() {
        fakePyKanAdapter.cannedResponse = "Using KSP Directory:  /Applications/Kerbal Space Program\n0: /Applications/Kerbal Space Program"
        let expected: KSPDir? = KSPDir(path: "/Applications/Kerbal Space Program")
        XCTAssertEqual(ckanClient.currentKSPDir(), expected)
    }
}
