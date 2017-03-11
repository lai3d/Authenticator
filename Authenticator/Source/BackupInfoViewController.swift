//
//  BackupInfoViewController.swift
//  Authenticator
//
//  Copyright (c) 2017 Authenticator authors
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import UIKit
import WebKit

class BackupInfoViewController: UIViewController, WKNavigationDelegate {
    private var viewModel: BackupInfo.ViewModel
    private let dispatchAction: (BackupInfo.Effect) -> Void

    private let webView = WKWebView()

    // MARK: Initialization

    init(viewModel: BackupInfo.ViewModel, dispatchAction: (BackupInfo.Effect) -> Void) {
        self.viewModel = viewModel
        self.dispatchAction = dispatchAction
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateWithViewModel(viewModel: BackupInfo.ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: View Lifecycle

    override func loadView() {
        view = webView
        webView.navigationDelegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Backups"

        view.backgroundColor = UIColor.otpBackgroundColor
        // Prevent a flash of white before WebKit fully loads the HTML content.
        webView.opaque = false

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done,
                                                            target: self,
                                                            action: #selector(done))

        if let path = NSBundle.mainBundle().pathForResource("BackupInfo", ofType: "html") {
            webView.loadRequest(NSURLRequest(URL: NSURL(fileURLWithPath: path)))
        }
    }

    // MARK: Target Actions

    func done() {
        dispatchAction(.Done)
    }

    // MARK: - WKNavigationDelegate

    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        // If the resuest is not for a file in the bundle, request it from Safari instead.
        if let url = navigationAction.request.URL where url.scheme != "file" {
            dispatchAction(.OpenURL(url))
            decisionHandler(.Cancel)
        } else {
            decisionHandler(.Allow)
        }
    }
}