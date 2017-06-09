//
//  ViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/03/26.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage

import Firebase   // 先頭でFirebaseをimportしておく
import FirebaseAuth


class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,XMLParserDelegate {
    
    
    
    var refreshControl:UIRefreshControl!
    
    var parser = XMLParser()
    
    var totalBox = NSMutableArray()
    
    var elements = NSMutableDictionary()
    
    var element = String() //　タイトルが入ったり、リンクが入ったりする
    
    var titleString = NSMutableString() //キー値を決めて取り出したり、セットしたりする
    var linkString = NSMutableString()
    
    var dateString = NSMutableString()
    
    var imageString = String()
    
    var urlArray = ["https://www.cnet.com/rss/all/"]
    
    var dataArray = NSArray()
    
    //お気に入りに登録用の配列
    var newsTitleArray:[String] = []
    var newsLinkArray:[String] = []
    var newsDateArray:[String] = []
    var newsUrlArray:[String] = []
    
    var userId:String = ""
    
    
    @IBOutlet var tableView: UITableView!
    
    
    
    
    
    //ストリング型でもいい
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().tintColor = UIColor(red: 1, green: 0.6, blue: 0, alpha: 1)
        
        if UserDefaults.standard.object(forKey: "userId") == nil{
            let databaseRef = FIRDatabase.database().reference()
            
            //時間
            let date = NSDate()
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let dateString:String = formatter.string(from:date  as Date)
            
            let user:NSDictionary = ["date":dateString]
            
            //            databaseRef.child(Const.PostPath2).childByAutoId().setValue(user)
            
            
            // Firebaseが生成したIDを取得
            let userID = databaseRef.child(Const.PostPath2).childByAutoId()
            
            userID.setValue(user)
            
            //userID.setValue()
            
            UserDefaults.standard.set(String(describing: userID), forKey:"userId" )
            
            
        }else{
            
        }
        
        
        
        
        
        
        //引っ張って更新
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        
        tableView.addSubview(refreshControl)
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        
        
        
        //xmlを解析する(パース)
        totalBox = []
        for urlAll in urlArray{
            
            let url = urlAll  //ここにサイトのURLを入れる
            
            let urlToSend:URL = URL(string:url)!
            
            parser = XMLParser(contentsOf: urlToSend)!
            parser.delegate = self
            parser.parse()
            
        }
        
        /////////////////
        if FIRAuth.auth()?.currentUser == nil {
            // ログインしていなければログインの画面を表示する
            // viewDidAppear内でpresent()を呼び出しても表示されないためメソッドが終了してから呼ばれるようにする
            let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(loginViewController!, animated: true, completion: nil)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SVProgressHUD.dismiss()
        
        
        
        userId = UserDefaults.standard.object(forKey: "userId") as! String
        print("---------------->>>\(userId)")
        
        
        
        if UserDefaults.standard.object(forKey: "newsTitleArray") != nil{
            
            
            
            newsTitleArray = UserDefaults.standard.object(forKey: "newsTitleArray") as! [String]
            
            newsLinkArray = UserDefaults.standard.object(forKey: "newsLinkArray") as! [String]
            
            newsDateArray = UserDefaults.standard.object(forKey: "newsDateArray") as! [String]
            
            newsUrlArray = UserDefaults.standard.object(forKey: "newsUrlArray") as! [String]
            
            
        }
        
        
    }
    
    
    //引っ張って更新メソッド
    //引っ張って更新メソッドの時にもパースしたものを更新したいので上のコードをメソッドの中に入れる
    func refresh(){
        
        perform(#selector(delay), with: nil, afterDelay: 2.0)
        //解析するのに時間がかかるのでこのメソッド。2.0は秒数
    }
    
    func delay(){
        //xmlを解析する(パース)
        totalBox = []
        for urlAll in urlArray{
            
            let url = urlAll  //ここにサイトのURLを入れる
            
            let urlToSend:URL = URL(string:url)!
            
            parser = XMLParser(contentsOf: urlToSend)!
            parser.delegate = self
            parser.parse()
            //テーブルビュー更新
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //セクションの数
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count //セルの数 totalBoxが取得した数
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        
        let titleLabel = cell.viewWithTag(1) as! UILabel
        let linkLabel = cell.viewWithTag(2) as! UILabel
        let dateLabel = cell.viewWithTag(3) as! UILabel
        let thumbnailImage = cell.viewWithTag(4) as! UIImageView!
        let favoriteButton = cell.viewWithTag(5) as! UIButton
        favoriteButton.backgroundColor = UIColor.clear
        
        titleLabel.text = (dataArray[indexPath.row] as AnyObject).value(forKey: "title") as? String
        
        linkLabel.text = (dataArray[indexPath.row] as AnyObject).value(forKey: "link") as? String
        
        dateLabel.text = (dataArray[indexPath.row] as AnyObject).value(forKey: "pubDate") as? String
        
        let urlstr = (dataArray[indexPath.row] as AnyObject).value(forKey: "url") as! String
        
        
        let url:URL = URL(string: urlstr)!
        
        
        thumbnailImage?.sd_setImage(with:url,placeholderImage:UIImage(named: "No Image.png"))
        
        
        favoriteButton.addTarget(self, action:#selector(favoriteButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        
        //サムネイル画像がない時の画像のURL入れる
        
        
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor.white
        }
            
        else
        {
            
            cell.backgroundColor = UIColor(white:0.93,alpha:1.0)
        }
        
        cell.selectionStyle = .none
        
        
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let newsModalViewController = self.storyboard?.instantiateViewController(withIdentifier: "news") as! NewsModalViewController
        
        let linkURL = (dataArray[indexPath.row] as AnyObject).value(forKey: "link") as? String
        newsModalViewController.str = linkURL!
        
        //navigationControllerをstoryboardでセットしてから使う
        
        self.navigationController?.pushViewController(newsModalViewController, animated: true)
        
        
    }
    //パースについて
    
    //タグを見つけた時
    //parserのデリゲートメソッド
    // if element 上でString型の宣言をしている
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        element = elementName
        
        if element == "item"{
            
            elements = NSMutableDictionary()
            elements = [:]
            titleString = NSMutableString()
            titleString = ""
            linkString = NSMutableString()
            linkString = ""
            dateString = NSMutableString()
            dateString = ""
            imageString = String()
        }
        else if element == "media:thumbnail"{
            imageString = String()
            imageString = attributeDict["url"]!
        }
        
    }
    
    //タグの間にデータがあった(開始タグと終了タグでくくられた箇所にデータが存在位した時に実行されるメソッド)
    //parserのデリゲートメソッド
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if element == "title"{
            
            titleString.append(string)
            
        }else if element == "link"{
            
            linkString.append(string)
        }
        else if element == "pubDate"{
            dateString.append(string)
        }
    }
    
