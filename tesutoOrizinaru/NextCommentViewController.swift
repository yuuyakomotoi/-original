//
//  NextCommentViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/04/26.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class NextCommentViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate {

	var userId:String = ""
    
    var postData:BBS_PostData1!
	
	var post_select = 0
	var post_id = ""

	@IBOutlet var textViewLabel: UILabel!

	var willEditImage:UIImage = UIImage()

	var usernameString:String = String()

	var textComment5 = String()

    var image_Select = false
    
	@IBOutlet var myProfileImageView: UIImageView!

	@IBOutlet var imageView: UIImageView!

	@IBOutlet var commentTextView: UITextView!

	@IBOutlet var myProfileLabel: UILabel!


	@IBOutlet var imageViewLabel: UILabel!

  @IBOutlet var postButton: UIButton!

    
	

	override func viewDidLoad() {
		super.viewDidLoad()

		commentTextView.delegate = self
		myProfileImageView.layer.cornerRadius = 8.0
		myProfileImageView.clipsToBounds = true


		if UserDefaults.standard.object(forKey: "profileImage") != nil{

			//エンコードして取り出す
			let decodeData = UserDefaults.standard.object(forKey: "profileImage")

			let decodedData = NSData(base64Encoded:decodeData as! String , options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
			let decodedImage = UIImage(data:decodedData! as Data)
			myProfileImageView.image = decodedImage

			usernameString = UserDefaults.standard.object(forKey: "userName") as! String

			myProfileLabel.text = usernameString

		}else{

			myProfileImageView.image = UIImage(named:"No User.png")
			myProfileLabel.text = "匿名"
            
		}

	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		
        
        if  UserDefaults.standard.object(forKey: "textComment5") != nil{
			textComment5 = UserDefaults.standard.object(forKey: "textComment5") as! String
			commentTextView.text = textComment5
			if textComment5 != ""{
				textViewLabel.text = ""
			}else{
				commentTextView.text = ""

			}
		}

        postStop()
        
        
	}


	func textViewDidChange(_ textView: UITextView) {
		if(textView.text == ""){
			textViewLabel.text = " 本文を入力してください"
		}
	}


	@IBAction func clear(_ sender: Any) {
        commentTextView.text = ""
		textViewLabel.text = " 本文を入力してください"
	
        postStop()
   
    }





	@IBAction func postedImage(_ sender: AnyObject) {
		let alertViewControler = UIAlertController(title: "選択してください。", message: "", preferredStyle:.actionSheet)
		let cameraAction = UIAlertAction(title: "カメラ", style: .default, handler:{
			(action:UIAlertAction!) -> Void in

			//処理を書く
			self.openCamera()

		})

		let photosAction = UIAlertAction(title: "アルバム", style: .default, handler:{
			(action:UIAlertAction!) -> Void in

			//処理を書く
			self.openPhoto()

		})

		let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)


		alertViewControler.addAction(cameraAction)
		alertViewControler.addAction(photosAction)
		alertViewControler.addAction(cancelAction)

		present(alertViewControler, animated: true, completion: nil)



	}


	@IBAction func back(_ sender: AnyObject) {

		let textComment1 = commentTextView.text
		//アプリ内へ保存する

		UserDefaults.standard.set(textComment1,forKey:"textComment5")

		dismiss(animated: true, completion: nil)

	}

	@IBAction func post(_ sender: AnyObject) {

		postAll()

		
	}



	func openCamera(){


		let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
		// カメラが利用可能かチェック
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
			// インスタンスの作成
			let cameraPicker = UIImagePickerController()
			cameraPicker.sourceType = sourceType
			cameraPicker.delegate = self

			let textComment5 = commentTextView.text
			//アプリ内へ保存する

			UserDefaults.standard.set(textComment5,forKey:"textComment5")

			self.present(cameraPicker, animated: true, completion: nil)

		}

	}



	func openPhoto(){


		let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.photoLibrary
		// カメラが利用可能かチェック
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary){
			// インスタンスの作成
			let cameraPicker = UIImagePickerController()
			cameraPicker.sourceType = sourceType
			cameraPicker.delegate = self
			let textComment5 = commentTextView.text
			//アプリ内へ保存する

			UserDefaults.standard.set(textComment5,forKey:"textComment5")

			self.present(cameraPicker, animated: true, completion: nil)

		}


	}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
			imageView.image = pickedImage
			imageViewLabel.text = ""
		image_Select = true
        }

		//カメラ画面(アルバム画面)を閉じる処理
		picker.dismiss(animated: true, completion: nil)
	}




	func postAll(){

        var stop = 0
        
        for i in commentTextView.text.characters {
            if String(i) == "\n"{
                
                stop += 1
                
                if stop > 50{
                    SVProgressHUD.showError(withStatus: "改行が多すぎます")
                    return
                }
                
            }
        }

        
		let databaseRef = FIRDatabase.database().reference()

        //ユーザーID
        userId = UserDefaults.standard.object(forKey: "userId") as! String

        
		//ユーザー名
		let username = myProfileLabel.text!

		//コメント
		let message = commentTextView.text!


		//時間
		let date = NSDate()

		let formatter = DateFormatter()
		formatter.dateFormat = "MM-dd HH:mm"

		let dateString:String = formatter.string(from:date  as Date)



		//投稿画像
		var data:NSData = NSData()
		if let image = imageView.image{
			data = UIImageJPEGRepresentation(image,0.1)! as NSData
		}
		let base64String = data.base64EncodedString(options:NSData.Base64EncodingOptions.lineLength64Characters) as String


		//profile画像
		var data2:NSData = NSData()
		if let image2 = myProfileImageView.image{
			data2 = UIImageJPEGRepresentation(image2,0.1)! as NSData
		}
		let base64String2 = data2.base64EncodedString(options:NSData.Base64EncodingOptions.lineLength64Characters) as String

		print(post_id)

		//サーバーに飛ばす箱
		let user:NSDictionary = ["userId":userId,"username":username,"comment":message,"date":dateString,"image":base64String,"profile_image":base64String2,"comment_id":post_id]

		databaseRef.child(Const.PostPath1).childByAutoId().setValue(user)

		let org_databaseRef = FIRDatabase.database().reference().child(Const.PostPath1).child(post_id)
		let comment_num = postData.comment_num + 1
		org_databaseRef.updateChildValues(["comment_num":comment_num])

        UserDefaults.standard.removeObject(forKey: "textComment5")

		/*
		// Postsの中にある、post_idに該当するものを取得してきている
		if ( post_select == 0 ) {

		let postRef = FIRDatabase.database().reference().child("Posts").child(post_id)
		let commentArray = postRef.comments
		commentArray.append(user)
		let comments = ["comments": commentArray]
		postRef.updateChildValues(comments)
		}
		else if ( post_select == 1 ) {
		let postRef = FIRDatabase.database().reference().child("Posts2").child(post_id)
		let comments = ["comments": user]
		postRef.updateChildValues(comments)
		}
		else if ( post_select == 2 ) {
		let postRef = FIRDatabase.database().reference().child("Posts3").child(post_id)
		let comments = ["comments": user]
		postRef.updateChildValues(comments)
		}
		else if ( post_select == 3 ) {
		let postRef = FIRDatabase.database().reference().child("Posts4").child(post_id)
		let comments = ["comments": user]
		postRef.updateChildValues(comments)
		}


		//        databaseRef.child("\(post)").childByAutoId().setValue(user)

		UserDefaults.standard.removeObject(forKey: "textComment5")
		*/

		//戻る
		dismiss(animated: true, completion: nil)


	}

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

		if(commentTextView.isFirstResponder){

			commentTextView.resignFirstResponder()

            postStop()
		}
	}

	//textviewがフォーカスされたら、Labelを非表示
	func textViewShouldBeginEditing(_ textView: UITextView) -> Bool
	{
		textViewLabel.isHidden = true
		return true
	}

	//textviewからフォーカスが外れて、TextViewが空だったらLabelを再び表示
	func textViewDidEndEditing(_ textView: UITextView) {

        
		
        if(textView.text.isEmpty){
			textViewLabel.isHidden = false
		
        }
	}


        func postStop(){
        
        if commentTextView.text.isEmpty{
            if (image_Select == false){
            postButton.alpha = 0.8
        postButton.isEnabled = false
            }else{
                
            }
            }
        
        var count = 0
        var count2 = 0
        
        for i in commentTextView.text.characters{
            if String(i) == " " || String(i) == "\n"{
                count += 1
                count2 += 1
                print("count　-----> \(count)")
                print("count2　-----> \(count2)")
            }else{
                count2 -= 1
                print("count2　-----> \(count2)")
            }
            }
            
            if count == count2  {
                if (image_Select == false){

                postButton.alpha = 0.8
                postButton.isEnabled = false
                }else{
                    postButton.alpha = 1.0
                    postButton.isEnabled = true
                }
            }else{
                postButton.alpha = 1.0
                postButton.isEnabled = true

                print("commentTextView ----->  \(commentTextView.text!)")
            
        }
    }

    
    
  

	
    
    override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()

	}



}
