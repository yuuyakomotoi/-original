//
//  CommentViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/04/25.
//  Copyright © 2017年 小本裕也. All rights reserved.
// タイマー　リロードアアチ


import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD



class CommentViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var postData:BBS_PostData1!
    
    var post_select = 0
    var post_id = ""
    var profileImageView2 = UIImageView()
    var userNameLabel2 = ""
    
    var commentTextView2 = String()
    var postedImageView2 = UIImageView()
    var cell_CategoryTitle2 = ""
    var cell_CategoryContent2 = String()
    
    var cellCount2:String!
    var cellUserName2:String!
    
    var ok_UserArayy:[String] = []
    
    var ng_UserArayy:[String] = []
    
    var timer:Timer!
    
    
    var check:Bool = false
    
    var timerCount = 0
    
    @IBOutlet var tableView: UITableView!
    
    
    @IBOutlet var reloadButton: UIButton!
    
    var items = [NSDictionary]()
    
    let refreshControl = UIRefreshControl()
    
    var commentArray:[BBS_PostData1] = []
   


    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        //処理の順番があるためカスタムセルはviewDidLoad()で宣言
        let nib = UINib(nibName: "BulletinBoardTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let nib2 = UINib(nibName: "BulletinBoardTableViewCell2", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "Cell2")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.estimatedRowHeight = 298
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        
        if (UserDefaults.standard.object(forKey: "ng_UserArayy")) != nil{
            ng_UserArayy = UserDefaults.standard.object(forKey: "ng_UserArayy") as! [String]
        }
        print("ng_UserArayy  --> \(ng_UserArayy)")
        
        if (UserDefaults.standard.object(forKey: "ok_UserArayy")) != nil{
            ok_UserArayy = UserDefaults.standard.object(forKey: "ok_UserArayy") as! [String]
        }
        print("ok_UserArayy  --> \(ok_UserArayy)")
        
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
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BulletinBoardTableViewCell
            
            cell.selectionStyle = .none
            
            cell.backView.backgroundColor = UIColor(white:0.98,alpha:1.0)
            
            
            //プロフィール画像
            //デコードしたものを反映する
            let decodedImage = postData.profile_image
            
            //画像を丸くする。値が大きいほど丸くなる
            cell.profileImageView.layer.cornerRadius = 8.0
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
            
            //セルのカテゴリータイトル
            
            //セルのカテゴリー内容
            
            let category:Int = postData.bbs_type
            
            switch  category {
            case 0:
                cell.cell_CategoryTitle.isHidden = true
                cell.cell_CategoryContent.isHidden = true
                cell.cell_CategoryTitle.text = ""
                cell.cell_CategoryContent.text = ""
                break
            case 1:
                cell.cell_CategoryTitle.isHidden = false
                cell.cell_CategoryContent.isHidden = false
                cell.cell_CategoryTitle.text = "ルームID"
                cell.cell_CategoryContent.text = postData.category
                break
            case 2:
                cell.cell_CategoryTitle.isHidden = false
                cell.cell_CategoryContent.isHidden = false
                cell.cell_CategoryTitle.text = "フレンドID"
                cell.cell_CategoryContent.text = postData.category
                break
            case 3:
                cell.cell_CategoryTitle.isHidden = false
                cell.cell_CategoryContent.isHidden = false
                cell.cell_CategoryTitle.text = "チーム名"
                cell.cell_CategoryContent.text = postData.category
                break
            default:
                break
            }
            
            //プロフィール画像拡大
            cell.profileLinkButton.addTarget(self, action:#selector(profile_handleButton(sender:event:)), for:  UIControlEvents.touchUpInside)
            
            //
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
            
            //ユーザーのお気に入り登録
            cell.okButton.addTarget(self, action:#selector(okAction(sender:event:)), for: UIControlEvents.touchUpInside)
            
            
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! BulletinBoardTableViewCell2
            
            cell.selectionStyle = .none
            
            let dict = commentArray[indexPath.row]
            
            //プロフィール画像
            //画像を丸くする。値が大きいほど丸くなる
            let decodedImage = dict.profile_image
            cell.profileImageView.layer.cornerRadius = 8.0
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
            
            //ユーザーのお気に入り登録
            cell.okButton.addTarget(self, action:#selector(okAction2(sender:event:)), for: UIControlEvents.touchUpInside)
            
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
    
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print("スクロールスタート")
        reloadButton.isEnabled = false
        reloadButton.alpha = 0.3
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        reloadButton.isEnabled = false
        reloadButton.alpha = 0.3
        print("スクロール中")
        
        //最下部にスクロールしても、print("スクロール中")が表示されるため⇩
        
        if tableView.contentOffset.y == (self.tableView.contentSize.height - self.tableView.frame.size.height ) || tableView.contentOffset.y == (self.tableView.contentInset.top ) {
            print("スクロール解除")
            reloadButton.isEnabled = true
            reloadButton.alpha = 1.0
            
        }
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,willDecelerate decelerate: Bool){
        print("スクロールで指が離れたところ")
        reloadButton.isEnabled = true
        reloadButton.alpha = 1.0
    }
    
    
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
        
        performSegue(withIdentifier: "nextCommentViewController", sender: nil)
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
    
    
    func okAction(sender: UIButton, event:UIEvent){
        
        
        let okUser = postData.userId
        print("okUser ----------->\(okUser)")
        
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
    
    func okAction2(sender: UIButton, event:UIEvent){
        
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let okUser = commentArray[(indexPath?.row)!].userId
        
        print("okUser  --> \(okUser)")
        
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
    
    func addokAction(okUser:String){
        
        
        ok_UserArayy.append(okUser)
        UserDefaults.standard.set(ok_UserArayy, forKey: "ok_UserArayy")
        
        SVProgressHUD.showError(withStatus: "お気に入りに\n登録しました")
        
        print("ok_UserArayy  --> \(ok_UserArayy)")
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nextCommentViewController:NextCommentViewController = segue.destination as! NextCommentViewController
        nextCommentViewController.postData = postData
        nextCommentViewController.post_id = postData.id
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