    //タグの終了を見つけた時
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?){
        
        //itemという要素の中にあるなら
        if elementName == "item"{
            //titleStringの中身(linkString)の中身が空でないなら
            if titleString != ""{
                //elementsにキー値を付与しながらtitleString(linkStrung)をセットする
                elements.setObject(titleString, forKey: "title" as NSCopying)
            }
            if linkString != "" {
                //elementsにキー値を付与しながらtitleString(linkStrung)をセットする
                elements.setObject(linkString, forKey: "link" as NSCopying)
            }
            if dateString != ""{
                let identifier = NSLocale.current.identifier
                
                //                if identifier == "ja_JP" {
                let dateFormatter = DateFormatter()
                dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
                dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZZZ"
                let r_date = dateFormatter.date(from: dateString as String)
                
                if let d = r_date {
                    dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale!
                    dateFormatter.dateFormat = "MM-dd HH:mm"
                    elements.setObject(dateFormatter.string(from: d), forKey: "pubDate" as NSCopying)
                    
                    //                    }
                }
            }
            
            elements.setObject(imageString,forKey:"url" as NSCopying)
            
            //totalBoxの中にelementsを入れる
            totalBox.add(elements)
        }
        sortAndReloadData()
    }
    func sortAndReloadData() {
        let dateDiscripter:NSSortDescriptor = NSSortDescriptor.init(key: "pubDate", ascending: false)
        let sortDescriptors:NSArray = [dateDiscripter]
        
        let data:NSArray = totalBox as NSArray
        
        dataArray = data.sortedArray(using: sortDescriptors as! [NSSortDescriptor]) as NSArray
        
        print(dataArray.description)
        tableView.reloadData()
    }
    
    
    func showAlert(newsTitle:String,newsLink:String,newsDate:String,newsUrl:String) {
        let alertViewControler = UIAlertController(title: "この記事をお気に入り登録しますか？", message: "「ホーム」→「お気に入り」\nより閲覧が可能となります", preferredStyle:.actionSheet)
        let okAction = UIAlertAction(title: "お気に入りに追加", style: .default, handler:{
            (action:UIAlertAction!) -> Void in
            self.addFavorite(newsTitle:newsTitle,newsLink:newsLink,newsDate:newsDate,newsUrl:newsUrl)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alertViewControler.addAction(okAction)
        alertViewControler.addAction(cancelAction)
        present(alertViewControler, animated: true, completion: nil)
        
    }
    
    func addFavorite(newsTitle:String,newsLink:String,newsDate:String,newsUrl:String) {
        
        
        newsTitleArray.append(newsTitle)
        UserDefaults.standard.set(newsTitleArray, forKey: "newsTitleArray")
        
        newsLinkArray.append(newsLink)
        UserDefaults.standard.set(newsLinkArray, forKey: "newsLinkArray")
        
        newsDateArray.append(newsDate)
        UserDefaults.standard.set(newsDateArray, forKey: "newsDateArray")
        
        newsUrlArray.append(newsUrl)
        UserDefaults.standard.set(newsUrlArray, forKey: "newsUrlArray")
        
        SVProgressHUD.showSuccess(withStatus: "お気に入りに\n追加しました")
    }
    
    func favoriteButton(sender: UIButton, event:UIEvent){
        
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let newsTitle = (dataArray[(indexPath?.row)!] as AnyObject).value(forKey: "title") as? String
        let newsLink = (dataArray[(indexPath?.row)!] as AnyObject).value(forKey: "link") as? String
        let newsDate = (dataArray[(indexPath?.row)!] as AnyObject).value(forKey: "pubDate") as? String
        let newsUrl = (dataArray[(indexPath?.row)!] as AnyObject).value(forKey: "url") as? String
        
        
        for i in newsLinkArray {
            if i == newsLink{
                SVProgressHUD.showError(withStatus: "この記事はお気に入りに登録済みです")
                return
            }
        }
        
        showAlert(newsTitle:newsTitle!,newsLink:newsLink!,newsDate:newsDate!,newsUrl:newsUrl!)
    }
    
    //    override func prepare(for segue:UIStoryboardSegue, sender:Any?){
    //        let newsModalViewController:NewsModalViewController = segue.destination as! NewsModalViewController
    //        NewsModalViewController.url =  ""
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

