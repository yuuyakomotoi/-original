//
//  First_BulletinBoard_ViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/08/10.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit
import SVProgressHUD

class First_BulletinBoard_ViewController: UIViewController {

    var next_Count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

            }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate2:AppDelegate = UIApplication.shared.delegate as! AppDelegate
print(appDelegate2.o_TitleArray)
       
        SVProgressHUD.dismiss()
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if(appDelegate.navicheck2 == true){
            self.tabBarController?.tabBar.isHidden = false
       
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if(appDelegate.navicheck2 == true){
            self.navigationController!.interactivePopGestureRecognizer!.isEnabled = true
        }

    }
    
    
    @IBAction func next_Button1(_ sender: Any) {
    next_Count = 0
    next_Bulletin_Board()
    }
    
    @IBAction func next_Button2(_ sender: Any) {
        next_Count = 2
        next_Bulletin_Board()
    }
    
    
    @IBAction func next_Button3(_ sender: Any) {
    next_Count = 1
        next_Bulletin_Board()
    }
    
    @IBAction func next_Button4(_ sender: Any) {
    next_Count = 3
        next_Bulletin_Board()
    }

    @IBAction func next_Button5(_ sender: Any) {
    
    }
    
    @IBAction func next_Button6(_ sender: Any) {
   
    }
    
    func next_Bulletin_Board(){
        
        self.tabBarController?.tabBar.isHidden = true
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.navicheck2 = true
        
        performSegue(withIdentifier:"next_Bulletin_Board",sender:nil)
    }
    
    
    // 画面の自動回転をさせない
    override var shouldAutorotate: Bool {
        
        return false
        
    }
    
    // 画面をPortraitに指定する
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        return .portrait
        
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "next_Bulletin_Board"){
        let bulletinboardviewController:BulletinBoardViewController = segue.destination as! BulletinBoardViewController
            bulletinboardviewController.segmentCount = self.next_Count
    }
    }
}
