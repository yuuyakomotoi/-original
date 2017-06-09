//
//  NavigationBar.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/03/26.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit

class NavigationBar: UINavigationBar {
    let navBarBorder = UIView()
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var barSize = super.sizeThatFits(size)
        barSize.height = 150
        return barSize;
    }
    

}
