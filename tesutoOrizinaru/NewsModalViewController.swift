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
    
    var app_News_Check = false
    
    var go_Back = UIBarButtonItem()
    
    var go_Forward = UIBarButtonItem()

    
    @IBOutlet var webView: UIWebView!
    
    //もし画面が横方向なら
    func isLandscape() -> Bool {
        return UIInterfaceOrientationIsLandscape(UIApplication.shared.statusBarOrientation)
    }
    //もし画面が縦方向なら
    func isPortrait() -> Bool {
        return UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//閉じるときに呼ばれるメソッド
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        let cansell = UIBarButtonItem(title: "閉じる", style: UIBarButtonItemStyle.plain, target: self, action:#selector(back))
    
        
         go_Back = UIBarButtonItem(title: "＜", style: UIBarButtonItemStyle.plain, target: self, action:#selector(goBack))
        
         go_Forward = UIBarButtonItem(title: "＞", style: UIBarButtonItemStyle.plain, target: self, action:#selector(goForward))
        
        self.navigationItem.leftBarButtonItem = cansell
        
        self.navigationItem.rightBarButtonItems = [go_Forward,go_Back]
        
        
        webView.delegate = self
        
        webView.scalesPageToFit = true //PCサイトもwebViewの大きさに収まるようになる
        
        webView.contentMode = .scaleAspectFit //scalesPageToFit = trueとセットで画面に収まる
        
        webView.scrollView.bounces = false
        
        let url:URL = URL(string: str)!
        let urlRequest = NSURLRequest(url:url)
        webView.loadRequest(urlRequest as URLRequest)
        
        
        
        
        self.setupSwipeGestures()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (check == false){
            SVProgressHUD.show()
        }
        
        if (self.webView.canGoBack) {
            go_Back.isEnabled = true
        } else {
            go_Back.isEnabled = false
            
            // canGoForward == false の処理
        }
        
        if (self.webView.canGoForward) {
            go_Forward.isEnabled = true
        } else {
            // canGoForward == false の処理
            go_Forward.isEnabled = false
        }

        setupSwipeGestures()
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let navBarImage = UIImage(named: "navBarImage.png") as UIImage?
        self.navigationController?.navigationBar.setBackgroundImage(navBarImage,for:.default)
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        
        
        
    }

    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if (self.webView.canGoBack) {
            go_Back.isEnabled = true
        } else {
            go_Back.isEnabled = false
            
            // canGoForward == false の処理
        }
        
        if (self.webView.canGoForward) {
            go_Forward.isEnabled = true
        } else {
            // canGoForward == false の処理
            go_Forward.isEnabled = false
        }

        
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
    
    
    func back(){
        //閉じるときに縦にする
        if (isLandscape()){
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        }
        
        if app_News_Check == false{
        self.tabBarController?.tabBar.isHidden = false
        }
        
        self.navigationController?.popViewController(animated: true)
   //アップデート
    //グーグル新規登録
    }
    
        
    

    
    
        
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
}

