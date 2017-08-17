//
//  HomeViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/03/26.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit
import Social
import MessageUI
import SVProgressHUD


class HomeViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate {
    
    var tableViewTitle = ["プロフィールを変更","お気に入り","お気に入りユーザー","SNSで勧める","問い合わせ"]
    var tableViewTitle2 = ["アプリニュース","お勧めのサービス"]
    var sectionTitle = [""," "]
    
    var imageArray = ["Entypo_d83d(10)_32.png","linecons_e029(7)_32.png","FontAwesome_f0c0(8)_32.png","sns.png","Material Icons_e0be(0)_32.png"
]
    
    var imageArray2 = ["FontAwesome_f02d(1)_32.png","Entypo_d83d(9)_32.png"]
    
    var usernameString:String = String()
    
    var myComposeView:SLComposeViewController!
    
    var mailViewController = MFMailComposeViewController()
    
    var mailCategory:String = ""
    
    @IBOutlet var userName: UILabel!
    
    @IBOutlet var userImage: UIImageView!
    
    @IBOutlet var homeTableView: UITableView!
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        homeTableView.delegate = self
        homeTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.navicheck == true{
            self.tabBarController?.tabBar.isHidden = false
        appDelegate.navicheck = false
        }
        
        SVProgressHUD.dismiss()
        
