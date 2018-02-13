        //
//  BrowseViewController.swift
//  Launch Pad
//
//  Created by Daniel Jilg on 13.02.18.
//  Copyright © 2018 breakthesystem. All rights reserved.
//

import AppKit
import WebKit

class BrowseViewController: NSViewController {
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        debugPrint("loading")
        webView.loadHTMLString("hello", baseURL: nil)
    }
}

extension BrowseViewController: WKUIDelegate {

}

extension BrowseViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        debugPrint("Web view finished loading")
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        debugPrint("Web View did terminate")
    }
}
