//
//  FavoriteUserViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/05/21.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import SVProgressHUD

class FavoriteUserViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var post_id = ""
    var cell_CategoryTitle1 = String()
    
    var okUser:[String] = []
    
    
    
    var ok_UserArayy:[String] = []
    
    
    
    var items = [BBS_PostData1]()
    
    let refreshControl = UIRefreshControl()
    
    var segmentCount = 0
    
    var timer:Timer!
    
    
    
    var check:Bool = false
    
    var image_Select = false
    
    
    @IBOutlet var segmentButton: UISegmentedControl!
    
    
    @IBOutlet var categoryLabel: UILabel!
    
    
    @IBOutlet var tableView: UITableView!
    
    
    @IBOutlet var reloadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        self.tableView.estimatedRowHeight = 298
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refreshControl.addTarget(self, action:#selector(refresh), for:UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        //        reloadButton.layer.cornerRadius = reloadButton.frame.size.width / 2
        //        reloadButton.clipsToBounds = true
        
        
        /*
         let reloadButton = UIButton()
         reloadButton.frame = CGRect(x: Int(self.view.frame.size.width - 72) , y: Int(self.view.frame.size.height - 93), width: 55, height: 55)
         reloadButton.tintColor = UIColor.white
         reloadButton.backgroundColor = UIColor.blue
         reloadButton.setTitle("更新", for:.normal)
         reloadButton.layer.cornerRadius = reloadButton.frame.size.width / 2
         reloadButton.clipsToBounds = true
         reloadButton.addTarget(self, action: #selector(reloadButton(sender:event:)), for:.touchUpInside)
         self.view.addSubview(reloadButton)
         */
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let nib = UINib(nibName: "BulletinBoardTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
        let nib2 = UINib(nibName: "BulletinBoardTableViewCell2", bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: "Cell2")
        tableView.rowHeight = UITableViewAutomaticDimension
        
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
            cell.ngButton.isHidden = true
            
            
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
            cell.ngButton.isHidden = true
            
            
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
    
    //データを取ってくるメソッド
    func loadAllData(segmentCount:Int){ // 雑談掲示板
        
        items = [BBS_PostData1]()
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if ( segmentCount == 0 ) {
            SVProgressHUD.show()
            segmentButton.isEnabled = false
            tableView.isHidden = true
            let firebase = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "0")
            firebase.queryLimited(toLast: 10).observe(.value) { (snapshot,error) in
                for item in(snapshot.children){//children　データの子供
                    let child = item as! FIRDataSnapshot
                    let postData = BBS_PostData1(snapshot: child, myId: "")
                    
                    var ng_flg = false
                    
                    for user in self.ok_UserArayy {
                        print("check --> \(user)")
                        print("c --> \(self.ok_UserArayy)")
                        if ( postData.userId == user ) {
                            ng_flg = true
                            print("      --> NG \(ng_flg)")
                        }
                        else {
                            print("      --> OK \(ng_flg)")
                        }
                    }
                    
                    if ( ng_flg ) {  //次回質問
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
            tableView.isHidden = true
            let firebase = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "1")
            firebase.queryLimited(toLast: 10).observe(.value) { (snapshot,error) in
                for item in(snapshot.children){
                    let child = item as! FIRDataSnapshot
                    let postData = BBS_PostData1(snapshot: child, myId: "")
                    var ng_flg = false
                    
                    for user in self.ok_UserArayy {
                        print("check --> \(user)")
                        print("c --> \(self.ok_UserArayy)")
                        if ( postData.userId == user ) {
                            ng_flg = true
                            print("      --> NG \(ng_flg)")
                        }
                        else {
                            print("      --> OK \(ng_flg)")
                        }
                    }
                    
                    if ( ng_flg ) {  //次回質問
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
            tableView.isHidden = true
            let firebase = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "2")
            firebase.queryLimited(toLast: 10).observe(.value) { (snapshot,error) in
                for item in(snapshot.children){
                    let child = item as! FIRDataSnapshot
                    let postData = BBS_PostData1(snapshot: child, myId: "")
                    var ng_flg = false
                    
                    for user in self.ok_UserArayy {
                        print("check --> \(user)")
                        print("c --> \(self.ok_UserArayy)")
                        if ( postData.userId == user ) {
                            ng_flg = true
                            print("      --> NG \(ng_flg)")
                        }
                        else {
                            print("      --> OK \(ng_flg)")
                        }
                    }
                    
                    if ( ng_flg ) {  //次回質問
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
            tableView.isHidden = true
            let firebase = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "3")
            firebase.queryLimited(toLast: 10).observe(.value) { (snapshot,error) in
                for item in(snapshot.children){
                    let child = item as! FIRDataSnapshot
                    let postData = BBS_PostData1(snapshot: child, myId: "")
                    var ng_flg = false
                    
                    for user in self.ok_UserArayy {
                        print("check --> \(user)")
                        print("c --> \(self.ok_UserArayy)")
                        if ( postData.userId == user ) {
                            ng_flg = true
                            print("      --> NG \(ng_flg)")
                        }
                        else {
                            print("      --> OK \(ng_flg)")
                        }
                    }
                    
                    if ( ng_flg ) {  //次回質問
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
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dict = items[indexPath.row] as BBS_PostData1
        
        //セルのカテゴリータイトル
        let cell_CategoryTitle:UILabel! = UILabel()
        
        switch segmentCount {
        case 0:
            cell_CategoryTitle.text = ""
            cell_CategoryTitle1 = cell_CategoryTitle.text!
            break
        case 1:
            cell_CategoryTitle.text = "ルームID"
            cell_CategoryTitle1 = cell_CategoryTitle.text!
            break
        case 2:
            cell_CategoryTitle.text = "フレンドID"
            cell_CategoryTitle1 = cell_CategoryTitle.text!
            break
        case 3:
            cell_CategoryTitle.text = "チーム名"
            cell_CategoryTitle1 = cell_CategoryTitle.text!
            break
        default:
            break
        }
        image_Select = true
        performSegue(withIdentifier: "nextComment", sender: dict)
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
        
        self.tableView.setContentOffset(CGPoint(x: 0, y: self.tableView.contentInset.top ), animated: false)
        
        self.segmentButton.isEnabled = true
        SVProgressHUD.dismiss()
        self.timer.invalidate()
        check = false
        self.tableView.isHidden = false
        
        if (reloadButton.isEnabled == false){
            
            reloadButton.isEnabled = true
        }
    }
    
    
    
    
    @IBAction func segmentButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            segmentCount = 0
            loadAllData(segmentCount:0)
            categoryLabel.text = "雑談"
            tableView.reloadData()
            break
        case 1:
            loadAllData(segmentCount:1)
            segmentCount = 1
            categoryLabel.text = "マルチ募集"
            tableView.reloadData()
            break
        case 2:
            loadAllData(segmentCount:2)
            segmentCount = 2
            categoryLabel.text = "フレンド募集"
            tableView.reloadData()
            break
        case 3:
            loadAllData(segmentCount:3)
            segmentCount = 3
            categoryLabel.text = "チーム募集"
            tableView.reloadData()
            break
            
        default:
            break
        }
        
        
        
    }
    
    @IBAction func reloadButton(_ sender: Any) {
        switch segmentCount {
        case 0:
            items = [BBS_PostData1]()
            reloadButton.isEnabled = false
            if (check == false){
                check = true
                loadAllData(segmentCount:0)
                
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
    
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    func removeAlert(removeUser:String){
        
        
        
        let alertViewControler = UIAlertController(title:"このユーザーをお気に入りから削除しますか？", message: "", preferredStyle:.alert)
        
        let okAction = UIAlertAction(title: "削除する", style: .default, handler: {
            (action:UIAlertAction!) -> Void in
            self.addokAction(removeUser: removeUser)
            
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
        
        let removeUser = items[(indexPath?.row)!].userId
        
        
        removeAlert(removeUser:removeUser)
        
        
        
        print("okUser  --> \(okUser)")
    }
    
    func addokAction(removeUser:String){
        
        
        var user_index:Int = 0
        
        
        
        for i in 0..<ok_UserArayy.count { // 0 1 2 3 4 5 6 7 8 9 10
            if ( ok_UserArayy[i] == removeUser ) { // 5 => removeUserに一致した場合
                user_index = i // user_index = 5 代入
            }
        }
        
        ok_UserArayy.remove(at: user_index)
        
        UserDefaults.standard.set(ok_UserArayy, forKey: "ok_UserArayy")
        
        
        loadAllData(segmentCount: segmentCount)
        
        tableView.reloadData()
        
        let alertController = UIAlertController(title: "お気に入りから\n削除しました", message: "", preferredStyle: .alert)
        
        let okAction:UIAlertAction = UIAlertAction(title: "Ok", style: .default, handler: {
            (action:UIAlertAction!) -> Void in
            
        })
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
        
        
        
        
        print("ok_UserArayy  --> \(ok_UserArayy)")
        
    }
    
    
    
    @IBAction func supportButton(_ sender: Any) {
        
        let support = self.storyboard?.instantiateViewController(withIdentifier: "support")
        present(support!, animated: true, completion: nil)
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





















