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


	@IBOutlet var usernameTextField: UITextField!


	@IBOutlet var profileImageView: UIImageView!


	@IBOutlet var profileChangeLabel: UILabel!


	override func viewDidLoad() {
		super.viewDidLoad()

        
        
		usernameTextField.delegate = self
		usernameTextField.text = name


		profileImageView.image = img.image
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
        //self.title = self.title! + "プロフィール設定"
    //次回質問
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
       
        
        if (usernameTextField.text?.characters.count)! > 22{
           SVProgressHUD.showError(withStatus: "ユーザー名を22文字以内にしてください")
            return
        }
        
        if UserDefaults.standard.object(forKey: "userName") == nil{
            if usernameTextField.text == "No Name"{
                SVProgressHUD.showError(withStatus: "この名前は利用できません")
                return

            }
            
        }
        
        
        let alertViewControler = UIAlertController(title: "本アプリは不正防止のため、一度登録した名前は今後変更できせん", message: "この名前で登録しますか？\n尚、プロフィール画像は何度でも変更可能です", preferredStyle:.alert)
        let okAction = UIAlertAction(title: "この名前で登録する", style: .default, handler:{
            (action:UIAlertAction!) -> Void in
            self.doneAction()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alertViewControler.addAction(okAction)
        alertViewControler.addAction(cancelAction)
        present(alertViewControler, animated: true, completion: nil)
        
        

	}


	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

		if(usernameTextField.isFirstResponder){

			usernameTextField.resignFirstResponder()

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
        
        //アプリ内へ保存する
        UserDefaults.standard.set(base64String,forKey:"profileImage")
        UserDefaults.standard.set(userName,forKey:"userName")
        
        
        self.navigationController?.popViewController(animated: true)

    }
    

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()


	}
}
