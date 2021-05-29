//
//  HelpScreenVC.swift
//  Weather
//
//  Created by Narsingoju Chander on 5/29/21.
//

import UIKit
import WebKit

class HelpScreenVC: UIViewController, WKUIDelegate {

    @IBOutlet weak var webBGView: UIView!
    var webView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webBGView.layoutIfNeeded()
        webBGView.layoutSubviews()
        webView = WKWebView()
        
        //Setting background color for webview.
        webView.isOpaque = false
        webView.backgroundColor = UIColor.clear
        webView.scrollView.backgroundColor = UIColor.clear
        
        webBGView.addSubview(webView)
        
        //Setting auto layouts
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        webView.topAnchor.constraint(equalTo: webBGView.topAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: webBGView.bottomAnchor).isActive = true
        webView.leadingAnchor.constraint(equalTo: webBGView.leadingAnchor).isActive = true
        webView.trailingAnchor.constraint(equalTo: webBGView.trailingAnchor).isActive = true
        webView.layoutIfNeeded()
        webView.layoutSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let pdfURL = Bundle.main.url(forResource: "weather_help", withExtension: "pdf", subdirectory: nil, localization: nil) {
           let request = URLRequest.init(url: pdfURL)
           webView.load(request)
        }
    }
    
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}
