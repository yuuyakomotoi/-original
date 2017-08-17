//
//  CellImageViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/04/24.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit

class CellImageViewController: UIViewController {
    
    var img = UIImageView()
    
    var time = Timer()
    
    var hideStatusbar: Bool = false
    
    
    @IBOutlet var backButton: UIButton!
    
    @IBOutlet var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = img.image
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        super.viewWillAppear(animated)
        
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        
        time = Timer.scheduledTimer(timeInterval: 0.22, target: self, selector: #selector(timer), userInfo: nil, repeats: false)
    }
    
    func timer(){
        hideStatusbar = true
        UIView.animate(withDuration: 0.1, delay: 0, options: .allowUserInteraction, animations: {
            self.setNeedsStatusBarAppearanceUpdate()
        }, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
//        hideStatusbar = true
//        UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction, animations: {
//            self.setNeedsStatusBarAppearanceUpdate()
//        }, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        hideStatusbar = false
        
        setNeedsStatusBarAppearanceUpdate()
        
        super.viewWillDisappear(animated)
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil
        )
    }
    
    override var prefersStatusBarHidden: Bool {
        return hideStatusbar
    }
    
//    override var prefersStatusBarHidden: Bool {
//        
//        return true
//    }
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
