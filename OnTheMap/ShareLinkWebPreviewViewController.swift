//
//  ShareLinkWebPreviewViewController.swift
//  OnTheMap
//
//  Created by Humberto Aquino on 4/15/15.
//  Copyright (c) 2015 Humberto Aquino. All rights reserved.
//

import Foundation
import UIKit

class ShareLinkWebPreviewViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var urlString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBarHidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let url = NSURL(string: urlString)!
        let request = NSURLRequest(URL: url)
        
        webView.loadRequest(request)
    }
    
    
    
}