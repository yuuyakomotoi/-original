//
//  EditViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/04/19.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class MultiViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,UITextFieldDelegate {
    
   var userId:String = ""
    
    @IBOutlet var textViewLabel: UILabel!
    
    var willEditImage:UIImage = UIImage()
    
    var usernameString:String = String()
    
    var textComment2 = String()
    
    var textCategory2 = String()
    
    var image_Select = false
    
    @IBOutlet var myProfileImageView: UIImageView!
    
    
    @IBOutlet var categoryTextField: UITextField!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var commentTextView: UITextView!
    
    @IBOutlet var myProfileLabel: UILabel!
    
    
    @IBOutlet var imageViewLabel: UILabel!
    
    @IBOutlet var postButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryTextField.delegate = self
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
        if  UserDefaults.standard.object(forKey: "textComment2") != nil{
            textComment2 = UserDefaults.standard.object(forKey: "textComment2") as! String
            commentTextView.text = textComment2
            if textComment2 != ""{
                textViewLabel.text = ""
            }else{
                commentTextView.text = ""
            }
        }
        
        
        if  UserDefaults.standard.object(forKey: "textCategory2") != nil{
            textCategory2 = UserDefaults.standard.object(forKey: "textCategory2") as! String
            categoryTextField.text = textCategory2
        }else{
            categoryTextField.text = ""
            
        }
        
        }
    
    func textViewDidChange(_ textView: UITextView) {
        if(textView.text == ""){
            textViewLabel.text = " 本文を入力してください"
        }
    }
    
    
    
    @IBAction func clear(_ sender: Any) {
        commentTextView.text = ""
        categoryTextField.text = ""
        textViewLabel.text = " 本文を入力してください"
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
        
       let textComment2 = commentTextView.text
        let textCategory2 = categoryTextField.text
        
        UserDefaults.standard.set(textComment2,forKey:"textComment2")
        UserDefaults.standard.set(textCategory2,forKey:"textCategory2")
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func post(_ sender: AnyObject) {
        if (commentTextView.text == ""){
            commentTextView.text = " "
        }
        
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
            
            let textComment2 = commentTextView.text
            let textCategory2 = categoryTextField.text
            
            UserDefaults.standard.set(textComment2,forKey:"textComment2")
            UserDefaults.standard.set(textCategory2,forKey:"textCategory2")

            
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
            
            let textComment2 = commentTextView.text
            let textCategory2 = categoryTextField.text
            
            UserDefaults.standard.set(textComment2,forKey:"textComment2")
            UserDefaults.standard.set(textCategory2,forKey:"textCategory2")
           
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
        
        //カテゴリー
        let category = categoryTextField.text!
        
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
        
        
        //サーバーに飛ばす箱
        let user:NSDictionary = ["userId":userId,"username":username,"comment":message,"date":dateString,"category":category,"image":base64String,"profile_image":base64String2,"comment_id":"1","bbs_type":1]
        
        databaseRef.child(Const.PostPath1).childByAutoId().setValue(user)
        
        UserDefaults.standard.removeObject(forKey: "textComment2")
        UserDefaults.standard.removeObject(forKey: "textCategory2")
        
        //戻る
        dismiss(animated: true, completion: nil)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(commentTextView.isFirstResponder){
            
            commentTextView.resignFirstResponder()
            
        }
        if(categoryTextField.isFirstResponder){
            
            categoryTextField.resignFirstResponder()
            
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
    
        
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
}
