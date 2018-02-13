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

    override func loadView() {
        super.loadView()
        webView.uiDelegate = self
        webView.navigationDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        debugPrint("loading")
        let myURL = URL(string: "https://www.apple.com")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
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
