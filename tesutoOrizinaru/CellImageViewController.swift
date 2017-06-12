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
    
    
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = img.image
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil
        )
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
}
}
