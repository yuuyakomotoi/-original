//
//  BulletinBoardTableViewCell2.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/05/23.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit

class BulletinBoardTableViewCell2: UITableViewCell {

   
    
@IBOutlet var backView: UIView!
    
    
    @IBOutlet var profileImageView: UIImageView!
    
    @IBOutlet var userNameLabel: UILabel!
    
    
    @IBOutlet var time: UILabel!
    
    
    @IBOutlet var commentLabel: UILabel!
    
    @IBOutlet var postedImageView: UIImageView!
    
    
    
    @IBOutlet var profileLinkButton: UIButton!
    
    
    @IBOutlet var likeButton: UIButton!
    
    
    
    @IBOutlet var replyLabel: UILabel!
    
    
    @IBOutlet var cell_Reply_Count: UILabel!
    
    
    @IBOutlet var ngButton: UIButton!
    
    
    @IBOutlet var okButton: UIButton!
    
    
    @IBOutlet var postedImage_height: NSLayoutConstraint!
    
    
    @IBOutlet var likeButton_height: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    
    func setPostData(BBS_PostData1:BBS_PostData1){
     
        
    }

    
}
