//
//  BulletinBoardViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/04/18.
//  Copyright © 2017年 小本裕也. All rights reserved.
////////
//ユーザーインターラクショ  self.tableView.isUserInteractionEnabled = false
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class BulletinBoardViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
    
    
    
    var ok_UserArayy:[String] = []
    
    var ng_UserArayy:[String] = []
    
    var favorite_Post_Arayy:[String] = []
    
    var items = [BBS_PostData1]()
    
    
    

    var bulletinBoard_Image_Button = UIBarButtonItem()
    
    
    let refreshControl = UIRefreshControl()
    
    var segmentCount = 0
    
    var timer:Timer!
    
    var image_Select = false
    
    var check:Bool = false
    
    var refreshCheck = false
    
    var next_100_check = false
    
    var count = 50
    var count2 = 50
    var count3 = 50
    var count4 = 50
    
    var check_Count = 0
    var check_Count2 = 0
    var totalCount = 0
    
    
    var post_Check = false
    
    var auto_Reload_Check = false
    
    
    @IBOutlet var profileImageView: UIImageView!
    
    
    @IBOutlet var bulletinBoard_Image: UIImageView!
    
    
    @IBOutlet var contributionLabel: UITextField!
    
    
    @IBOutlet var comment_BlurView: UIVisualEffectView!
    
    
    @IBOutlet var tableView: UITableView!
    
    
    @IBOutlet var reloadButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
       
        
        
        

        
            
        bulletinBoard_Image_Button = UIBarButtonItem(title: "背景", style: UIBarButtonItemStyle.plain, target: self, action:#selector(change_BulletinBoard_Image))
        
        
        self.navigationItem.rightBarButtonItem = bulletinBoard_Image_Button
        
        
        
        

        
        print("items----------------\(items)")
        
        
//        let nib = UINib(nibName: "BulletinBoardTableViewCell", bundle: nil)
//        tableView.register(nib, forCellReuseIdentifier: "Cell")
//        tableView.rowHeight = UITableViewAutomaticDimension
        
        let nib2 = UINib(nibName: "BulletinBoardTableViewCell2", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "Cell2")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        self.tableView.estimatedRowHeight = 298
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        
        //        reloadButton.layer.cornerRadius = reloadButton.frame.size.width/2
        //
        //
        //        reloadButton.clipsToBounds = true
        
        refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refreshControl.addTarget(self, action:#selector(refresh), for:UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    
    
    
    
    func refresh(){
        
        refreshCheck = true
        auto_Reload_Check = false
        
        switch segmentCount {
        case 0:
           if (check == false){
//            items = [BBS_PostData1]()
           
            reloadButton.isEnabled = false
            
                check = true
                loadAllData(segmentCount:0)
            
                    tableView.reloadData()
               refreshControl.endRefreshing()
            
            
            
            }
            SVProgressHUD.dismiss()
            break
        case 1:
            if (check == false){
//            items = [BBS_PostData1]()
          
            reloadButton.isEnabled = false
            
                check = true
                loadAllData(segmentCount:1)
              
                    tableView.reloadData()
                refreshControl.endRefreshing()
            }
            SVProgressHUD.dismiss()
            break
        case 2:
           if (check == false){
//            items = [BBS_PostData1]()
            
            reloadButton.isEnabled = false
            
                check = true
                loadAllData(segmentCount:2)
            
                    tableView.reloadData()
                refreshControl.endRefreshing()
                            }
            SVProgressHUD.dismiss()
            break
        case 3:
            if (check == false){
//            items = [BBS_PostData1]()
            
            reloadButton.isEnabled = false
            
                check = true
                loadAllData(segmentCount:3)
                
                    tableView.reloadData()
                
                    refreshControl.endRefreshing()
            }
            SVProgressHUD.dismiss()
            break
        default:
            break
        }
        refreshControl.endRefreshing()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        
        
//        let appDelegate2:AppDelegate = UIApplication.shared.delegate as! AppDelegate
//        if appDelegate2.navicheck == true{
//            self.tabBarController?.tabBar.isHidden = false
//           appDelegate2.navicheck = false
//        }
        
        switch segmentCount {
        case 0:
            self.title = "雑談"
        contributionLabel.placeholder = "雑談に投稿"
        
        case 1:
            self.title = "フレンドマッチ"
        contributionLabel.placeholder = "フレンドマッチに投稿"
       
        case 2:
            self.title = "質問"
        contributionLabel.placeholder = "質問に投稿"
        case 3:
            self.title = "チーム募集"
        contributionLabel.placeholder = "チーム募集に投稿"
        default:
            break
        }
        
        
        
        if (image_Select == true){
            SVProgressHUD.dismiss()
        }
        
        
        
        next_100_check = false
        
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        self.post_Check = appDelegate.post_Check
        
        
        if self.post_Check == true{
            tableView.contentOffset.y = (self.tableView.contentInset.top )
            post_Check = false
            
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.post_Check = self.post_Check
        }else{
            let table_point = tableView.contentOffset
            self.tableView.setContentOffset(CGPoint(x: table_point.x, y: table_point.y ), animated: false)

        }
        
        
        auto_Reload_Check = false
        
        //        if count == 150{
        //            count -= 100
        //        }
        
    
        if UserDefaults.standard.object(forKey: "profileImage") != nil{
            
            //エンコードして取り出す
            let decodeData = UserDefaults.standard.object(forKey: "profileImage")
            
            let decodedData = NSData(base64Encoded:decodeData as! String , options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            let decodedImage = UIImage(data:decodedData! as Data)
            profileImageView.image = decodedImage
        }else{
            profileImageView.image = UIImage(named:"No User.png")
        }

        profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
    
        
        if UserDefaults.standard.object(forKey: "bulletinBoard_Image") != nil{
            
            //エンコードして取り出す
            let decodeData = UserDefaults.standard.object(forKey: "bulletinBoard_Image")
            
            let decodedData = NSData(base64Encoded:decodeData as! String , options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            let decodedImage = UIImage(data:decodedData! as Data)
            bulletinBoard_Image.image = decodedImage
        }else{
            bulletinBoard_Image.image = UIImage(named:"asanoha-400px.png")
        }

    }
    
    


    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
       self.navigationController!.interactivePopGestureRecognizer!.isEnabled = false
        
    
        let navBarImage = UIImage(named: "navBarImage.png") as UIImage?
        self.navigationController?.navigationBar.setBackgroundImage(navBarImage,for:.default)
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        
        
        
        if (UserDefaults.standard.object(forKey: "ng_UserArayy")) != nil{
            ng_UserArayy = UserDefaults.standard.object(forKey: "ng_UserArayy") as! [String]
        }
        
        if (UserDefaults.standard.object(forKey: "ok_UserArayy")) != nil{
            ok_UserArayy = UserDefaults.standard.object(forKey: "ok_UserArayy") as! [String]
        }
        
        if (image_Select == true){
            image_Select = false
            SVProgressHUD.dismiss()
            self.tableView.isUserInteractionEnabled = true
            
        }
        else{
            //tableView.contentOffset.y = (self.tableView.contentInset.top )
            let table_point = tableView.contentOffset
            self.tableView.setContentOffset(CGPoint(x: table_point.x, y: table_point.y ), animated: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.loadAllData(segmentCount: self.segmentCount)
                
            }
        }
        
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }
    
    
    //画像のリサイズ
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
//        if segmentCount == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! BulletinBoardTableViewCell2
            
            
            
            cell.setPostData(BBS_PostData1: items[indexPath.row])
            
            
            
            //////////
            
            //ハイライトがされない
            cell.selectionStyle = .none
            
            
            
            let dict = items[(indexPath as NSIndexPath).row]
            
            
//            cell.backView.backgroundColor = UIColor(white:1.0,alpha:1.0)
            
            
            
            
            //プロフィール画像
            //デコードしたものを反映する
            let decodedImage = dict.profile_image
            
            
            //画像を丸くする。値が大きいほど丸くなる
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.height / 2
            cell.profileImageView.clipsToBounds = true
            cell.profileImageView.image = decodedImage
            
            //ユーザーネーム
            
            cell.userNameLabel.text = dict.name
            
            
            /* 非表示の部分とお気に入りの部分?
             
             if userNameLabel.text == "匿名"{
             tableView.rowHeight = 0
             }else{
             tableView.rowHeight = 356
             
             非表示ボタンと通報ボタンをアラートFirebaseに通報を保存
             非表示はUserDefaultsに配列として入れる
             
             
             }*/
            
            
            //投稿時間
        
        
        if ( dict.date != nil ) {
            
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss" //フォーマット合わせる
            if(formatter.date(from:dict.date!) != nil){
            print("ここ")
            print("\(dict.date)")
            print(formatter.date(from:dict.date!))
            
            let posTimeText:String = formatter.date(from:dict.date!)!.timeAgoSinceDate(numericDates: true)
            
                cell.time.text = posTimeText
            
            }
        }
            
            //コメント(本文)
            cell.commentLabel.text = dict.comment
            
            
            //投稿画像
            //デコードしたものを反映する
            
            
            cell.postedImageView.image = dict.image
            
            
            //プロフィール画像拡大
            cell.profileLinkButton.addTarget(self, action:#selector(profile_handleButton(sender:event:)), for:  UIControlEvents.touchUpInside)
            
            //画像拡大
            
            cell.likeButton.addTarget(self, action:#selector(handleButton(sender:event:)), for:  UIControlEvents.touchUpInside)
            
            
            //セルのコメント数
            cell.cell_Reply_Count.text = "\(dict.comment_num)"
            
            //ユーザーのNG登録
            cell.ngButton.addTarget(self, action:#selector(ngAction(sender:event:)), for: UIControlEvents.touchUpInside)
            
            
            //ユーザーのお気に入り登録
            cell.okButton.addTarget(self, action:#selector(okAction(sender:event:)), for: UIControlEvents.touchUpInside)
            
            
            if (cell.postedImageView.image) == nil{
                cell.postedImageView.isHidden = true
                cell.likeButton.isHidden = true
                cell.postedImage_height.constant = 0
                cell.likeButton_height.constant = 0
            }else{
                cell.postedImageView.isHidden = false
                cell.likeButton.isHidden = false
                cell.postedImage_height.constant = self.view.frame.size.height / 5
                cell.likeButton_height.constant = self.view.frame.size.height / 5
            }
//            
//            let userID = dict.userId
//            var ccc = 0
//            for user in self.ng_UserArayy {
//                
//                if (userID == user ) {
//                    cell.userNameLabel.text = "NG登録したユーザーです"
//                    cell.commentLabel.text = ""
//              cell.userNameLabel.numberOfLines = 1
//                                }

            
            
            
            
            
            return cell
            
            
//        }else{
//            
//            
//            
//            
//            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BulletinBoardTableViewCell
//            cell.setPostData(BBS_PostData1: items[indexPath.row])
//            
//            // cell.layoutIfNeeded()
//            
//            
//            
//            //ハイライトがされない
//            cell.selectionStyle = .none
//            
//            let dict = items[(indexPath as NSIndexPath).row]
//            
//            
//            cell.backView.backgroundColor = UIColor(white:0.97,alpha:1.0)
//            
//            
//            
//            
//            //プロフィール画像
//            //デコードしたものを反映する
//            let decodedImage = dict.profile_image
//            
//            
//            //画像を丸くする。値が大きいほど丸くなる
//            cell.profileImageView.layer.cornerRadius = 8.0
//            cell.profileImageView.clipsToBounds = true
//            cell.profileImageView.image = decodedImage
//            
//            //ユーザーネーム
//            
//            cell.userNameLabel.text = dict.name
//            
//            
//            
//            //投稿時間
//            let formatter = DateFormatter()
//            formatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale!
//            formatter.dateFormat = "MM-dd HH:mm"
//            
//            if ( dict.date != nil ) {
//                let dateString:String = dict.date!
//                cell.time.text = dateString
//            }
//            
//            //コメント(本文)
//            cell.commentLabel.text = dict.comment
//            
//            
//            //投稿画像
//            //デコードしたものを反映する
//            
//            
//            cell.postedImageView.image = dict.image
//            
//            
//            
//            //セルのカテゴリータイトル
//            
//            switch segmentCount {
//            case 0:
//                cell.cell_CategoryTitle.isHidden = true
//                cell.cell_CategoryTitle.text = ""
//                break
//            case 1:
//                cell.cell_CategoryTitle.isHidden = false
//                cell.cell_CategoryTitle.text = "ルームID"
//                
//                break
//            case 2:
//                cell.cell_CategoryTitle.isHidden = false
//                cell.cell_CategoryTitle.text = "フレンドID"
//                break
//            case 3:
//                cell.cell_CategoryTitle.isHidden = false
//                cell.cell_CategoryTitle.text = "チーム名"
//                break
//                
//            default:
//                break
//            }
//            
//            //セルのカテゴリー内容
//            if segmentCount == 0 {
//                cell.cell_CategoryContent.isHidden = true
//                cell.cell_CategoryContent.text = ""
//            }else{
//                cell.cell_CategoryContent.isHidden = false
//                cell.cell_CategoryContent.text = dict.category
//            }
//            
//            //プロフィール画像拡大
//            
//            cell.profileLinkButton.addTarget(self, action:#selector(profile_handleButton(sender:event:)), for:  UIControlEvents.touchUpInside)
//            
//            //画像拡大
//            
//            cell.likeButton.addTarget(self, action:#selector(handleButton(sender:event:)), for:  UIControlEvents.touchUpInside)
//            
//            
//            //セルのコメント数
//            cell.cell_Reply_Count.text = "\(dict.comment_num)"
//            
//            //ユーザーのNG登録
//            cell.ngButton.addTarget(self, action:#selector(ngAction(sender:event:)), for: UIControlEvents.touchUpInside)
//            
//            
//            //ユーザーのお気に入り登録
//            cell.okButton.addTarget(self, action:#selector(okAction(sender:event:)), for: UIControlEvents.touchUpInside)
//            
//            
//            if (cell.postedImageView.image) == nil{
//                cell.postedImageView.isHidden = true
//                cell.likeButton.isHidden = true
//                cell.postedImage_height.constant = 0
//                cell.likeButton_height.constant = 0
//            }else{
//                cell.postedImageView.isHidden = false
//                cell.likeButton.isHidden = false
//                cell.postedImage_height.constant = self.view.frame.size.height / 5
//                cell.likeButton_height.constant = self.view.frame.size.height / 5
//            }
//            
//            
//            return cell
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dict = items[indexPath.row] as BBS_PostData1
        
        
        self.tabBarController?.tabBar.isHidden = true

        
        image_Select = true
        performSegue(withIdentifier: "nextComment", sender: dict)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    
    
    //データを取ってくるメソッド
    func loadAllData(segmentCount:Int){ // 雑談掲示板
        
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if ( segmentCount == 0 ) {
            SVProgressHUD.show()
//            segmentButton.isEnabled = false
            self.tableView.isUserInteractionEnabled = false
            self.comment_BlurView.isHidden = false
            //タッチ無効
            
            let firebase = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "0")
            firebase.queryLimited(toLast: UInt(Int(count))).observe(.value) { (snapshot,error) in
                
                
                if self.auto_Reload_Check == true{
                    SVProgressHUD.dismiss()
//                    self.segmentButton.isEnabled = true
                    self.tableView.isUserInteractionEnabled = true
                    self.comment_BlurView.isHidden = true
                     self.refreshControl.endRefreshing()
                    return
                }
                
                
                self.auto_Reload_Check = true
                
               
                if self.segmentCount != 0{
                    SVProgressHUD.dismiss()
//                    self.segmentButton.isEnabled = true
                    self.tableView.isUserInteractionEnabled = true
                    self.comment_BlurView.isHidden = true
                     self.refreshControl.endRefreshing()
                    return
                }
                
                self.items = [BBS_PostData1]()
                
                
                
                for item in(snapshot.children){
                    let child = item as! FIRDataSnapshot
                    let postData = BBS_PostData1(snapshot: child, myId: "")
                    
                    var ng_flg = false
                    
                    for user in self.ng_UserArayy {
                        print("check --> \(user)")
                        print("c --> \(self.ng_UserArayy)")
                        if ( postData.userId == user ) {
                            ng_flg = true
                            self.check_Count += 1
                            self.totalCount += 1
                            print("      --> NG \(ng_flg)")
                        }
                        else {
                            self.check_Count2 += 1
                            self.totalCount += 1
                            print("      --> OK \(ng_flg)")
                        }
                    }
                    
                    if ( !ng_flg ) {  //次回質問
                        self.items.append(postData)
                    }
                }
                
                
                if self.check_Count > 26 && self.count == 50{
                    
                        self.count = 100
                    
                    if (self.check == false){
                        self.check = true
                     self.auto_Reload_Check = false
                        self.check_Count = 0
                        self.check_Count2 = 0
                        self.totalCount = 0
                         self.refreshControl.endRefreshing()
                        self.loadAllData(segmentCount:segmentCount)
                        
                        return
                    }
                
                    }
                
                    
            
                if self.check_Count + self.check_Count2 != self.totalCount{
                    
                    if self.count == 50{
                        self.count = 50
                    
                    }else if self.count == 100{
                        self.count = 100
                    
                    }
                    
                    
                    self.auto_Reload_Check = false
                        if (self.check == false){
                            self.check = true
                            self.check_Count = 0
                            self.check_Count2 = 0
                            self.totalCount = 0
                             self.refreshControl.endRefreshing()
                            self.loadAllData(segmentCount:segmentCount)
                            
                            print("リターン------")
                            return
                            
                        }
                        }
                
                
                self.items.reverse()
//                let CGPoint2 = self.tableView.contentOffset
//                
//                self.tableView.setContentOffset(CGPoint(x: CGPoint2.x, y: CGPoint2.y ), animated: false)
//               
//                if (self.refreshCheck == false){
//                self.tableView.contentOffset.y = (self.tableView.contentInset.top )
//                }
//                self.tableView.reloadData()
                
                
                //タイマー広告
                print(self.count)
                self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.time), userInfo: nil, repeats: false)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        else if ( segmentCount == 1 ) {
            SVProgressHUD.show()
//            segmentButton.isEnabled = false
            self.tableView.isUserInteractionEnabled = false //タッチ無効
            self.comment_BlurView.isHidden = false
            
            let firebase = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "1")
            firebase.queryLimited(toLast: UInt(Int(count2))).observe(.value) { (snapshot,error) in
                
                
                if self.auto_Reload_Check == true{
                    SVProgressHUD.dismiss()
//                    self.segmentButton.isEnabled = true
                    self.tableView.isUserInteractionEnabled = true
                    self.comment_BlurView.isHidden = true
                     self.refreshControl.endRefreshing()
                    return
                }
                
                
                self.auto_Reload_Check = true
                
                
                if self.segmentCount != 1{
                    SVProgressHUD.dismiss()
//                    self.segmentButton.isEnabled = true
                    self.tableView.isUserInteractionEnabled = true
                    self.comment_BlurView.isHidden = true
                     self.refreshControl.endRefreshing()
                    return
                }
                
                self.items = [BBS_PostData1]()
                
                for item in(snapshot.children){
                    let child = item as! FIRDataSnapshot
                    let postData = BBS_PostData1(snapshot: child, myId: "")
                    
                    var ng_flg = false
                    
                    for user in self.ng_UserArayy {
                        print("check --> \(user)")
                        print("c --> \(self.ng_UserArayy)")
                        if ( postData.userId == user ) {
                            ng_flg = true
                            self.check_Count += 1
                            self.totalCount += 1
                            print("      --> NG \(ng_flg)")
                        }
                        else {
                            self.check_Count2 += 1
                            self.totalCount += 1
                            print("      --> OK \(ng_flg)")
                        }
                    }
                    
                    if ( !ng_flg ) {  //次回質問
                        self.items.append(postData)
                    }
                }
                
                
                if self.check_Count > 26 && self.count2 == 50{
                    
                    self.count2 = 100
                    
                    if (self.check == false){
                        self.check = true
                        self.auto_Reload_Check = false
                        self.check_Count = 0
                        self.check_Count2 = 0
                        self.totalCount = 0
                         self.refreshControl.endRefreshing()
                        self.loadAllData(segmentCount:segmentCount)
                        
                        return
                    }
                    
                }
                
                
                
                if self.check_Count + self.check_Count2 != self.totalCount{
                    
                    if self.count2 == 50{
                        self.count2 = 50
                        
                    }else if self.count2 == 100{
                        self.count2 = 100
                        
                    }
                    
                    
                    self.auto_Reload_Check = false
                    if (self.check == false){
                        self.check = true
                        self.check_Count = 0
                        self.check_Count2 = 0
                        self.totalCount = 0
                         self.refreshControl.endRefreshing()
                        self.loadAllData(segmentCount:segmentCount)
                        
                        print("リターン------")
                        return
                        
                    }
                }
                
                self.items.reverse()
//                let CGPoint2 = self.tableView.contentOffset
//                
//                self.tableView.setContentOffset(CGPoint(x: CGPoint2.x, y: CGPoint2.y ), animated: false)
//                if (self.refreshCheck == false){
//                    self.tableView.contentOffset.y = (self.tableView.contentInset.top )
//                }
//                self.tableView.reloadData()
                
                
                print(self.count2)
                self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.time), userInfo: nil, repeats: false)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }else if ( segmentCount == 2 ) {
            SVProgressHUD.show()
//            segmentButton.isEnabled = false
            self.tableView.isUserInteractionEnabled = false //タッチ無効
            self.comment_BlurView.isHidden = false
            
            let firebase = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "2")
            firebase.queryLimited(toLast: UInt(Int(count3))).observe(.value) { (snapshot,error) in
                
                
                if self.auto_Reload_Check == true{
                    SVProgressHUD.dismiss()
//                    self.segmentButton.isEnabled = true
                    self.tableView.isUserInteractionEnabled = true
                    self.comment_BlurView.isHidden = true
                     self.refreshControl.endRefreshing()
                    return
                }
                
                
                self.auto_Reload_Check = true
                
                
                if self.segmentCount != 2{
                    SVProgressHUD.dismiss()
//                    self.segmentButton.isEnabled = true
                    self.tableView.isUserInteractionEnabled = true
                    self.comment_BlurView.isHidden = true
                     self.refreshControl.endRefreshing()
                    return
                }
                
                self.items = [BBS_PostData1]()
                
                for item in(snapshot.children){
                    let child = item as! FIRDataSnapshot
                    let postData = BBS_PostData1(snapshot: child, myId: "")
                    
                    var ng_flg = false
                    
                    for user in self.ng_UserArayy {
                        print("check --> \(user)")
                        print("c --> \(self.ng_UserArayy)")
                        if ( postData.userId == user ) {
                            ng_flg = true
                            self.check_Count += 1
                            self.totalCount += 1
                            print("      --> NG \(ng_flg)")
                        }
                        else {
                            self.check_Count2 += 1
                            self.totalCount += 1
                            print("      --> OK \(ng_flg)")
                        }
                    }
                    
                    if ( !ng_flg ) {  //次回質問
                        self.items.append(postData)
                    }
                }
                
                
                if self.check_Count > 26 && self.count3 == 50{
                    
                    self.count3 = 100
                    
                    if (self.check == false){
                        self.check = true
                        self.auto_Reload_Check = false
                        self.check_Count = 0
                        self.check_Count2 = 0
                        self.totalCount = 0
                         self.refreshControl.endRefreshing()
                        self.loadAllData(segmentCount:segmentCount)
                        
                        return
                    }
                    
                }
                
                
                
                if self.check_Count + self.check_Count2 != self.totalCount{
                    
                    if self.count3 == 50{
                        self.count3 = 50
                        
                    }else if self.count3 == 100{
                        self.count3 = 100
                        
                    }
                    
                    
                    self.auto_Reload_Check = false
                    if (self.check == false){
                        self.check = true
                        self.check_Count = 0
                        self.check_Count2 = 0
                        self.totalCount = 0
                         self.refreshControl.endRefreshing()
                        self.loadAllData(segmentCount:segmentCount)
                        
                        print("リターン------")
                        return
                        
                    }
                }
                
                self.items.reverse()
//                let CGPoint2 = self.tableView.contentOffset
//                
//                self.tableView.setContentOffset(CGPoint(x: CGPoint2.x, y: CGPoint2.y ), animated: false)
//                if (self.refreshCheck == false){
//                    self.tableView.contentOffset.y = (self.tableView.contentInset.top )
//                }
//                self.tableView.reloadData()
                
                print(self.count3)
                self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.time), userInfo: nil, repeats: false)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }else if ( segmentCount == 3 ) {
            SVProgressHUD.show()
//            segmentButton.isEnabled = false
            self.tableView.isUserInteractionEnabled = false //タッチ無効
            self.comment_BlurView.isHidden = false
            
            let firebase = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "3")
            
            
            firebase.queryLimited(toLast: UInt(Int(count4))).observe(.value) { (snapshot,error) in
                
                
                if self.auto_Reload_Check == true{
                    SVProgressHUD.dismiss()
//                    self.segmentButton.isEnabled = true
                    self.tableView.isUserInteractionEnabled = true
                    self.comment_BlurView.isHidden = true
                     self.refreshControl.endRefreshing()
                    return
                }
                
                
                self.auto_Reload_Check = true
                
                
                if self.segmentCount != 3{
                    SVProgressHUD.dismiss()
//                    self.segmentButton.isEnabled = true
                    self.tableView.isUserInteractionEnabled = true
                    self.comment_BlurView.isHidden = true
                     self.refreshControl.endRefreshing()
                    return
                }
                
                self.items = [BBS_PostData1]()
                
                
                for item in(snapshot.children){
                    let child = item as! FIRDataSnapshot
                    let postData = BBS_PostData1(snapshot: child, myId: "")
                    
                    var ng_flg = false
                    
                    for user in self.ng_UserArayy {
                        print("check --> \(user)")
                        print("c --> \(self.ng_UserArayy)")
                        if ( postData.userId == user ) {
                            ng_flg = true
                            self.check_Count += 1
                            self.totalCount += 1
                            print("      --> NG \(ng_flg)")
                        }
                        else {
                            self.check_Count2 += 1
                            self.totalCount += 1
                            print("      --> OK \(ng_flg)")
                        }
                    }
                    
                    if ( !ng_flg ) {  //次回質問
                        self.items.append(postData)
                    }
                }
                
                
                if self.check_Count > 26 && self.count4 == 50{
                    
                    self.count4 = 100
                    
                    if (self.check == false){
                        self.check = true
                        self.auto_Reload_Check = false
                        self.check_Count = 0
                        self.check_Count2 = 0
                        self.totalCount = 0
                         self.refreshControl.endRefreshing()
                        self.loadAllData(segmentCount:segmentCount)
                        
                        return
                    }
                    
                }
                
                
                
                if self.check_Count + self.check_Count2 != self.totalCount{
                    
                    if self.count4 == 50{
                        self.count4 = 50
                        
                    }else if self.count4 == 100{
                        self.count4 = 100
                        
                    }
                    
                    
                    self.auto_Reload_Check = false
                    if (self.check == false){
                        self.check = true
                        self.check_Count = 0
                        self.check_Count2 = 0
                        self.totalCount = 0
                        self.refreshControl.endRefreshing()
                        self.loadAllData(segmentCount:segmentCount)
                        
                        print("リターン------")
                        return
                        
                    }
                }
                
                
                self.items.reverse()
//                let CGPoint2 = self.tableView.contentOffset
//                
//                self.tableView.setContentOffset(CGPoint(x: CGPoint2.x, y: CGPoint2.y ), animated: false)
//                if (self.refreshCheck == false){
//                    self.tableView.contentOffset.y = (self.tableView.contentInset.top )
//                }
//                self.tableView.reloadData()
                
                print(self.count4)
                self.timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(self.time), userInfo: nil, repeats: false)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        
    }
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("スクロールスタート")
        reloadButton.isEnabled = false
        reloadButton.alpha = 0.3
        tableView.allowsSelection = false
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        ////////
        
//        reloadButton.isEnabled = false
//        reloadButton.alpha = 0.3
//        tableView.allowsSelection = false
        print("スクロール中")
        
        
        //最下部にスクロールしても、print("スクロール中")が表示されるため⇩
        
        if   tableView.contentOffset.y == (self.tableView.contentInset.top ) {
            print("スクロール解除")
            reloadButton.isEnabled = true
            reloadButton.alpha = 1.0
            tableView.allowsSelection = true
        }
        
//        if tableView.contentOffset.y == (self.tableView.contentSize.height - self.tableView.frame.size.height ){
//            
//            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.next_100_check = true
//            }
//
//            
//            if (next_100_check == true){
//            self.next_100_check = false
//            
//                if (self.count != 150){
//                
//                let CGPoint2 = tableView.contentOffset
//                self.tableView.setContentOffset(CGPoint(x: CGPoint2.x, y: CGPoint2.y ), animated: false)
//                
//                
//            if (self.check == false){
//                self.check = true
//                if self.count == 50{
//                    self.count = 150
//                
//                 self.tableView.contentOffset.y = (self.tableView.contentSize.height - self.tableView.frame.size.height )
//                self.auto_Reload_Check = false
//               
//                self.loadAllData(segmentCount: self.segmentCount)
//                
//                }
//                
//                print("aaaaaaaaaaaaaaaaaaaaaaaaa")
//                return
//                    }
//                    
//                    
//                }
//            }
//        }
    }
 
                
    
                    
            
            
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,willDecelerate decelerate: Bool){
        print("スクロールで指が離れたところ")
        reloadButton.isEnabled = true
        reloadButton.alpha = 1.0
        tableView.allowsSelection = true
        
    }
    
    func time(){
        //top == 実機で右のスクロールが動いてない時
        
        
        //var CGPoint2 = tableView.contentOffset
        //self.tableView.setContentOffset(CGPoint(x: CGPoint2.x, y: CGPoint2.y ), animated: false)
        //if t_check == false{
        //self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentInset.top ), animated: false)
        
        //}
        if (segmentCount == 0){
        if self.check_Count + self.check_Count2 != self.totalCount{
            
            if self.count == 50{
                self.count = 50
                
            }else if self.count == 100{
                self.count = 100
                
            }
            
            
            self.auto_Reload_Check = false
            if (self.check == false){
                self.check = true
                self.check_Count = 0
                self.check_Count2 = 0
                self.totalCount = 0
                 self.refreshControl.endRefreshing()
                self.loadAllData(segmentCount:segmentCount)
                
                print("リターン------")
                return
                
            }
        }
        }else if (segmentCount == 1){
            if self.check_Count + self.check_Count2 != self.totalCount{
                
                if self.count2 == 50{
                    self.count2 = 50
                    
                }else if self.count2 == 100{
                    self.count2 = 100
                    
                }
                
                
                self.auto_Reload_Check = false
                if (self.check == false){
                    self.check = true
                    self.check_Count = 0
                    self.check_Count2 = 0
                    self.totalCount = 0
                     self.refreshControl.endRefreshing()
                    self.loadAllData(segmentCount:segmentCount)
                    
                    print("リターン------")
                    return
                    
                }
            }

        }else if (segmentCount == 2){
            if self.check_Count + self.check_Count2 != self.totalCount{
                
                if self.count3 == 50{
                    self.count3 = 50
                    
                }else if self.count3 == 100{
                    self.count3 = 100
                    
                }
                
                
                self.auto_Reload_Check = false
                if (self.check == false){
                    self.check = true
                    self.check_Count = 0
                    self.check_Count2 = 0
                    self.totalCount = 0
                    self.refreshControl.endRefreshing()
                    self.loadAllData(segmentCount:segmentCount)
                    
                    print("リターン------")
                    return
                    
                }
            }
        }else if (segmentCount == 3){
            if self.check_Count + self.check_Count2 != self.totalCount{
                
                if self.count4 == 50{
                    self.count4 = 50
                    
                }else if self.count4 == 100{
                    self.count4 = 100
                    
                }
                
                
                self.auto_Reload_Check = false
                if (self.check == false){
                    self.check = true
                    self.check_Count = 0
                    self.check_Count2 = 0
                    self.totalCount = 0
                    
                    self.loadAllData(segmentCount:segmentCount)
                    
                    print("リターン------")
                    return
                    
                }
            }
        }
//        self.segmentButton.isEnabled = true
        tableView.allowsSelection = true
        self.view.isUserInteractionEnabled = true
        self.comment_BlurView.isHidden = true
        
        
        SVProgressHUD.dismiss()
        self.timer.invalidate()
        check = false
        self.tableView.isUserInteractionEnabled = true
        if (reloadButton.isEnabled == false){
            
            reloadButton.isEnabled = true
       reloadButton.alpha = 1.0
        }
        
        
        
        
        print("bbbbbbbbbbbbb")
        print(auto_Reload_Check)
        print(check)
        refreshControl.endRefreshing()
        
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
            let CGPoint2 = self.tableView.contentOffset
            self.tableView.setContentOffset(CGPoint(x: CGPoint2.x, y: CGPoint2.y ), animated: false)
            
            if (self.refreshCheck == false){
                self.tableView.contentOffset.y = (self.tableView.contentInset.top )
                self.refreshCheck = true
            }

        }
   
    }
    
    
    
    
    
