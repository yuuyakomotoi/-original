//
//  Comment_ViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/08/06.
//  Copyright © 2017年 小本裕也. All rights reserved.
//


import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class Comment_ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    var postData:BBS_PostData1!
    
    
    var image_Select = false
    
    
    
    var ng_UserArayy:[String] = []
    
    var commentArray:[BBS_PostData1] = []
    
    var timer = Timer()
    
    var check:Bool = false
    
    var timerCount = 0
    
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var profileImageView: UIImageView!
    
    @IBOutlet var bulletinBoard_Image: UIImageView!
    
    
    
    
    @IBOutlet var comment_BlurView: UIVisualEffectView!

    @IBOutlet var reloadButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
        let nib2 = UINib(nibName: "BulletinBoardTableViewCell2", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "Cell2")
        tableView.rowHeight = UITableViewAutomaticDimension
        
       tableView.delegate = self
    tableView.dataSource = self
        
        
        self.tableView.estimatedRowHeight = 298
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
            }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
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

        
       
        if (UserDefaults.standard.object(forKey: "ng_UserArayy")) != nil{
            ng_UserArayy = UserDefaults.standard.object(forKey: "ng_UserArayy") as! [String]
        }
    
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadAllData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }else{
            return commentArray.count
        }

        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        if indexPath.section == 0 {
        
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! BulletinBoardTableViewCell2
            
            cell.selectionStyle = .none
        
            //プロフィール画像
            //デコードしたものを反映する
            let decodedImage = postData.profile_image
            
            //画像を丸くする。値が大きいほど丸くなる
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.height / 2
            cell.profileImageView.clipsToBounds = true
            cell.profileImageView.image = decodedImage
            
            //ユーザーネーム
            cell.userNameLabel.text = postData.name
            
            //投稿時間
            let formatter = DateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale!
            formatter.dateFormat = "MM-dd HH:mm"
            
            if ( postData.date != nil ) {
                let dateString:String = postData.date!
                
                cell.time.text = dateString
            }
            
            //コメント(本文)
            cell.commentLabel.text = postData.comment
            
            //投稿画像
            
            cell.postedImageView.image = postData.image
            
        
            //プロフィール画像拡大
            cell.profileLinkButton.addTarget(self, action:#selector(profile_handleButton(sender:event:)), for:  UIControlEvents.touchUpInside)
            
          
            //画像拡大
            cell.likeButton.addTarget(self, action:#selector(handleButton(sender:event:)), for:  UIControlEvents.touchUpInside)
            
            //セルのコメント数
            cell.cell_Reply_Count.text = "\(postData.comment_num)"
            
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
            
            //ユーザーのNG登録
            cell.ngButton.isHidden = true
//            
//            //ユーザーのお気に入り登録
//            cell.okButton.addTarget(self, action:#selector(okAction(sender:event:)), for: UIControlEvents.touchUpInside)
            
            
            return cell
        }else{

            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! BulletinBoardTableViewCell2
            
            cell.selectionStyle = .none
            
            let dict = commentArray[indexPath.row]
            
            //プロフィール画像
            //画像を丸くする。値が大きいほど丸くなる
            let decodedImage = dict.profile_image
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.height / 2
            cell.profileImageView.clipsToBounds = true
            cell.profileImageView.image = decodedImage
            
            //ユーザーネーム
            cell.userNameLabel.text = dict.name
            
            //投稿時間
            
            let formatter = DateFormatter()
            formatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale!
            formatter.dateFormat = "MM-dd HH:mm"
            
            if ( dict.date != nil ) {
                let dateString:String = dict.date!
                cell.time.text = dateString
            }
            
            //コメント(本文)
            cell.commentLabel.text = dict.comment
            
            
            //投稿画像
            cell.postedImageView.image = dict.image
            
            //プロフィール画像拡大
            cell.profileLinkButton.addTarget(self, action:#selector(profile_handleButton2(sender:event:)), for:  UIControlEvents.touchUpInside)
            
            //画像拡大
            cell.likeButton.addTarget(self, action:#selector(handleButton2(sender:event:)), for:  UIControlEvents.touchUpInside)
            
            
            cell.cell_Reply_Count.isHidden = true
            cell.replyLabel.isHidden = true
            
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
            
            //ユーザーのNG登録
            cell.ngButton.addTarget(self, action:#selector(ngAction2(sender:event:)), for: UIControlEvents.touchUpInside)
//

            cell.okButton.isHidden = true
            //            //ユーザーのお気に入り登録
//            cell.okButton.addTarget(self, action:#selector(okAction2(sender:event:)), for: UIControlEvents.touchUpInside)
            
            return cell
        }
    }


    
    func loadAllData(){ // 雑談掲示板
        
        self.commentArray = []
        SVProgressHUD.show()
        self.tableView.isUserInteractionEnabled = false //タッチ無効
        let data = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: postData.id)
        data.observe(.value) { (snapshot,error) in
            for item in(snapshot.children){
                let child = item as! FIRDataSnapshot
                let postData = BBS_PostData1(snapshot: child, myId: "")
                
                
                var ng_flg = false
                
                for user in self.ng_UserArayy{
                    print("check --> \(user)")
                    print("c --> \(self.ng_UserArayy)")
                    if (postData.userId == user){
                        ng_flg = true
                        print("      --> NG \(ng_flg)")
                    }else{
                        print("      --> OK \(ng_flg)")
                    }
                }
                
                if (ng_flg == false){
                    
                    self.commentArray.append(postData)
                }
            }
            
            self.tableView.reloadData() //reloadData()1回
            
            if self.timerCount == 1{
                self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.time), userInfo: nil, repeats: false)
                
            }
            else{
                self.tableView.isUserInteractionEnabled = true
                SVProgressHUD.dismiss()
                self.timerCount = 1
                
            }
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }
    
    
    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        print("スクロールスタート")
//        reloadButton.isEnabled = false
//        reloadButton.alpha = 0.3
//    }
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        
//        reloadButton.isEnabled = false
//        reloadButton.alpha = 0.3
//        print("スクロール中")
//        
//        //最下部にスクロールしても、print("スクロール中")が表示されるため⇩
//        
//        if tableView.contentOffset.y == (self.tableView.contentSize.height - self.tableView.frame.size.height ) || tableView.contentOffset.y == (self.tableView.contentInset.top ) {
//            print("スクロール解除")
//            reloadButton.isEnabled = true
//            reloadButton.alpha = 1.0
//            
//        }
//    }
//    
//    
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView,willDecelerate decelerate: Bool){
//        print("スクロールで指が離れたところ")
//        reloadButton.isEnabled = true
//        reloadButton.alpha = 1.0
//    }
    
    
    func time(){
        //top == 実機で右のスクロールが動いてない時
        if tableView.contentOffset.y != (self.tableView.contentInset.top ){
            self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentSize.height - self.tableView.frame.size.height ), animated: false)
        }
        SVProgressHUD.dismiss()
        self.timer.invalidate()
        check = false
        self.tableView.isUserInteractionEnabled = true
        
        if (reloadButton.isEnabled == false){
            
            reloadButton.isEnabled = true
        }
    }
    
    
    
    
    
    
    @IBAction func back(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func contributionButton(_ sender: Any) {
        
//        performSegue(withIdentifier: "nextCommentViewController", sender: nil)

            
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
        
        reloadButton.isEnabled = false
        if (check == false){
            check = true
            loadAllData()
            
            //いらない
            //            self.timer2 = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.time2), userInfo: nil, repeats: false)
            //            self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.time), userInfo: nil, repeats: false)
        }
        
        //
        //        self.tableView.contentOffset = CGPointMake(0, -self.tableView.contentInset.top) //上
        
        //        self.tableView.setContentOffset(
        //            CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height),
        //            animated: false)　　//下
        
    }
    
    func handleButton(sender: UIButton, event:UIEvent) {
        
        let cellImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "nextimg") as! CellImageViewController
        //投稿画像
        cellImageViewController.img.image = postData.image
        present(cellImageViewController, animated: true, completion: nil)
    }
    
    func profile_handleButton(sender: UIButton, event:UIEvent) {
        
        let cellImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "nextimg") as! CellImageViewController
        //投稿画像
        cellImageViewController.img.image = postData.profile_image
        present(cellImageViewController, animated: true, completion: nil)
    }
    
    func handleButton2(sender: UIButton, event:UIEvent){
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        // 投稿の画面を開く
        let cellImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "nextimg") as! CellImageViewController
        let dict = commentArray[(indexPath! as NSIndexPath).row]
        //投稿画像
        cellImageViewController.img.image = dict.image
        present(cellImageViewController, animated: true, completion: nil)
    }
    
    func profile_handleButton2(sender: UIButton, event:UIEvent){
        let touch = event.allTouches?.first
        let point = touch!.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        // 投稿の画面を開く
        let cellImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "nextimg") as! CellImageViewController
        let dict = commentArray[(indexPath! as NSIndexPath).row]
        //投稿画像
        cellImageViewController.img.image = dict.profile_image
        present(cellImageViewController, animated: true, completion: nil)
        
    }
    
    func ngAction2(sender: UIButton, event:UIEvent){
        
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        
        let ngUser = commentArray[(indexPath?.row)!].userId
        
        print("ngUser  --> \(ngUser)")
        
        if  (UserDefaults.standard.object(forKey: "userId")) != nil{
            let user:String = (UserDefaults.standard.object(forKey: "userId") as! String)
            if user == ngUser{
                SVProgressHUD.showError(withStatus: "自身は非表示に\nできません")
                return
            }
        }
        
        
        ngAlert(ngUser:ngUser)
        
        
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
    
    func addngAction(ngUser:String){
        
        
        ng_UserArayy.append(ngUser)
        
        
        
        UserDefaults.standard.set(ng_UserArayy, forKey: "ng_UserArayy")
        
        loadAllData()
        tableView.reloadData()
        
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if (segue.identifier == "post"){
            let postViewController:PostViewController = segue.destination as! PostViewController
            
        
                postViewController.postSelect = 10
                postViewController.postData = postData
                postViewController.post_id = postData.id
        }
        
        //        let nextCommentViewController:NextCommentViewController = segue.destination as! NextCommentViewController
//        nextCommentViewController.postData = postData
//        nextCommentViewController.post_id = postData.id
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
