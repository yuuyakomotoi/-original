//
//  Support_ViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/06/01.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit

class Support_ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
//        let cansell = UIBarButtonItem(title: "戻る", style: UIBarButtonItemStyle.plain, target: self, action:#selector(back))
//        
//        self.navigationItem.leftBarButtonItem = cansell
        
        
    }

    
    func back() {
    self.navigationController?.popViewController(animated: true)
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
    

   
}
