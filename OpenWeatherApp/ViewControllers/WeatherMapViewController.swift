//
//  WeatherMapViewController.swift
//  OpenWeatherApp
//
//  Created by MAC on 29.02.2020.
//  Copyright © 2020 Alex. All rights reserved.
//

import UIKit
import WebKit

class WeatherMapViewController: UIViewController, UIWebViewDelegate{

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    private var progressKVOhandle: NSKeyValueObservation?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url = URL(string: "https://www.windy.com")
        let request = URLRequest(url: url!)
        
        webView.load(request)
        
        progressKVOhandle = webView.observe(\.estimatedProgress) { [weak self] (object, _) in
        self?.progressView.setProgress(Float(object.estimatedProgress), animated: true)
            if self?.progressView.progress == 1.0 {
                self?.progressView.isHidden = true
                self?.loadingLabel.isHidden = true
            }
        }
    }

}
