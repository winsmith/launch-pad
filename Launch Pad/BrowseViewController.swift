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

    let ckanClient = CKANClient()

    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            let modules_list = self.ckanClient.listModules().reduce("", +)
            self.webView.loadHTMLString(modules_list, baseURL: nil)

        }
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
