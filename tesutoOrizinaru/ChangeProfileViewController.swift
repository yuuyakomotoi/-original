//
//  ChangeProfileViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/04/18.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit
import SVProgressHUD

class ChangeProfileViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {


	var name = String()

	var img = UIImageView()

    var user_Profile_Check = ""

    
	@IBOutlet var usernameTextField: UITextField!


	@IBOutlet var profileImageView: UIImageView!


	@IBOutlet var profileChangeLabel: UILabel!


	override func viewDidLoad() {
		super.viewDidLoad()

        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.navicheck == true{
            self.tabBarController?.tabBar.isHidden = true
        }

        
		usernameTextField.delegate = self
		usernameTextField.text = name


		profileImageView.image = img.image
	
    self.title = "プロフィール設定"
    }


	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
		profileImageView.clipsToBounds = true
		if profileImageView.image == UIImage(named: "No User.png"){
		}else{
			profileChangeLabel.text = ""
		}

	}

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserDefaults.standard.object(forKey: "user_Profile_Check") != nil{
            user_Profile_Check = UserDefaults.standard.object(forKey: "user_Profile_Check") as! String
        print(user_Profile_Check)
        }
        
        
        //ナビゲーションのスワイプ無効
        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = false
    }

    
    
	@IBAction func changeProfile(_ sender: AnyObject) {
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


		self.navigationController?.popViewController(animated: true)
	}


	@IBAction func done(_ sender: AnyObject)
	{
       
        if (usernameTextField.text != name){
           
            let date = Date()
            let calendar = Calendar.current
            
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            
            let calendar_Check = String(year) + String(month) + String(day)
        
        if (calendar_Check == user_Profile_Check){
            SVProgressHUD.showError(withStatus: "ユーザー名は翌日まで変更できません")
            return
        }
        }
        
        if (usernameTextField.text?.characters.count)! > 22{
           SVProgressHUD.showError(withStatus: "ユーザー名を22文字以内にしてください")
            return
        }
        
        if UserDefaults.standard.object(forKey: "userName") == nil{
            if usernameTextField.text == "No Name"{
                SVProgressHUD.showError(withStatus: "このユーザー名では登録できません")
                return
}
            
        }
        
        if (usernameTextField.text != name){
        
        let alertViewControler = UIAlertController(title: "本アプリは不正防止のため、登録したユーザー名は翌日まで変更できせん", message: "このユーザー名で登録しますか？ 尚、プロフィール画像は何度でも変更可能です", preferredStyle:.alert)
        let okAction = UIAlertAction(title: "このユーザー名で登録する", style: .default, handler:{
            (action:UIAlertAction!) -> Void in
            self.doneAction()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alertViewControler.addAction(okAction)
        alertViewControler.addAction(cancelAction)
        present(alertViewControler, animated: true, completion: nil)
        
        }else{
            var data: NSData = NSData()
            if let image = profileImageView.image{
                
                data = UIImageJPEGRepresentation(image, 0.1)! as NSData
                let base64String = data.base64EncodedString(options:
                    NSData.Base64EncodingOptions.lineLength64Characters
                    ) as String
                UserDefaults.standard.set(base64String,forKey:"profileImage")
                

             }
            
            self.navigationController?.popViewController(animated: true)
       
        }

	}


	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

		if(usernameTextField.isFirstResponder){

			usernameTextField.resignFirstResponder()
           
            if (usernameTextField.text != name){
                
                let date = Date()
                let calendar = Calendar.current
                
                let year = calendar.component(.year, from: date)
                let month = calendar.component(.month, from: date)
                let day = calendar.component(.day, from: date)
                
                let calendar_Check = String(year) + String(month) + String(day)
                
                if (calendar_Check == user_Profile_Check){
                  
                    usernameTextField.text = name
                    
                    let alertViewControler = UIAlertController(title: "ユーザー名は翌日まで変更できません", message: "", preferredStyle:.alert)
                    let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertViewControler.addAction(cancelAction)
                    present(alertViewControler, animated: true, completion: nil)
                    
                    
                }

            }
		}

	}

	func openCamera(){


		let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
		// カメラが利用可能かチェック
		if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
			// インスタンスの作成
			let cameraPicker = UIImagePickerController()
			cameraPicker.sourceType = sourceType
			cameraPicker.delegate = self
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
			self.present(cameraPicker, animated: true, completion: nil)

		}


	}

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
			profileImageView.image = pickedImage
			profileChangeLabel.text = ""
		}

    
        
		//カメラ画面(アルバム画面)を閉じる処理
		picker.dismiss(animated: true, completion: nil)
	}
/*
	private func imagePickerController(_ imagePicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
		if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
			profileImageView.image = pickedImage
			profileChangeLabel.text = ""
		}

		//カメラ画面(アルバム画面)を閉じる処理
		imagePicker.dismiss(animated: true, completion: nil)

	}
*/

    func doneAction (){
        var data: NSData = NSData()
        if let image = profileImageView.image{
            
            
            data = UIImageJPEGRepresentation(image, 0.1)! as NSData
            
        }
        
        let userName = usernameTextField.text
        let base64String = data.base64EncodedString(options:
            NSData.Base64EncodingOptions.lineLength64Characters
            ) as String
        
        
       
        if UserDefaults.standard.object(forKey: "user_Profile_Check") == nil{
            let date = Date()
            let calendar = Calendar.current
           
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            
            let calendar_Check = String(year) + String(month) + String(day)
            
            UserDefaults.standard.set(calendar_Check, forKey: "user_Profile_Check")
            print(day)
        }else{
            UserDefaults.standard.removeObject(forKey: "user_Profile_Check")
            
            let date = Date()
            let calendar = Calendar.current
            
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            
            let calendar_Check = String(year) + String(month) + String(day)

            UserDefaults.standard.set(calendar_Check, forKey: "user_Profile_Check")
        }
        

        
        //アプリ内へ保存する
        UserDefaults.standard.set(base64String,forKey:"profileImage")
        UserDefaults.standard.set(userName,forKey:"userName")
        
        
        self.navigationController?.popViewController(animated: true)

    }
    

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()


	}
}
