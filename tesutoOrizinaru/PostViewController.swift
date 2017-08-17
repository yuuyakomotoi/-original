//
//  PostViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/08/01.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD


class PostViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate {

    var userId:String = ""
    
    
    var willEditImage:UIImage = UIImage()
    
    var usernameString:String = String()
    
    var textComment = String()
    
    var image_Select = false
    
    var textCount = 255
    
    var textCheck = true
   
    var postData:BBS_PostData1!
    
    var post_id = ""
    
    
    @IBOutlet var textCountLabel: UILabel!
    
    
    @IBOutlet var myProfileImageView: UIImageView!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var commentTextView: UITextView!
    
    @IBOutlet var myProfileLabel: UILabel!
    
    
    @IBOutlet var imageViewLabel: UILabel!
    
    
    @IBOutlet var postButton: UIButton!
    
    
    var post_Check = false
    
    var postSelect = 0
    
    
    
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView.delegate = self
        myProfileImageView.layer.cornerRadius = myProfileImageView.frame.size.height/2
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
            myProfileLabel.text = "No Name"
            
            
            
        }

        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.navicheck == true{
            self.tabBarController?.tabBar.isHidden = true
        }

        
        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = false
        
        
        if (postSelect == 0){
           //雑談
            self.title = "雑談に投稿"
            if  UserDefaults.standard.object(forKey: "textComment1") != nil{
                textComment = UserDefaults.standard.object(forKey: "textComment1") as! String
                commentTextView.text = textComment
                
                textCount = 255
                textCountLabel.text = "\( (textCount) - (textComment.count))"
                textCount = textCount - (textComment.count)
                
            
            }else{
                commentTextView.text = ""
            }
        }else if(postSelect == 1){
            //マルチ
            self.title = "マルチ募集に投稿"
            if  UserDefaults.standard.object(forKey: "textComment2") != nil{
                textComment = UserDefaults.standard.object(forKey: "textComment2") as! String
                commentTextView.text = textComment
                textCount = 255
                textCountLabel.text = "\( (textCount) - (textComment.count))"
                textCount = textCount - (textComment.count)
           
            }else{
                commentTextView.text = "【部屋番号】"
            }
            }else if(postSelect == 2){
            //フレンド
            self.title = "フレンド募集に投稿"
            if  UserDefaults.standard.object(forKey: "textComment3") != nil{
                textComment = UserDefaults.standard.object(forKey: "textComment3") as! String
                commentTextView.text = textComment
                textCount = 255
                textCountLabel.text = "\( (textCount) - (textComment.count))"
                textCount = textCount - (textComment.count)
            }else{
                commentTextView.text = "【フレンドID】"
            }
            
        }else if(postSelect == 3){
            self.title = "チーム募集に投稿"
            if  UserDefaults.standard.object(forKey: "textComment4") != nil{
                textComment = UserDefaults.standard.object(forKey: "textComment4") as! String
                commentTextView.text = textComment
                textCount = 255
                textCountLabel.text = "\( (textCount) - (textComment.count))"
                textCount = textCount - (textComment.count)
            }else{
               commentTextView.text = "【チーム名】\n【リーグ】\n【現在の人数】\n【募集人数】\n【募集内容】"
            }
          
        }else if(postSelect == 10){
            self.title = "コメントを投稿"
            if  UserDefaults.standard.object(forKey: "textComment10") != nil{
                textComment = UserDefaults.standard.object(forKey: "textComment10") as! String
                commentTextView.text = textComment
                textCount = 255
                textCountLabel.text = "\( (textCount) - (textComment.count))"
                textCount = textCount - (textComment.count)
            }else{
                commentTextView.text = ""
            }
        }
        
        postStop()
        
    }
    
        //かいぎょうを全て""にしてから""なのか調べる
    //""なら開業がたくさんあるとtextViewLabel.text = " 本文を入力してください"が上の方で表示されないのでテキストを””にする
    
    //マルチの時はアラートでシングルかダブルスかイベントか確認
   
    
    @IBAction func reset(_ sender: Any) {
        
        
        
        if (postSelect == 0){
        commentTextView.text = ""
        UserDefaults.standard.set(commentTextView.text,forKey:"textComment1")
            textCount = 255
            textCountLabel.text = "\( (textCount) - (commentTextView.text.count))"
            textCount = textCount - (textComment.count)

        }else if(postSelect == 1){
        commentTextView.text = "【部屋番号】"
        UserDefaults.standard.set(commentTextView.text,forKey:"textComment2")
        }else if(postSelect == 2){
            commentTextView.text = "【フレンドID】"
        UserDefaults.standard.set(commentTextView.text,forKey:"textComment3")
        }else if(postSelect == 3){
        commentTextView.text = "【チーム名】\n【リーグ】\n【現在の人数】\n【募集人数】\n【募集内容】"
        UserDefaults.standard.set(commentTextView.text,forKey:"textComment4")
        }else if(postSelect == 10){
            commentTextView.text = ""
            UserDefaults.standard.set(commentTextView.text,forKey:"textComment10")
        }

        
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
    
    func openCamera(){
            
            
            let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.camera
            // カメラが利用可能かチェック
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera){
                // インスタンスの作成
                let cameraPicker = UIImagePickerController()
                cameraPicker.sourceType = sourceType
                cameraPicker.delegate = self
                
                let textComment = commentTextView.text
                //アプリ内へ保存する
                
                
                if (postSelect == 0){
                    UserDefaults.standard.set(textComment,forKey:"textComment1")
                }else if(postSelect == 1){
                    UserDefaults.standard.set(textComment,forKey:"textComment2")
                }else if(postSelect == 2){
                    UserDefaults.standard.set(textComment,forKey:"textComment3")
                }else if(postSelect == 3){
                    UserDefaults.standard.set(textComment,forKey:"textComment4")
                }else if(postSelect == 10){
                    UserDefaults.standard.set(textComment,forKey:"textComment10")
                }

                
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
                let textComment = commentTextView.text
                //アプリ内へ保存する
                
                if (postSelect == 0){
                    UserDefaults.standard.set(textComment,forKey:"textComment1")
                }else if(postSelect == 1){
                    UserDefaults.standard.set(textComment,forKey:"textComment2")
                }else if(postSelect == 2){
                    UserDefaults.standard.set(textComment,forKey:"textComment3")
                }else if(postSelect == 3){
            UserDefaults.standard.set(textComment,forKey:"textComment4")
                }else if(postSelect == 10){
                    UserDefaults.standard.set(textComment,forKey:"textComment10")
                }

        
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
    

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if(commentTextView.isFirstResponder){
            
            
            
            commentTextView.resignFirstResponder()
            
            
            var result = ""
            
            
            result = (commentTextView.text.pregReplace(pattern: "\\s", with: ""))

            if(result == "") {
                commentTextView.text = ""
            }
            
            
            
            postStop()
            
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        var result = ""
        var textComment = commentTextView.text
        
        if (postSelect == 0){
            result = (textComment?.pregReplace(pattern: "\\s", with: ""))!
            if (result == ""){
                textComment = ""
            }
            UserDefaults.standard.set(textComment,forKey:"textComment1")
      
            
            textCount = 255
                textCountLabel.text = "\( (textCount) - (textComment?.count)!)"
            textCount = textCount - (textComment?.count)!
        
            
        }else if(postSelect == 1){
            result = (textComment?.pregReplace(pattern: "\\s", with: ""))!
            if (result == ""){
                textComment = ""
            }
            UserDefaults.standard.set(textComment,forKey:"textComment2")
            textCount = 255
            textCountLabel.text = "\( (textCount) - (textComment?.count)!)"
            textCount = textCount - (textComment?.count)!
        }else if(postSelect == 2){
            result = (textComment?.pregReplace(pattern: "\\s", with: ""))!
            if (result == ""){
                textComment = ""
            }
            UserDefaults.standard.set(textComment,forKey:"textComment3")
            textCount = 255
            textCountLabel.text = "\( (textCount) - (textComment?.count)!)"
            textCount = textCount - (textComment?.count)!
        }else if(postSelect == 3){
            result = (textComment?.pregReplace(pattern: "\\s", with: ""))!
            if (result == ""){
                textComment = ""
            }
            UserDefaults.standard.set(textComment,forKey:"textComment4")
            textCount = 255
            textCountLabel.text = "\( (textCount) - (textComment?.count)!)"
            textCount = textCount - (textComment?.count)!
        }else if(postSelect == 10){
            result = (textComment?.pregReplace(pattern: "\\s", with: ""))!
            if (result == ""){
                textComment = ""
            }
            UserDefaults.standard.set(textComment,forKey:"textComment10")
            textCount = 255
            textCountLabel.text = "\( (textCount) - (textComment?.count)!)"
            textCount = textCount - (textComment?.count)!
        }
        
        postStop()
    }

    
    
    
    
    
    
    
    @IBAction func back(_ sender: AnyObject) {
        
        var result = ""
       
        var textComment = commentTextView.text
        
       
        
        result = (textComment?.pregReplace(pattern: "\\s", with: ""))!
        
        
        if(result == "") {
        textComment = ""
        }
            
            if (postSelect == 0){
                UserDefaults.standard.set(textComment,forKey:"textComment1")
            }else if(postSelect == 1){
                UserDefaults.standard.set(textComment,forKey:"textComment2")
            }else if(postSelect == 2){
                UserDefaults.standard.set(textComment,forKey:"textComment3")
            }else if(postSelect == 3){
                UserDefaults.standard.set(textComment,forKey:"textComment4")
            }else if(postSelect == 10){
                    UserDefaults.standard.set(textComment,forKey:"textComment10")
                
            
        }
        
        self.navigationController?.popViewController(animated: true)
        
    }

    
   
    @IBAction func post(_ sender: Any) {
    postAll()
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
    
    
    var result = ""
    var result2 = ""

    
    //    for i in commentTextView.text.characters {
//        a += String(i)
//    result = ""
//        result = a.pregReplace(pattern: "\\n\\n\\n", with: "あああ")
//    print(result.debugDescription)
//    }
    
    
    result = commentTextView.text.pregReplace(pattern: "\\n{3,}", with: "\n\n")
    result2 = result.pregReplace(pattern: " {1,}", with: " ")


    


    
    
    

    
    self.post_Check = true
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    appDelegate.post_Check = self.post_Check
    
    
    let databaseRef = FIRDatabase.database().reference()
    
    //ユーザーID
    userId = UserDefaults.standard.object(forKey: "userId") as! String
    
    
    //ユーザー名
    let username = myProfileLabel.text!
    
    //コメント
    var message = result2
    
    
    //時間
    let date = NSDate()
    
    let formatter = DateFormatter()
    formatter.dateFormat = "MM-dd HH:mm"
    
    let dateString:String = formatter.string(from:date  as Date)
    
    
//    let date1 = Date()
//    
//    let formatter = DateFormatter()
//    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//    
//    let dateString:String = formatter.string(from:date1  as Date)

    
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
    if(postSelect != 1){
    
    if(postSelect == 0){
    let user:NSDictionary = ["userId":userId,"username":username,"comment":message,"date":dateString,"image":base64String,"profile_image":base64String2,"comment_id":"0","bbs_type":0]
    databaseRef.child(Const.PostPath1).childByAutoId().setValue(user)
       UserDefaults.standard.removeObject(forKey: "textComment1")
    }else if(postSelect == 2){
        let user:NSDictionary = ["userId":userId,"username":username,"comment":message,"date":dateString,"image":base64String,"profile_image":base64String2,"comment_id":"2","bbs_type":2]
   databaseRef.child(Const.PostPath1).childByAutoId().setValue(user)
   UserDefaults.standard.removeObject(forKey: "textComment3")
    }else if(postSelect == 3){
        let user:NSDictionary = ["userId":userId,"username":username,"comment":message,"date":dateString,"image":base64String,"profile_image":base64String2,"comment_id":"3","bbs_type":3]
        databaseRef.child(Const.PostPath1).childByAutoId().setValue(user)
    UserDefaults.standard.removeObject(forKey: "textComment4")
    }else if(postSelect == 10){
        let user:NSDictionary = ["userId":userId,"username":username,"comment":message,"date":dateString,"image":base64String,"profile_image":base64String2,"comment_id":post_id]
        databaseRef.child(Const.PostPath1).childByAutoId().setValue(user)
        let org_databaseRef = FIRDatabase.database().reference().child(Const.PostPath1).child(post_id)
        let comment_num = postData.comment_num + 1
        org_databaseRef.updateChildValues(["comment_num":comment_num])

        UserDefaults.standard.removeObject(forKey: "textComment10")
        
        
        
        }
    
    
    self.navigationController?.popViewController(animated: true)
    
    }else{
        let alertViewControler = UIAlertController(title: "選択してください", message: "", preferredStyle:.alert)
        let Action1 = UIAlertAction(title:"【シングル】", style: .default, handler:{
            (action:UIAlertAction!) -> Void in
            
                message = "【シングル】\n" + result2
                let user:NSDictionary = ["userId":self.userId,"username":username,"comment":message,"date":dateString,"image":base64String,"profile_image":base64String2,"comment_id":"1","bbs_type":1]
                databaseRef.child(Const.PostPath1).childByAutoId().setValue(user)
                UserDefaults.standard.removeObject(forKey: "textComment2")
            self.navigationController?.popViewController(animated: true)
            }
            )
        
        let Action2 = UIAlertAction(title: "【ダブルス】", style: .default, handler:{
            (action:UIAlertAction!) -> Void in
            
            message = "【ダブルス】\n" + result2
            let user:NSDictionary = ["userId":self.userId,"username":username,"comment":message,"date":dateString,"image":base64String,"profile_image":base64String2,"comment_id":"1","bbs_type":1]
            databaseRef.child(Const.PostPath1).childByAutoId().setValue(user)
            UserDefaults.standard.removeObject(forKey: "textComment2")
            self.navigationController?.popViewController(animated: true)
            
        })
        
        let Action3 = UIAlertAction(title: "【イベント】", style: .default, handler:{
            (action:UIAlertAction!) -> Void in
            
            message = "【イベント】\n" + result2
            let user:NSDictionary = ["userId":self.userId,"username":username,"comment":message,"date":dateString,"image":base64String,"profile_image":base64String2,"comment_id":"1","bbs_type":1]
            databaseRef.child(Const.PostPath1).childByAutoId().setValue(user)
            UserDefaults.standard.removeObject(forKey: "textComment2")
            self.navigationController?.popViewController(animated: true)
            
        })

        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        
        alertViewControler.addAction(Action1)
        alertViewControler.addAction(Action2)
        alertViewControler.addAction(Action3)
        alertViewControler.addAction(cancelAction)
        
        
        present(alertViewControler, animated: true, completion: nil)
        
    }
  
    
    }

    
    func postStop(){
        
        if textCount < 0{
            
            postButton.alpha = 0.8
            postButton.isEnabled = false
        print("a")
        }else{
                postButton.alpha = 1.0
                postButton.isEnabled = true
            print("b")
            var result = ""
            result = commentTextView.text.pregReplace(pattern: "\\s", with: "")
            if(result == ""){
               
                if (image_Select == true){
                    postButton.alpha = 1.0
                    postButton.isEnabled = true
                }else{
                    postButton.alpha = 0.8
                    postButton.isEnabled = false
                }

            }
            
            }
        
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
