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

class BulletinBoardViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    
    
    
    var ok_UserArayy:[String] = []
    
    var ng_UserArayy:[String] = []
    
    
    var items = [BBS_PostData1]()
    
    
    let refreshControl = UIRefreshControl()
    
    var segmentCount = 0
    
    var timer:Timer!
    
    var image_Select = false
    
    var check:Bool = false
    
   var count = 30
    
    var t_check = false
    
    
    @IBOutlet var segmentButton: UISegmentedControl!
    
    
    @IBOutlet var contributionLabel: UITextField!
    
    @IBOutlet var categoryLabel: UILabel!
    
    
    @IBOutlet var tableView: UITableView!
    
    
    @IBOutlet var reloadButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "BulletinBoardTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
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
        switch segmentCount {
        case 0:
            items = [BBS_PostData1]()
            loadAllData(segmentCount:0)
            SVProgressHUD.dismiss()
            break
        case 1:
            items = [BBS_PostData1]()
            loadAllData(segmentCount:1)
           SVProgressHUD.dismiss()
            break
        case 2:
            items = [BBS_PostData1]()
            loadAllData(segmentCount:2)
            SVProgressHUD.dismiss()
            break
        case 3:
            items = [BBS_PostData1]()
            loadAllData(segmentCount:3)
            SVProgressHUD.dismiss()
            break
        default:
            break
        }
        refreshControl.endRefreshing()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
       
        
        if (UserDefaults.standard.object(forKey: "ng_UserArayy")) != nil{
            ng_UserArayy = UserDefaults.standard.object(forKey: "ng_UserArayy") as! [String]
        }
        
        if (UserDefaults.standard.object(forKey: "ok_UserArayy")) != nil{
            ok_UserArayy = UserDefaults.standard.object(forKey: "ok_UserArayy") as! [String]
        }
        
        if (image_Select == true){
            image_Select = false
        }else{
            loadAllData(segmentCount: segmentCount)
        
        }
        
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if segmentCount == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! BulletinBoardTableViewCell2
            cell.setPostData(BBS_PostData1: items[indexPath.row])
            
            
            
            
            
            //ハイライトがされない
            cell.selectionStyle = .none
            
            let dict = items[(indexPath as NSIndexPath).row]
            
            
            cell.backView.backgroundColor = UIColor(white:0.98,alpha:1.0)
            
            
            
            
            //プロフィール画像
            //デコードしたものを反映する
            let decodedImage = dict.profile_image
            
            
            //画像を丸くする。値が大きいほど丸くなる
            cell.profileImageView.layer.cornerRadius = 8.0
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
            
            
            return cell
            
            
        }else{
            
            
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BulletinBoardTableViewCell
            cell.setPostData(BBS_PostData1: items[indexPath.row])
            
            // cell.layoutIfNeeded()
            
            
            
            //ハイライトがされない
            cell.selectionStyle = .none
            
            let dict = items[(indexPath as NSIndexPath).row]
            
            
            cell.backView.backgroundColor = UIColor(white:0.97,alpha:1.0)
            
            
            
            
            //プロフィール画像
            //デコードしたものを反映する
            let decodedImage = dict.profile_image
            
            
            //画像を丸くする。値が大きいほど丸くなる
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
            //デコードしたものを反映する
            
            
            cell.postedImageView.image = dict.image
            
            
            
            //セルのカテゴリータイトル
            
            switch segmentCount {
            case 0:
                cell.cell_CategoryTitle.isHidden = true
                cell.cell_CategoryTitle.text = ""
                break
            case 1:
                cell.cell_CategoryTitle.isHidden = false
                cell.cell_CategoryTitle.text = "ルームID"
                
                break
            case 2:
                cell.cell_CategoryTitle.isHidden = false
                cell.cell_CategoryTitle.text = "フレンドID"
                break
            case 3:
                cell.cell_CategoryTitle.isHidden = false
                cell.cell_CategoryTitle.text = "チーム名"
                break
                
            default:
                break
            }
            
            //セルのカテゴリー内容
            if segmentCount == 0 {
                cell.cell_CategoryContent.isHidden = true
                cell.cell_CategoryContent.text = ""
            }else{
                cell.cell_CategoryContent.isHidden = false
                cell.cell_CategoryContent.text = dict.category
            }
            
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
            
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = items[indexPath.row] as BBS_PostData1
        
        //セルのカテゴリータイトル
        image_Select = true
        performSegue(withIdentifier: "nextComment", sender: dict)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // Auto Layoutを使ってセルの高さを動的に変更する
        return UITableViewAutomaticDimension
    }

    
    //データを取ってくるメソッド
    func loadAllData(segmentCount:Int){ // 雑談掲示板
        
        items = [BBS_PostData1]()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if ( segmentCount == 0 ) {
            SVProgressHUD.show()
            segmentButton.isEnabled = false
            self.tableView.isUserInteractionEnabled = false //タッチ無効
            let firebase = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "0")
            firebase.queryLimited(toLast: UInt(Int(count))).observe(.value) { (snapshot,error) in
                for item in(snapshot.children){//children　データの子供
                    let child = item as! FIRDataSnapshot
                    let postData = BBS_PostData1(snapshot: child, myId: "")
                    
                    var ng_flg = false
                    
                    for user in self.ng_UserArayy {
                        print("check --> \(user)")
                        print("c --> \(self.ng_UserArayy)")
                        if ( postData.userId == user ) {
                            ng_flg = true
                            print("      --> NG \(ng_flg)")
                        }
                        else {
                            print("      --> OK \(ng_flg)")
                        }
                    }
                    
                    if ( !ng_flg ) {  //次回質問
                        self.items.append(postData)
                    }
                }
                self.items.reverse()
                self.tableView.reloadData()
                self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.time), userInfo: nil, repeats: false)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        else if ( segmentCount == 1 ) {
            SVProgressHUD.show()
            segmentButton.isEnabled = false
            self.tableView.isUserInteractionEnabled = false //タッチ無効
            let firebase = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "1")
            firebase.queryLimited(toLast: 10).observe(.value) { (snapshot,error) in
                for item in(snapshot.children){
                    let child = item as! FIRDataSnapshot
                    let postData = BBS_PostData1(snapshot: child, myId: "")
                    var ng_flg = false
                    
                    for user in self.ng_UserArayy {
                        print("check --> \(user)")
                        print("c --> \(self.ng_UserArayy)")
                        if ( postData.userId == user ) {
                            ng_flg = true
                            print("      --> NG \(ng_flg)")
                        }
                        else {
                            print("      --> OK \(ng_flg)")
                        }
                    }
                    
                    if ( !ng_flg ) {  //次回質問
                        self.items.append(postData)
                    }
                }
                
                self.items.reverse()
                self.tableView.reloadData()
                self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.time), userInfo: nil, repeats: false)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }else if ( segmentCount == 2 ) {
            SVProgressHUD.show()
            segmentButton.isEnabled = false
            self.tableView.isUserInteractionEnabled = false //タッチ無効
            let firebase = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "2")
            firebase.queryLimited(toLast: 10).observe(.value) { (snapshot,error) in
                for item in(snapshot.children){
                    let child = item as! FIRDataSnapshot
                    let postData = BBS_PostData1(snapshot: child, myId: "")
                    var ng_flg = false
                    
                    for user in self.ng_UserArayy {
                        print("check --> \(user)")
                        print("c --> \(self.ng_UserArayy)")
                        if ( postData.userId == user ) {
                            ng_flg = true
                            print("      --> NG \(ng_flg)")
                        }
                        else {
                            print("      --> OK \(ng_flg)")
                        }
                    }
                    
                    if ( ng_flg == false ) {  //次回質問
                        self.items.append(postData)
                    }
                }
                self.items.reverse()
                self.tableView.reloadData()
                self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.time), userInfo: nil, repeats: false)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }else if ( segmentCount == 3 ) {
            SVProgressHUD.show()
            segmentButton.isEnabled = false
            self.tableView.isUserInteractionEnabled = false //タッチ無効
            let firebase = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "3")
            firebase.queryLimited(toLast: 10).observe(.value) { (snapshot,error) in
                for item in(snapshot.children){
                    let child = item as! FIRDataSnapshot
                    let postData = BBS_PostData1(snapshot: child, myId: "")
                    var ng_flg = false
                    
                    for user in self.ng_UserArayy {
                        print("check --> \(user)")
                        print("ng_UserArayy --> \(self.ng_UserArayy)")
                        if ( postData.userId == user ) {
                            ng_flg = true
                            print("      --> NG \(ng_flg)")
                        }
                        else {
                            print("      --> OK \(ng_flg)")
                        }
                    }
                    
                    if ( !ng_flg ) {  //次回質問
                        
                        self.items.append(postData)
                    }
                }
                
                self.items.reverse()
                self.tableView.reloadData()
                self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.time), userInfo: nil, repeats: false)
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
        
        reloadButton.isEnabled = false
        reloadButton.alpha = 0.3
        tableView.allowsSelection = false
        print("スクロール中")
        
        //最下部にスクロールしても、print("スクロール中")が表示されるため⇩
        
        if   tableView.contentOffset.y == (self.tableView.contentInset.top ) {
            print("スクロール解除")
            reloadButton.isEnabled = true
            reloadButton.alpha = 1.0
            tableView.allowsSelection = true
        }
  
        if tableView.contentOffset.y == (self.tableView.contentSize.height - self.tableView.frame.size.height ){
            
           
            
            if t_check == false{
            t_check = true
               
                
//               tabBarItem.isEnabled = false
            print("aaaaaaaaaaaaaaaaaaaaaaaaa")
            
                //いふ分でcount == 1 . 2 .3
            //50 50 100 100 200 200
            count += 50
            
           tableView.allowsSelection = false
                reloadButton.isEnabled = false
            if (check == false){
                check = true
                loadAllData(segmentCount:0)
                count -= 50
                }
                }
        }
    
    }
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,willDecelerate decelerate: Bool){
        print("スクロールで指が離れたところ")
        reloadButton.isEnabled = true
        reloadButton.alpha = 1.0
    tableView.allowsSelection = true
    
        }
    
    func time(){
        //top == 実機で右のスクロールが動いてない時
        
        if t_check == false{
        self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentInset.top ), animated: false)
        
        }
        
        self.segmentButton.isEnabled = true
        SVProgressHUD.dismiss()
        self.timer.invalidate()
        check = false
        self.tableView.isUserInteractionEnabled = true
        if (reloadButton.isEnabled == false){
            
            reloadButton.isEnabled = true
        }
    
        t_check = false
    print("bbbbbbbbbbbbb")
    }
    
    
    
    
    
    @IBAction func segmentButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            segmentCount = 0
            count = 30 ///////////////////////////////////////////////////////編集中
            loadAllData(segmentCount:0)
            categoryLabel.text = "雑談"
            contributionLabel.placeholder = "雑談に投稿"
            tableView.reloadData()
            break
        case 1:
            segmentCount = 1
            count = 30
            loadAllData(segmentCount:1)
            categoryLabel.text = "マルチ募集"
            contributionLabel.placeholder = "マルチ募集に投稿"
            tableView.reloadData()
            
            break
        case 2:
            segmentCount = 2
            count = 30
            loadAllData(segmentCount:2)
            categoryLabel.text = "フレンド募集"
            contributionLabel.placeholder = "フレンド募集に投稿"
            tableView.reloadData()
            
            break
        case 3:
            segmentCount = 3
            count = 30
            loadAllData(segmentCount:3)
            categoryLabel.text = "チーム募集"
            contributionLabel.placeholder = "チーム募集に投稿"
            tableView.reloadData()
            
            break
            
        default:
            break
        }
        
        
        
    }
    
    
    @IBAction func contributionButton(_ sender: Any) {
        if segmentCount == 0{
            let editViewController = self.storyboard?.instantiateViewController(withIdentifier: "edit")
            self.present(editViewController!,animated: true, completion: nil)
        }
        else if segmentCount == 1 {
            let multiViewController = self.storyboard?.instantiateViewController(withIdentifier: "multi")
            self.present(multiViewController!,animated: true, completion: nil)
        }
        else if segmentCount == 2 {
            let friendViewController = self.storyboard?.instantiateViewController(withIdentifier: "friend")
            self.present(friendViewController!,animated: true, completion: nil)
        }
        else if segmentCount == 3 {
            let teamViewController = self.storyboard?.instantiateViewController(withIdentifier: "team")
            self.present(teamViewController!,animated: true, completion: nil)
        }
    }
    
    @IBAction func reloadButton(_ sender: Any) {
        
        switch segmentCount {
        case 0:
            
            items = [BBS_PostData1]()
            t_check = false
            reloadButton.isEnabled = false
            if (check == false){
                check = true
                loadAllData(segmentCount:0)
                if t_check == false{
                    tableView.reloadData()
                }

            }
            break
        case 1:
            items = [BBS_PostData1]()
            reloadButton.isEnabled = false
            if (check == false){
                check = true
                loadAllData(segmentCount:1)
                
            }
            break
        case 2:
            items = [BBS_PostData1]()
            reloadButton.isEnabled = false
            if (check == false){
                check = true
                loadAllData(segmentCount:2)
                
            }
            break
        case 3:
            items = [BBS_PostData1]()
            reloadButton.isEnabled = false
            if (check == false){
                check = true
                loadAllData(segmentCount:3)
                
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
        
        loadAllData(segmentCount:segmentCount)
        tableView.reloadData()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "nextComment"){
            let commentViewController:CommentViewController = segue.destination as! CommentViewController
            commentViewController.postData = sender as! BBS_PostData1
        }
    }
    
}