//    @IBAction func segmentButton(_ sender: UISegmentedControl) {
//        switch sender.selectedSegmentIndex {
//            
//            
//            
//        case 0:
//            
//            tableView.contentOffset.y = (self.tableView.contentInset.top )
//            
//            segmentCount = 0
//            auto_Reload_Check = false
//            loadAllData(segmentCount:0)
////            categoryLabel.text = "雑談"
//            contributionLabel.placeholder = "雑談に投稿"
//            tableView.reloadData()
//            break
//        case 1:
//            tableView.contentOffset.y = (self.tableView.contentInset.top )
//            count = 50
//            segmentCount = 1
//            auto_Reload_Check = false
//            loadAllData(segmentCount:1)
//            
////            categoryLabel.text = "マルチ募集"
//            contributionLabel.placeholder = "マルチ募集に投稿"
//            tableView.reloadData()
//            
//            break
//        case 2:
//            tableView.contentOffset.y = (self.tableView.contentInset.top )
//            count = 50
//            segmentCount = 2
//            auto_Reload_Check = false
//            loadAllData(segmentCount:2)
////            categoryLabel.text = "フレンド募集"
//            contributionLabel.placeholder = "フレンド募集に投稿"
//            tableView.reloadData()
//            
//            break
//        case 3:
//            tableView.contentOffset.y = (self.tableView.contentInset.top )
//            count = 50
//            segmentCount = 3
//            auto_Reload_Check = false
//            loadAllData(segmentCount:3)
//            
////            categoryLabel.text = "チーム募集"
//            contributionLabel.placeholder = "チーム募集に投稿"
//            tableView.reloadData()
//            
//            break
//            
//        default:
//            break
//        }
//        
//        
//        
//    }
    
    //更新ちゅう
    
    
    
    
    @IBAction func contributionButton(_ sender: Any) {
        
        if UserDefaults.standard.object(forKey: "userName") == nil{
            let alertViewControler = UIAlertController(title: "掲示板の書き込みには プロフィール登録が必要です", message: "「ホーム」 ➡︎　「プロフィールを変更」よりプロフィール登録を行ってください",preferredStyle:.alert)
            let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertViewControler.addAction(cancelAction)
            present(alertViewControler, animated: true, completion: nil)
            
            
        }else{

            image_Select = true
            let CGPoint2 = tableView.contentOffset
            self.tableView.setContentOffset(CGPoint(x: CGPoint2.x, y: CGPoint2.y ), animated: false)
            self.tableView.isUserInteractionEnabled = false
            
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.navicheck = true
            
            performSegue(withIdentifier:"post",sender:nil)
        }
    }
    @IBAction func reloadButton(_ sender: Any) {
        
        auto_Reload_Check = false
        
        switch segmentCount {
        case 0:
//            tableView.contentOffset.y = (self.tableView.contentInset.top )
//            items = [BBS_PostData1]()
           
            reloadButton.isEnabled = false
            if (check == false){
                check = true
                
                //ポイントを求めてからトップへ
                let CGPoint2 = self.tableView.contentOffset
                
                self.tableView.setContentOffset(CGPoint(x: CGPoint2.x, y: CGPoint2.y ), animated: false)
                tableView.contentOffset.y = (self.tableView.contentInset.top )
                loadAllData(segmentCount:0)
                
//                tableView.reloadData()
                
                
            }
            break
        case 1:
            
//            tableView.contentOffset.y = (self.tableView.contentInset.top )
//            items = [BBS_PostData1]()
           
            reloadButton.isEnabled = false
            if (check == false){
                check = true
                let CGPoint2 = self.tableView.contentOffset
                
                self.tableView.setContentOffset(CGPoint(x: CGPoint2.x, y: CGPoint2.y ), animated: false)
               tableView.contentOffset.y = (self.tableView.contentInset.top )
                loadAllData(segmentCount:1)
//                  tableView.reloadData()
               
                
                
            }
            break
        case 2:
            
//            tableView.contentOffset.y = (self.tableView.contentInset.top )
//            items = [BBS_PostData1]()
           
            reloadButton.isEnabled = false
            if (check == false){
                check = true
                let CGPoint2 = self.tableView.contentOffset
                
                self.tableView.setContentOffset(CGPoint(x: CGPoint2.x, y: CGPoint2.y ), animated: false)
                tableView.contentOffset.y = (self.tableView.contentInset.top )
                loadAllData(segmentCount:2)
//                tableView.reloadData()
//                
            }
            
            break
        case 3:
            
//            tableView.contentOffset.y = (self.tableView.contentInset.top )
//            items = [BBS_PostData1]()
            
            reloadButton.isEnabled = false
            if (check == false){
                check = true
                let CGPoint2 = self.tableView.contentOffset
                
                self.tableView.setContentOffset(CGPoint(x: CGPoint2.x, y: CGPoint2.y ), animated: false)
               tableView.contentOffset.y = (self.tableView.contentInset.top )
                loadAllData(segmentCount:3)
               
//            tableView.reloadData()
               
                
            }
            
            break
        default:
            break
        }
        
    }
    
    func handleButton(sender: UIButton, event:UIEvent) {
        image_Select = true
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        // 投稿の画面を開く
        let cellImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "nextimg") as! CellImageViewController
        let dict = items[(indexPath! as NSIndexPath).row]
        //投稿画像
        cellImageViewController.img.image = dict.image
        present(cellImageViewController, animated: true, completion: nil)
    }
    
    func profile_handleButton(sender: UIButton, event:UIEvent){
        image_Select = true
        let touch = event.allTouches?.first
        let point = touch!.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        // 投稿の画面を開く
        let cellImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "nextimg") as! CellImageViewController
        let dict = items[(indexPath! as NSIndexPath).row]
        //投稿画像
        cellImageViewController.img.image = dict.profile_image
        present(cellImageViewController, animated: true, completion: nil)
    }
    
    func ngAlert(ngUser:String){
        
        
        
        let alertViewControler = UIAlertController(title:"このユーザーを非表示\nにしますか？", message: "非表示登録したユーザーは今後、掲示板に表示されません", preferredStyle:.alert)
        
        let okAction = UIAlertAction(title: "非表示にする", style: .default, handler: {
            (action:UIAlertAction!) -> Void in
            self.addngAction(ngUser: ngUser)
        })
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alertViewControler.addAction(okAction)
        alertViewControler.addAction(cancelAction)
        
        present(alertViewControler, animated: true, completion: nil)
        
    }
    
    func ngAction(sender: UIButton, event:UIEvent){
        
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        
        let ngUser = items[(indexPath?.row)!].userId
        print("ngUser ------------->  \(ngUser)")
        
        
        if  (UserDefaults.standard.object(forKey: "userId")) != nil{
            let user:String = (UserDefaults.standard.object(forKey: "userId") as! String)
            if user == ngUser{
                SVProgressHUD.showError(withStatus: "自身は非表示に\nできません")
                return
            }
        }
        
        
        ngAlert(ngUser:ngUser)
        
        
    }
    
    func addngAction(ngUser:String){
        
        
        ng_UserArayy.append(ngUser)
        UserDefaults.standard.set(ng_UserArayy, forKey: "ng_UserArayy")
        
        
        auto_Reload_Check = false

        
        loadAllData(segmentCount:segmentCount)
        
        self.tableView.reloadData()
        
        
    }
    
    
    func okAlert(okUser:String){
        
        
        
        let alertViewControler = UIAlertController(title:"このユーザーをお気に\n入り登録しますか？", message: "お気に入り登録をすることで「ホーム」→「お気に入りユーザー」より登録したユーザーの書き込みのみが表示可能となります", preferredStyle:.alert)
        
        let okAction = UIAlertAction(title: "お気に入りに登録する", style: .default, handler: {
            (action:UIAlertAction!) -> Void in
            self.addokAction(okUser: okUser)
        })
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alertViewControler.addAction(okAction)
        alertViewControler.addAction(cancelAction)
        
        present(alertViewControler, animated: true, completion: nil)
        
    }
    
    
    func okAction(sender: UIButton, event:UIEvent){
        
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let okUser = items[(indexPath?.row)!].userId
        
        print("okUser ------------->  \(okUser)")
        
        if  (UserDefaults.standard.object(forKey: "ok_UserArayy")) != nil{
            let userArayy:[String] = UserDefaults.standard.object(forKey: "ok_UserArayy") as! [String]
            for i in userArayy{
                if i == okUser{
                    SVProgressHUD.showError(withStatus: "このユーザーはお気に入りに登録済みです")
                    return
                    
                }
            }
        }
        
        okAlert(okUser:okUser)
        
        
        
        print("okUser  --> \(okUser)")
    }
    
    func addokAction(okUser:String){
        
        
        ok_UserArayy.append(okUser)
        UserDefaults.standard.set(ok_UserArayy, forKey: "ok_UserArayy")
        
        SVProgressHUD.showSuccess(withStatus: "お気に入りに\n登録しました")
        
        
        print("ok_UserArayy  --> \(ok_UserArayy)")
        
    }
    
    //お気に入りの投稿
    
    func favoriteAlert(favorite_Post:String){
        
        
        
        let alertViewControler = UIAlertController(title:"この投稿をお気に入り登録しますか？", message: "お気に入り登録をすることで「ホーム」→「お気に入りの投稿」より登録した書き込みが表示可能となります", preferredStyle:.alert)
        
        let okAction = UIAlertAction(title: "お気に入りに登録する", style: .default, handler: {
            (action:UIAlertAction!) -> Void in
            self.addfavoriteAction(favorite_Post:favorite_Post)
        })
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alertViewControler.addAction(okAction)
        alertViewControler.addAction(cancelAction)
        
        present(alertViewControler, animated: true, completion: nil)
        
    }
    
    
    
    
    func favoriteAction(sender: UIButton, event:UIEvent){
        
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let favorite_Post = items[(indexPath?.row)!].id
        
        
        if  (UserDefaults.standard.object(forKey: "favorite_Post_Arayy")) != nil{
            let favorite_Post_Arayy2 = UserDefaults.standard.object(forKey: "favorite_Post_Arayy") as! [String]
            
            var favoritecheck = false
            
            for i in favorite_Post_Arayy2 {
                if ( i == favorite_Post ) {
                    favoritecheck = true
                }
            }
            
            if ( favoritecheck == true ) {
                SVProgressHUD.showError(withStatus: "この投稿はお気に入りに登録済みです")
                return
            }
            else {
                print("favorite_Post  --> \(favorite_Post)")

                favoriteAlert(favorite_Post:favorite_Post)
            }
            
        
        }
    }
    
    
    func addfavoriteAction(favorite_Post:String){
        
        
        favorite_Post_Arayy.append(favorite_Post)
        UserDefaults.standard.set(favorite_Post_Arayy, forKey: "favorite_Post_Arayy")
        
        //入らない
        
        SVProgressHUD.showSuccess(withStatus: "お気に入りに\n登録しました")
        
        
        
    }
    
    
    func change_BulletinBoard_Image() {
        let alertViewControler = UIAlertController(title: "掲示板の背景画像を設定", message: "", preferredStyle:.actionSheet)
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
        
        
        
        let defaultAction = UIAlertAction(title: "デフォルト", style: .default, handler:{
            (action:UIAlertAction!) -> Void in
            
            if UserDefaults.standard.object(forKey:"bulletinBoard_Image") != nil{
                UserDefaults.standard.removeObject(forKey: "bulletinBoard_Image")
                self.bulletinBoard_Image.image = UIImage(named:"asanoha-400px.png")
            }
        })
        
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        
        alertViewControler.addAction(cameraAction)
        alertViewControler.addAction(photosAction)
        alertViewControler.addAction(defaultAction)
        
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
            bulletinBoard_Image.image = pickedImage

            var data: NSData = NSData()
            
            if let image = bulletinBoard_Image.image{
                
                data = UIImageJPEGRepresentation(image, 0.1)! as NSData
                let base64String = data.base64EncodedString(options:
                    NSData.Base64EncodingOptions.lineLength64Characters
                    ) as String
                UserDefaults.standard.set(base64String,forKey:"bulletinBoard_Image")
                
            }

        
        }
        
        
        //カメラ画面(アルバム画面)を閉じる処理
        picker.dismiss(animated: true, completion: nil)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "nextComment"){
            let comment_ViewController:Comment_ViewController = segue.destination as! Comment_ViewController
            comment_ViewController.postData = sender as! BBS_PostData1
        }else if(segue.identifier == "post"){
            let postViewController:PostViewController = segue.destination as! PostViewController
            
            if(segmentCount == 0){
               postViewController.postSelect = 0
            }else if(segmentCount == 1){
                postViewController.postSelect = 1
            }else if(segmentCount == 2){
                postViewController.postSelect = 2
            }else if(segmentCount == 3){
                postViewController.postSelect = 3
            }
    }
}
}