        userImage.layer.cornerRadius = userImage.frame.size.height/2
        userImage.clipsToBounds = true
        
        
        if UserDefaults.standard.object(forKey: "profileImage") != nil{
            
            //エンコードして取り出す
            let decodeData = UserDefaults.standard.object(forKey: "profileImage")
            
            let decodedData = NSData(base64Encoded:decodeData as! String , options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            let decodedImage = UIImage(data:decodedData! as Data)
            userImage.image = decodedImage
        }else{
            userImage.image = UIImage(named:"No User.png")
        }
        
        
        if  UserDefaults.standard.object(forKey: "userName") != nil{
            usernameString = UserDefaults.standard.object(forKey: "userName") as! String
            
            userName.text = usernameString
        }else{
            
            userName.text = "No Name"
        }
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //ナビゲーションのスワイプ有効
        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = true
        
        let navBarImage = UIImage(named: "navBarImage.png") as UIImage?
        self.navigationController?.navigationBar.setBackgroundImage(navBarImage,for:.default)
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        
        
        
        
    }

    
    func numberOfSections(in tableView: UITableView) -> Int { // sectionの数を決める
        return 2
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String?{
        return sectionTitle[section]
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return tableViewTitle.count
        } else if section == 1 {
            return tableViewTitle2.count
        } else {
            return 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath as IndexPath)
        
        cell.selectionStyle = .none
        
        if indexPath.section == 0 {
            cell.textLabel?.text = "\(tableViewTitle[indexPath.row])"
        } else if indexPath.section == 1 {
            cell.textLabel?.text = "\(tableViewTitle2[indexPath.row])"
        }
        
        if indexPath.section == 0 {
            let img = UIImage(named:"\(imageArray[indexPath.row])")
            
            cell.imageView?.image = img
        }
        else  if indexPath.section == 1{
            
            let img2 = UIImage(named:"\(imageArray2[indexPath.row])")
            
            cell.imageView?.image = img2
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row{
            case 0:
                let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.navicheck = true
                
                performSegue(withIdentifier:"next",sender:nil)
              
                break
            case 1:
//                self.tabBarController?.tabBar.isHidden = true
                
                let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.navicheck = true
                
                performSegue(withIdentifier:"favorite",sender:nil)
                
                break
            case 2:
                if UserDefaults.standard.object(forKey: "check") == nil{
                    let support = self.storyboard?.instantiateViewController(withIdentifier: "support")
                    self.navigationController?.pushViewController(support!, animated: true)
                    let check = "check"
                    UserDefaults.standard.set(check, forKey: "check")

                }else{

                
                let favoriteUserViewController = self.storyboard?.instantiateViewController(withIdentifier: "favoriteuser") as! FavoriteUserViewController
                present(favoriteUserViewController, animated: true, completion: nil)
                }
                    break
            case 3:
                let alertController = UIAlertController(title: "紹介方法を選択してください", message: "", preferredStyle: .actionSheet)
                
                let cancelAction:UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: {
                    (action:UIAlertAction!) -> Void in
                })
                
                let defaultAction1:UIAlertAction = UIAlertAction(title: "LINE", style: .default, handler: {
                    (action:UIAlertAction!) -> Void in
                    self.postLINE()
                })
                
                let defaultAction2:UIAlertAction = UIAlertAction(title: "Twitter", style: .default, handler: {
                    (action:UIAlertAction!) -> Void in
                    self.postTwitter()
                })
                
                let defaultAction3:UIAlertAction = UIAlertAction(title: "Facebook", style: .default, handler: {
                    (action:UIAlertAction!) -> Void in
                    self.postFacebook()
                })
                
                alertController.addAction(cancelAction)
                alertController.addAction(defaultAction1)
                alertController.addAction(defaultAction2)
                alertController.addAction(defaultAction3)
                
                present(alertController, animated: true, completion: nil)
            
                break
                case 4:
                
                    if UserDefaults.standard.object(forKey: "userName") == nil{
                        
                        let alertViewControler = UIAlertController(title: "問い合わせにはプロフィール登録が必要です", message: "「プロフィールを変更」よりプロフィール登録を行ってください", preferredStyle:.alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler:{
                            (action:UIAlertAction!) -> Void in
                            return
                        })
                        
                        alertViewControler.addAction(okAction)
                        present(alertViewControler, animated: true, completion: nil)
                        
                    }else{
                    
                    
                    let alertController = UIAlertController(title: "件名を選択してください", message: "", preferredStyle: .actionSheet)
                
                let cancelAction:UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: {
                    (action:UIAlertAction!) -> Void in
                })
                
                let defaultAction1:UIAlertAction = UIAlertAction(title: "要望", style: .default, handler: {
                    (action:UIAlertAction!) -> Void in
                  self.mailCategory = "【要望】"
                    self.openMail()
                })
                
                let defaultAction2:UIAlertAction = UIAlertAction(title: "不具合", style: .default, handler: {
                    (action:UIAlertAction!) -> Void in
                   self.mailCategory = "【不具合】"
                    self.openMail()
                })
                
                
                
                let defaultAction4:UIAlertAction = UIAlertAction(title: "その他", style: .default, handler: {
                    (action:UIAlertAction!) -> Void in
                     self.mailCategory = "【その他】"
                    self.openMail()
                })
                
                alertController.addAction(cancelAction)
                alertController.addAction(defaultAction1)
                alertController.addAction(defaultAction2)
                
                alertController.addAction(defaultAction4)
                
                present(alertController, animated: true, completion: nil)
break
                }
                        default:
                break
            }
            
            
        }
        else if  indexPath.section == 1 {
            switch indexPath.row{
            case 0:
                
//                self.tabBarController?.tabBar.isHidden = true
                
                
                               
                let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.navicheck = true
                
                
                performSegue(withIdentifier:"app_News",sender:nil)
               
                
                

                break
                
            case 1:
                let url = URL(string:"https://peraichi.com/landing_pages/view/emeg8game")
                if( UIApplication.shared.canOpenURL(url!) ) {
                    UIApplication.shared.open(url!)
                }
            default:
                break
                
            }
        }
        
    }

    //修正中
    
    //LINEに投稿するメソッド
    //Info.plis設定あり
    func postLINE(){
        
        let lineSchemeMessage: String! = "line://msg/text/"
        var scheme: String! = lineSchemeMessage + "ニュース、動画、掲示板を\n一まとめに！！\nhttps://www.google.co.jp/"
        
        scheme =  scheme.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let messageURL: URL! = URL(string: scheme)
        
        self.openURL(messageURL)
        
    }
    //LINEに投稿するメソッド
    func openURL(_ url: URL) {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // 本来であれば、指定したURLで開けないときの実装を別途行う必要がある
            print("failed to open..")
        }
    }

    
    
    
    //Twitterに投稿するメソッド
    func postTwitter(){
        myComposeView = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        myComposeView.setInitialText("https://www.google.co.jp/")
       
        let img = UIImageView()
        img.image = UIImage(named: "images2.jpg")
        
        myComposeView.add(img.image)
        self.present(myComposeView, animated: true, completion: nil)
        
    }
    
    
    //FaceBookに投稿するメソッド
    func postFacebook(){
        myComposeView = SLComposeViewController(forServiceType:SLServiceTypeFacebook)
        myComposeView.setInitialText("https://www.google.co.jp/")
        
        let img = UIImageView()
        img.image = UIImage(named: "images2.jpg")
        
        myComposeView.add(img.image)
        self.present(myComposeView, animated: true, completion: nil)
    }
    
    func openMail(){
       
        mailViewController = MFMailComposeViewController()
        
        mailViewController.mailComposeDelegate = self
        
        //setMessageBody ＝ 本文
        mailViewController.setMessageBody("以下の項目をご記入の上、メールを送信してください。\n\n\n■発生時期：\n\n\n■お問い合わせ内容：\n\n\n\n\n件名は削除せずそのまま送信してください。\n内容によって回答を控えさせていただく場合もございます", isHTML: false)
        
        //setSubject = 件名
        mailViewController.setSubject(mailCategory + "ユーザー名:" + userName.text!)
        
        
        
        //To(誰に送るか？ オリジナルアプリは自分自身に送る)
        //一度定数の中に文字列を入れる
        let mailAddress = ["mail@gmail.com"]
        mailViewController.setToRecipients(mailAddress)
        
        present(mailViewController, animated: true, completion: nil)
    }
    
    //メール画面を閉じる必須メソッド
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result.rawValue {
        case MFMailComposeResult.cancelled.rawValue:
            print("Email Send Cancelled")
            break
        case MFMailComposeResult.saved.rawValue:
            print("Email Saved as a Draft")
            break
        case MFMailComposeResult.sent.rawValue:
            print("Email Sent Successfully")
            break
        case MFMailComposeResult.failed.rawValue:
            print("Email Send Failed")
            break
        default:
            break
        }
        
        self.dismiss(animated: true, completion: nil)
        
        
    }

    
    override func prepare(for segue:UIStoryboardSegue,sender:Any?){
        
        if segue.identifier == "next"{
        
        let changeprofileviewcontroller:ChangeProfileViewController = segue.destination as! ChangeProfileViewController
        
        changeprofileviewcontroller.name = userName.text!
        changeprofileviewcontroller.img = userImage
    
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
