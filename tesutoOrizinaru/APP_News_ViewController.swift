//
//  APP_News_ViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/07/07.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit
import SVProgressHUD
import SDWebImage



class APP_News_ViewController:UIViewController,UITableViewDataSource,UITableViewDelegate,XMLParserDelegate,URLSessionDownloadDelegate{
   
   
    
    let refreshControl = UIRefreshControl()
    
    var refresh_Chack = false
    
    
    
    var convery_count = 0
    
    var parser:XMLParser? = XMLParser()
    
    var data:NSData? = NSData()
    var data2:NSData? = NSData()
    
    
  
    
    
    var totalBox = NSMutableArray()
    
    var elements = NSMutableDictionary()
    
    var element = String() //　タイトルが入ったり、リンクが入ったりする
    
    var titleString = NSMutableString() //キー値を決めて取り出したり、セットしたりする
    
    var linkString = NSMutableString()
    
    var link_Name = String()
    
    var dateString = NSMutableString()
    
    var imageString = NSMutableString()
    
    
    let urlArray = ["http://gamebiz.jp/?feed=rss","http://www.4gamer.net/rss/smartphone/smartphone_index.xml"]//URLリスト
    
    
    var dataArray:NSArray = []
    var dataArray2:NSArray = []
    
    
    //お気に入りに登録用の配列
    var app_newsTitleArray:[String] = []
    var app_newsLinkArray:[String] = []
    var app_newsDateArray:[String] = []
    var app_newsUrlArray:[String] = []
    var app_newsLink_NameArray:[String] = []
    
    var support_Button = UIBarButtonItem()
    
    @IBOutlet var tableView: UITableView!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    
        
        refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refreshControl.addTarget(self, action:#selector(refresh), for:UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.totalBox = []
       self.dataArray = []

        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.navicheck == true{
            self.tabBarController?.tabBar.isHidden = true
        }
        
        
        
        support_Button = UIBarButtonItem(title: "説明", style: UIBarButtonItemStyle.plain, target: self, action:#selector(support))
        
        self.title = "アプリニュース"
        /////////////////
        //オートレイアウト
        
        self.navigationItem.rightBarButtonItem = support_Button
        
            convery_count = urlArray.count
        
            for url_string in urlArray{
                download_rss(url_str: url_string)
                
            }
        
        
        //refuresuつけずに
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if totalBox != []{
            SVProgressHUD.dismiss()
        }
        
        if UserDefaults.standard.object(forKey: "app_newsTitleArray") != nil{
            
            
            
            app_newsTitleArray = UserDefaults.standard.object(forKey: "app_newsTitleArray") as! [String]
            
            app_newsLinkArray = UserDefaults.standard.object(forKey: "app_newsLinkArray") as! [String]
            
            app_newsDateArray = UserDefaults.standard.object(forKey: "app_newsDateArray") as! [String]
            
            app_newsUrlArray = UserDefaults.standard.object(forKey: "app_newsUrlArray") as! [String]
            
            app_newsLink_NameArray = UserDefaults.standard.object(forKey: "app_newsLink_NameArray") as! [String]
            
            
        }
        
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //ナビゲーションのスワイプ無効
        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = false
        
        if dataArray == []{
            let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
            if appDelegate.dataArray != []{
                self.dataArray = appDelegate.dataArray
                print(dataArray)
                tableView.reloadData()
            }

        }
        
        
        if totalBox == []{
            SVProgressHUD.show()
        }
     
                    }
    
       //引っ張って更新メソッド
    //引っ張って更新メソッドの時にもパースしたものを更新したいので上のコードをメソッドの中に入れる
    
    
    func refresh(){
       perform(#selector(delay), with: nil, afterDelay: 1.5)
    }
    
    func delay(){
       
        
            
                refresh_Chack = true
            
            self.totalBox = []
           
            convery_count = urlArray.count
            
            for url_string in urlArray{
                download_rss(url_str: url_string)
                
            }
           refreshControl.endRefreshing()
          
        
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
        let thumbnailImage = cell.viewWithTag(4) as! UIImageView
        let favoriteButton = cell.viewWithTag(5) as! UIButton
        favoriteButton.backgroundColor = UIColor.clear
        
        
        if (( (dataArray[indexPath.row] as AnyObject).value(forKey: "title") ) != nil) {
            titleLabel.text = (dataArray[indexPath.row] as AnyObject).value(forKey: "title") as? String
        }
        
        if (( (dataArray[indexPath.row] as AnyObject).value(forKey: "link_Name") ) != nil) {
            linkLabel.text = (dataArray[indexPath.row] as AnyObject).value(forKey: "link_Name") as? String
        }
        
        if (( (dataArray[indexPath.row] as AnyObject).value(forKey: "pubDate") ) != nil) {
            dateLabel.text = (dataArray[indexPath.row] as AnyObject).value(forKey: "pubDate") as? String
        }
        
        if (( (dataArray[indexPath.row] as AnyObject).value(forKey: "image") ) != nil) {
            //SDウェブ
            //1024　の作る
            //2X = 2倍
            //概要
            
            let urlstr = (dataArray[indexPath.row] as AnyObject).value(forKey: "image") as! String
            let encodedString = urlstr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
            let url:URL = URL(string: encodedString!)!
            thumbnailImage.sd_setImage(with:url,placeholderImage:UIImage(named: "No Image.png"))
        }
        else {
            thumbnailImage.image = UIImage(named: "No Image.png")
        }
        
        
        
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
        newsModalViewController.app_News_Check = true
    
        self.navigationController?.pushViewController(newsModalViewController, animated: true)
        
        
        
        
        
    }
    
    
    func download_rss(url_str:String){
        // 通信のコンフィグを用意.
//        let config: URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        // Sessionを作成する.
        //        let session: URLSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        let session: URLSession = URLSession.shared
        
        // ダウンロード先のURLからリクエストを生成.
        let url:NSURL = NSURL(string: url_str)!
        let request: URLRequest =  URLRequest(url: url as URL)
        
        // ダウンロードタスクを生成.
        //        let myTask: URLSessionDownloadTask = session.downloadTask(with: request)
        
        let myTask = session.downloadTask(with: request) { (url, response, error) in
            
            print("finish download")
            
            var data: NSData!
            
            do {
                data = try NSData(contentsOf: url!, options: NSData.ReadingOptions.alwaysMapped)
            } catch {
                print(error)
            }
            
            let rss = String(data: data as Data, encoding: .utf8)!
            
            
            self.convertRSS(rss:rss)
            
        
        }
        
        // タスクを実行.
        myTask.resume()
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        
//        //ここにブレイクポイントを打ったが呼ばれない
//        
//        print("finish download")
//        
//        var data: NSData!
//        
//        do {
//            data = try NSData(contentsOf: location, options: NSData.ReadingOptions.alwaysMapped)
//        } catch {
//            print(error)
//        }
//        
//        let rss = String(data: data as Data, encoding: .utf8)!
//        
//        
//        ///rss入れた
//        //メソッド作る
//        
//        
//        convertRSS(rss:rss)
        
    }
    
    func convertRSS(rss:String){
        
        
        
        
        // 正規表現に置き換える
        
        
        
        
        
        
        convery_count -= 1
        
        
        if convery_count == 1{
            print(convery_count)
        
            var result:String = ""
            var result2:String = ""
            var result3:String = ""
            var result4:String = ""
            var result5:String = ""
            var result6:String = ""
            
            var rss_data:String = ""
            data = NSData()
            
            result = rss
            
 
            result2 = result.pregReplace(pattern: "<item.+rdf.+>", with: "<item>")
            
            result3 = result2.pregReplace(pattern: "<dc:date>", with: "<pubDate>")
           
            
            result4 = result3.pregReplace(pattern: "</dc:date>", with: "<\\/pubDate>")
            

            result5 = result4.pregReplace(pattern: "<\\/rdf:RDF>", with: "\\\t<item>\\\t<title>RSS_Check<\\/title><\\/item><\\/rdf:RDF>")
//            print(result5.debugDescription)
            result6 = result5.pregReplace(pattern: "\\n", with: "")

            
            
            
            rss_data += result6
        
            
            self.data = rss_data.data(using: String.Encoding.utf8)! as NSData
      
        
        }else if convery_count == 0{
            
            var result:String = ""
            var result2:String = ""
            var result3:String = ""
           
            
            var rss_data2:String = ""
            data2 = NSData()
            
            result = rss
            
            result2 = result.pregReplace(pattern: "<\\/rss>", with: "\\\t<item>\\\t<title>RSS_END<\\/title><\\/item><\\/rss>")

            result3 = result2.pregReplace(pattern: "\\\n\\\t\\\t\\\t\\\t\\\t\\\t\\\t\\\t|\\\n\\\t\\\t\\\t\\\t", with: "")
            


        
            
            
            rss_data2 += result3
            
            print(result3.debugDescription)
            
           
            
            
            self.data2 = rss_data2.data(using: String.Encoding.utf8)! as NSData
            
            
        
            
            //print(self.rss_data2)
            //print(rss_data.debugDescription)
            //print(data.debugDescription)
            
            for i in 0...1{
                if i == 0 {self.parser = XMLParser(data: self.data! as Data)
                    if self.parser != nil {
                        
                        
                        convery_count = 1
                        
                        self.parser!.delegate = self
                        self.parser!.parse()
                        
                        print("パース成功")
                    } else {
                        // パースに失敗した時
                        print("パース失敗")
                    }
                    
                }else{
                    self.parser = XMLParser(data: self.data2! as
                        Data)
                    if self.parser != nil {
                        
                        convery_count = 0
                        
                        self.parser!.delegate = self
                        self.parser!.parse()
                        print("パース成功")
                    } else {
                        // パースに失敗した時
                        print("パース失敗")
                    }
                    
                }
            }
            
            
            
        }
        
    }
    
    
    //タグを見つけた時
    //parserのデリゲートメソッド
    // if element 上でString型の宣言をしている
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        element = elementName
        
        
        
        if element == "item"{
            
//            print("itemを見つけた")
            
            elements = NSMutableDictionary()
            elements = [:]
            titleString = NSMutableString()
            titleString = ""
            linkString = NSMutableString()
            linkString = ""
            dateString = NSMutableString()
            dateString = ""
            imageString = NSMutableString()
            imageString = ""
        }
    }
    
    //タグの間にデータがあった(開始タグと終了タグでくくられた箇所にデータが存在位した時に実行されるメソッド)
    //parserのデリゲートメソッド
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        
        if element == "title"{
            
//            print("titleを見つけた")
           

            titleString.append(string)
//            print("title---------->\(titleString)")
            
            
            
        }else if element == "link"{
            
//            print("linkを見つけた")
            
            linkString.append(string)
//            print("link---------->\(linkString)")

        }
        else if element == "pubDate"{
            
//            print("pubDateを見つけた")
            
            dateString.append(string)
        }
        
        if (convery_count == 1){
//            if element == "image"{
//                
//                //            print("imageを見つけた")
//                
//                imageString.append(string)
//            }
    
        }else if (convery_count == 0){
            if element == "description"{
        
                imageString.append(string)
            }

        }
        
       
    }
    
