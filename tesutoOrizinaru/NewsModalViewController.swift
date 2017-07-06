//
//  NewsModalViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/04/05.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit
import SVProgressHUD

class NewsModalViewController: UIViewController,UIWebViewDelegate {
    
    var str = String()
    
    var check = false
    
    @IBOutlet var webView: UIWebView!
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        webView.delegate = self
        
        webView.scalesPageToFit = true //PCサイトもwebViewの大きさに収まるようになる
        webView.contentMode = .scaleAspectFit //scalesPageToFit = trueとセットで画面に収まる
        
        let url:URL = URL(string: str)!
        let urlRequest = NSURLRequest(url:url)
        webView.loadRequest(urlRequest as URLRequest)
        
        
        
        
        self.setupSwipeGestures()
        
    }
    
    
    
    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        if (check == false){
        SVProgressHUD.show()
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        
        
        
        SVProgressHUD.dismiss()
        check = true
    }
    
    
    func setupSwipeGestures() {
        // 右方向へのスワイプ
        let gestureToRight = UISwipeGestureRecognizer(target: self, action: #selector(NewsModalViewController.goBack))
        gestureToRight.direction = UISwipeGestureRecognizerDirection.right
        self.webView.addGestureRecognizer(gestureToRight)
        
        // 左方向へのスワイプ
        let gestureToLeft = UISwipeGestureRecognizer(target: self, action: #selector(NewsModalViewController.goForward))
        gestureToLeft.direction = UISwipeGestureRecognizerDirection.left
        self.webView.addGestureRecognizer(gestureToLeft)
        
    }
    
    
    func goBack() {
        if (self.webView.canGoBack) {
            self.webView.goBack()
        } else {
            // canGoForward == false の処理
        }
    }
    
    
    
    func goForward() {
        if (self.webView.canGoForward) {
            self.webView.goForward()
        } else {
            // canGoForward == false の処理
        }
    }
    
    @IBAction func back(_ sender: Any) {
    dismiss(animated: true, completion: nil)
    }
    
    
    
    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}

