//
//  kouryakuViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/03/26.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit
import SVProgressHUD

class kouryakuViewController: UIViewController,UIWebViewDelegate {

   
    
    @IBOutlet var segmentButton: UISegmentedControl!
   
    
    @IBOutlet var webView: UIWebView!
    @IBOutlet var webView2: UIWebView!
    
    var url:String!
    
    @IBOutlet var backButton: UIButton!
   
    
    
    var webView_select:Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        webView2.delegate = self
        
        
        checGoBack()
        
        SVProgressHUD.show()
        
        let url = URL(string:"https://shironekotennis.gamewith.jp/")
        let urlReqestr = URLRequest(url:url!)
        
        webView.loadRequest(urlReqestr)
        //この形で覚える
        
        let url2 = URL(string:"https://twitter.com/Stennis_colopl")
        let urlReqestr2 = URLRequest(url:url2!)
        
        webView2.loadRequest(urlReqestr2)
        //画面にくるくる設置してあるので読み込む時はくるくるを非表示にする
                self.setupSwipeGestures()
        self.setupSwipeGestures2()
        
        }
    
    
    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        //webView読み込み開始時に呼ばれるメソッドくるくる回るやつ

    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        //webView読み込み終わったら呼ばれるメソッドくるくる回るやつ止まる
        checGoBack()
       

        SVProgressHUD.dismiss()
       
    }
    
    func checGoBack(){
        if webView_select == 1{
            if(webView.canGoBack){
                backButton.isEnabled = true
            }
            else{
                backButton.isEnabled = false
            }
        }
            else if webView_select == 2{
                if(webView2.canGoBack){
                    backButton.isEnabled = true
                }
                else{
                    backButton.isEnabled = false
                }

        }
    }
    
    func setupSwipeGestures() {
       
        // 右方向へのスワイプ
        let gestureToRight = UISwipeGestureRecognizer(target: self, action: #selector(kouryakuViewController.goBack))
        gestureToRight.direction = UISwipeGestureRecognizerDirection.right
        self.webView.addGestureRecognizer(gestureToRight)
        
        // 左方向へのスワイプ
        let gestureToLeft = UISwipeGestureRecognizer(target: self, action: #selector(kouryakuViewController.goForward))
        gestureToLeft.direction = UISwipeGestureRecognizerDirection.left
        self.webView.addGestureRecognizer(gestureToLeft)
    }
    
    func setupSwipeGestures2() {
        
        // 右方向へのスワイプ
        let gestureToRight = UISwipeGestureRecognizer(target: self, action: #selector(kouryakuViewController.goBack))
        gestureToRight.direction = UISwipeGestureRecognizerDirection.right
        self.webView2.addGestureRecognizer(gestureToRight)
        
        // 左方向へのスワイプ
        let gestureToLeft = UISwipeGestureRecognizer(target: self, action: #selector(kouryakuViewController.goForward))
        gestureToLeft.direction = UISwipeGestureRecognizerDirection.left
        self.webView2.addGestureRecognizer(gestureToLeft)
    }

    
    func goBack() {
        if webView_select == 1{
            
            
            if (self.webView.canGoBack) {
                self.webView.goBack()
            } else {
                // canGoForward == false の処理
            }
        }
        if webView_select == 2{
            
            
            if (self.webView2.canGoBack) {
                self.webView2.goBack()
            } else {
                // canGoForward == false の処理
            }
        }
    }
    
    func goForward() {
        if webView_select == 1{
            
        
        if (self.webView.canGoForward) {
            self.webView.goForward()
        } else {
            // canGoForward == false の処理
        }
        }
        if webView_select == 2{
            
        
        if (self.webView2.canGoForward) {
            self.webView2.goForward()
        } else {
            // canGoForward == false の処理
        }
        }
    }
    
    
    
    @IBAction func backButton(_ sender: Any) {
        if (webView_select == 1) {
            webView.goBack()
        }
        else{
           webView2.goBack()
        }
    }
   
    
    @IBAction func reload(_ sender: Any) {
        
        if (webView_select == 1) {
            webView.reload()
        }
        else{
            webView2.reload()
        }
    
    }
    
    @IBAction func segmentButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.view.bringSubview(toFront: webView)
        webView_select = 1
        print(webView_select)
            break
                case 1:
       self.view.bringSubview(toFront: webView2)
        webView_select = 2
        print(webView_select)
            break
        default:
            
            break
        }
        checGoBack()
        
    }
   
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}

