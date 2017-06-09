//
//  BBS_PostData.swift
//  tesutoOrizinaru
//
//  Created by Suzuki Hideaki on 2017/05/08.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class BBS_PostData1:NSObject{
	var id:String
	var bbs_type:Int = 0
	var image:UIImage?
	var imageString:String?
	var profile_image:UIImage?
	var profile_imageString:String?
	var userId:String = ""
    var name:String = "No Name"
	var comment:String = ""
	var comment2:String = ""
	var date:String?
	var comments:[String] = []
	var category:String?
	var comment_id:String?
	var comment_num:Int = 0

	init(snapshot:FIRDataSnapshot,myId:String){
		self.id = snapshot.key

		let valueDictionary = snapshot.value as! [String:AnyObject]

		imageString = valueDictionary["image"] as? String
		if ( imageString != nil ) {
			image = UIImage(data:NSData(base64Encoded:imageString!,options: .ignoreUnknownCharacters)! as Data)
		}

		profile_imageString = valueDictionary["profile_image"] as? String
		if ( profile_imageString != nil ) {
			profile_image = UIImage(data:NSData(base64Encoded:profile_imageString!,options: .ignoreUnknownCharacters)! as Data)
		}

		if ( valueDictionary["bbs_type"] != nil ) {
			self.bbs_type = valueDictionary["bbs_type"] as! Int
		}
        
        if ( valueDictionary["userId"] != nil ) {
            self.userId = valueDictionary["userId"] as! String
        }

		if ( valueDictionary["username"] != nil ) {
			self.name = valueDictionary["username"] as! String
		}

		if ( valueDictionary["category"] != nil ) {
			self.category = valueDictionary["category"] as? String
		}

		if ( valueDictionary["comment"] != nil ) {
			self.comment = valueDictionary["comment"] as! String
		}
		if ( valueDictionary["comment2"] != nil ) {
			self.comment2 = valueDictionary["comment2"] as! String
		}

		if ( valueDictionary["date"] != nil ) {
			let time = valueDictionary["date"] as? String
			self.date = time
		}

		if let comments = valueDictionary["comments"] as? [String]{
			self.comments = comments
		}

		if let comment_id = valueDictionary["comment_id"] as? String {
			self.comment_id = comment_id//ネーム
		}

		if  let comment_num = valueDictionary["comment_num"] {
			self.comment_num = comment_num as! Int
		}
	}
}