    //タグの終了を見つけた時
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?){
        
        //itemという要素の中にあるなら
        if elementName == "item"{
            
            if titleString != ""{
                
//                print("title---------->\(titleString)")
                elements.setObject(titleString, forKey: "title" as NSCopying)
                
                if (self.convery_count == 1){
                    link_Name = "4Gamer.net"
                    elements.setObject(link_Name, forKey: "link_Name" as NSCopying)
                }else if (self.convery_count == 0){
                    link_Name = "Social Game Info"
                    elements.setObject(link_Name, forKey: "link_Name" as NSCopying)
                }
                
            }
            if linkString != "" {
                //elementsにキー値を付与しながらtitleString(linkStrung)をセットする
//                print("link---------->\(linkString)")
                elements.setObject(linkString, forKey: "link" as NSCopying)
            
                if (convery_count == 1){
                   let imageString = String(linkString) + "TN/001.jpg"
//                    print(imageString)
                    
                    elements.setObject(imageString, forKey: "image" as NSCopying)
                }
            
            }
            if dateString != ""{
                
                // １     2017-07-20T10:00:00+09:00
                // ０     Thu, 20 Jul 2017 10:36:00 +0900

                
                if (self.convery_count == 1){
                    
                    var date = ""
                    var date2 = ""
                    var date3 = ""
                    
                    
                    
                    
                    date = String(dateString).pregReplace(pattern: "20\\d\\d-", with: "")
//07-20T10:00:00+09:00
                    
                    
                    date2 = date.pregReplace(pattern: ":\\d\\d\\+\\d\\d:\\d\\d", with: "")
 //07-20T10:00
                  
                    
                    date3 = date2.pregReplace(pattern: "T", with: " ")
 //07-20 10:00
                
                    
                    elements.setObject(date3, forKey: "pubDate" as NSCopying)
                
                
                }
                else if (self.convery_count == 0){
                    var date = ""
                    var date2 = ""
                    var date3 = ""
                    var date4 = ""
                    var date5 = ""
                    var date6 = ""
                    var date_Set = ""
                    
                    
                    // ０     Thu, 20 Jul 2017 10:36:00 +0900
                    
                    date = String(dateString).pregReplace(pattern: "20\\d\\d", with: "")
                    //      Thu, 20 Jul  10:36:00 +0900
                    
                    date2 = date.pregReplace(pattern: "\\s", with: "")
                    //Thu,20Jul10:36:00+0900
                    
                    
                    date3 = date2.pregReplace(pattern: "...,|:\\d\\d\\+\\d\\d\\d\\d", with: "")
                    //20Jul10:36
                    

                   
                    date4 = date3.pregReplace(pattern: "\\d|:", with: "")
                    //Jul
                    

                    
                    
                    
                    switch date4 {
                    case "Jan":
                        date4 = "01"
                    case "Feb":
                        date4 = "02"
                    case "Mar":
                        date4 = "03"
                    case "Apr":
                        date4 = "04"
                    case "May":
                        date4 = "05"
                    case "Jun":
                        date4 = "06"
                    case "Jul":
                        date4 = "07"
                    case "Aug":
                        date4 = "08"
                    case "Sep":
                        date4 = "09"
                    case "Oct":
                        date4 = "10"
                    case "Nov":
                        date4 = "11"
                    case "Dec":
                        date4 = "12"
                    default:
                        break
                    }
                    
                    
                    
                    date5 = date3.pregReplace(pattern: "...\\d\\d:\\d\\d", with: "")
                    //20
                    
                    date6 = date3.pregReplace(pattern: "\\d\\d[[a-z]|[A-Z]]{3}", with: "")
                    //20Jul10:36
                    
                    
                    
                    date_Set = "\(date4)-\(date5) \(date6)"
                    
                    
                    //                    print("date---------->\(date_Set)")
                    
                    //                let formatter = DateFormatter()
                    //                formatter.dateFormat = "yyyy/MM/dd HH:mm:ss" //表示形式を設定
                    //
                    //                //現在時刻
                    //                let now = Date(timeIntervalSinceNow: 0) //"Dec 13, 2016, 4:10 PM"
                    //
                    //                //現在時刻を文字列で取得
                    //                let nowString = formatter.string(from: now) //"2016/12/13 16:10:31"
                    //
                    //                //文字列から日付を取得
                    //               let dateFromString = formatter.date(from: "2005/12/12 9:24:21")! //"Dec 12, 2005, 9:24 AM"
                    
                    elements.setObject(date_Set, forKey: "pubDate" as NSCopying)
                    
                    
                }else{
                    elements.setObject(dateString, forKey: "pubDate" as NSCopying)

                }
                
            }
            if (convery_count == 0) {
                
            
            if imageString != ""{
                
                
                var result:String = ""
                var result2:String = ""
                var result3:String = ""
                var result4:String = ""
                var result5:String = ""

                
                result = String(imageString).pregReplace(pattern: "\\s", with: "")
                result2 = result.pregReplace(pattern: "<imgsrc..", with: "")
                result3 = result2.pregReplace(pattern: ".jpg.alt.+<\\/p>", with: ".jpg")
                result4 = result3.pregReplace(pattern: ".png.alt.+<\\/p>", with: ".png")
                result5 = result4.pregReplace(pattern: ".jpeg.alt.+<\\/p>", with: ".jpeg")
                
//                imageString = (result3 as? NSMutableString)!

                print("image---------->\(imageString)")
                
                elements.setObject(result5, forKey: "image" as NSCopying)
                
            }
            }
            if titleString != "RSS_Check"{
                
                if titleString != "RSS_END"{
                    
//                   if ( !checkMovie(elements: elements) ) {
                    totalBox.add(elements)
                    
//                    }
                    }else{
                    
//                    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
//                    appDelegate.dataArray = self.dataArray
                    sortAndReloadData()
                    
                    
                }
            }
            
        }
        
        
    }
    
   
    //elements.value(forKey: "title")の中を選別をする
   
    let ok_words = ["事前登録","iOS版","Android版","配信開始","βテスト","配信スタート","新作アプリ","サービスイン","PV","提供開始","リリース","DLを突破"]
    
    
    func checkMovie(elements:NSMutableDictionary) -> Bool {
        let title:String = elements.value(forKey: "title") as! String
        
        var ok = true
        
        for word in ok_words {
            if ( title.contains(word) ) {
                ok = false
            }
        }
        return ok
    }

   
    
    
    func sortAndReloadData() {
        let dateDiscripter:NSSortDescriptor = NSSortDescriptor.init(key: "pubDate", ascending: false)
        let sortDescriptors:NSArray = [dateDiscripter]
        
        let data:NSArray = totalBox as NSArray
        
        dataArray = data.sortedArray(using: sortDescriptors as! [NSSortDescriptor]) as NSArray
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
    
        if self.dataArray != []{
        appDelegate.dataArray = self.dataArray
        }else{

            self.dataArray = appDelegate.dataArray
        }
        
       print("AAAAAAAAAAAAAAAAAA")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            
            self.refreshControl.endRefreshing()
             self.refresh_Chack = false
            self.tableView.reloadData()
            SVProgressHUD.dismiss()
        
    }
   
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if error == nil {
            print("ダウンロードが完了しました")
        } else {
            convery_count -= 1
            print("ダウンロードが失敗しました")
        }
        
    }
    
    
    
    
    func showAlert(newsTitle:String,newsLink:String,newsDate:String,newsUrl:String,newsLink_Name:String) {
        let alertViewControler = UIAlertController(title: "この記事をお気に入り登録しますか？", message: "「ホーム」→「お気に入り」\nより閲覧が可能となります", preferredStyle:.actionSheet)
        let okAction = UIAlertAction(title: "お気に入りに追加", style: .default, handler:{
            (action:UIAlertAction!) -> Void in
            self.addFavorite(newsTitle:newsTitle,newsLink:newsLink,newsDate:newsDate,newsUrl:newsUrl,newsLink_Name: newsLink_Name)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alertViewControler.addAction(okAction)
        alertViewControler.addAction(cancelAction)
        present(alertViewControler, animated: true, completion: nil)
        
    }
    
    func addFavorite(newsTitle:String,newsLink:String,newsDate:String,newsUrl:String,newsLink_Name:String) {
        
        
        app_newsTitleArray.append(newsTitle)
        UserDefaults.standard.set(app_newsTitleArray, forKey: "app_newsTitleArray")
        
        app_newsLinkArray.append(newsLink)
        UserDefaults.standard.set(app_newsLinkArray, forKey: "app_newsLinkArray")
        
        app_newsDateArray.append(newsDate)
        UserDefaults.standard.set(app_newsDateArray, forKey: "app_newsDateArray")
        
        app_newsUrlArray.append(newsUrl)
        UserDefaults.standard.set(app_newsUrlArray, forKey: "app_newsUrlArray")
        
        app_newsLink_NameArray.append(newsLink_Name)
        UserDefaults.standard.set(app_newsLink_NameArray, forKey: "app_newsLink_NameArray")
        
        
        SVProgressHUD.showSuccess(withStatus: "お気に入りに\n追加しました")
    }
    
    func favoriteButton(sender: UIButton, event:UIEvent){
        
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        let newsTitle = (dataArray[(indexPath?.row)!] as AnyObject).value(forKey: "title") as? String
        let newsLink = (dataArray[(indexPath?.row)!] as AnyObject).value(forKey: "link") as? String
        let newsDate = (dataArray[(indexPath?.row)!] as AnyObject).value(forKey: "pubDate") as? String
        let newsUrl = (dataArray[(indexPath?.row)!] as AnyObject).value(forKey: "image") as? String
        let newsLink_Name = (dataArray[(indexPath?.row)!] as AnyObject).value(forKey: "link_Name") as? String
        
    
        
        
        for i in app_newsLinkArray {
            if i == newsLink{
                SVProgressHUD.showError(withStatus: "この記事はお気に入りに登録済みです")
                return
            }
        }
        
        showAlert(newsTitle:newsTitle!,newsLink:newsLink!,newsDate:newsDate!,newsUrl:newsUrl!,newsLink_Name: newsLink_Name!)
    }
    
    
    
    
    
    func support() {
        
        
        
        let support_ViewController = self.storyboard?.instantiateViewController(withIdentifier: "support") as! Support_ViewController
        self.navigationController?.pushViewController(support_ViewController, animated: true)
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


//var alphabet = "title=ABCDE&body=FGHIJ"
//
//if alphabet.pregMatche(pattern: "ABCDE") {
//    print("match")  // martch
//}else{
//    print("not match")
//}
//
//var hoge: [String] = []
//_ = alphabet.pregMatche(pattern: "^title=.*&body", matches: &hoge)
//print(hoge)  // ["title=ABCDE&body"]
//
//
//let fuga = alphabet.pregReplace(pattern: "^title=.*&body", with: "title=abcde&body")
//print(fuga)  // title=abcde&body=FGHIJ
//
////コンテントエンコーデっど
