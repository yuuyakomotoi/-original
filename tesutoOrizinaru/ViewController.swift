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


class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,XMLParserDelegate,URLSessionDownloadDelegate{
    
    
    var auto_Reload_Check = false
    
    let refreshControl = UIRefreshControl()
    
    var refresh_Chack = false
    
    var rss_data:String = ""
    var rss_data2:String = ""
    var rss_data3:String = ""
    
    var convery_count = 0
    
    var parser:XMLParser? = XMLParser()
    
    var data:NSData? = NSData()
    var data2:NSData? = NSData()
    var data3:NSData? = NSData()
    
    
    
    
    var totalBox = NSMutableArray()
    
    var elements = NSMutableDictionary()
    
    var element = String() //　タイトルが入ったり、リンクが入ったりする
    
    var titleString = NSMutableString() //キー値を決めて取り出したり、セットしたりする
    
    var linkString = NSMutableString()
    
    var link_Name = String()
    
    var dateString = NSMutableString()
    
    var imageString = NSMutableString()
    
    
     let urlArray = ["http://shironekotennisms.net/feed","http://shironekotennis-kouryaku.xyz/feed",""]//URLリスト
    
    
    var dataArray = NSArray()
    
    //お気に入りに登録用の配列
    var newsTitleArray:[String] = []
    var newsLinkArray:[String] = []
    var newsDateArray:[String] = []
    var newsUrlArray:[String] = []
    var newsLink_NameArray:[String] = []
    
    
    //Firebase関連
    var userId:String = ""
    
    var items:[BBS_PostData1] = []
    var items2:[BBS_PostData1] = []
    var items3:[BBS_PostData1] = []
    var items4:[BBS_PostData1] = []
    
    
    var id:[BBS_PostData1] = []
    
    @IBOutlet var tableView: UITableView!
    
    
    
    
    
    //ストリング型でもいい
    
    
    //バージョン管理
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().tintColor = UIColor(red: 1, green: 0.6, blue: 0, alpha: 1)
        
        
        
        if totalBox == []{
            SVProgressHUD.show()
        }
        
        
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
        
        
        
    
        
        
        loadAllData()
      
        
        
        
        //引っ張って更新
      
        
        refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refreshControl.addTarget(self, action:#selector(delay), for:UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        convery_count = urlArray.count
        
        for url_string in urlArray{
            download_rss(url_str: url_string)
            
        }
        
        
       
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if totalBox != []{
        SVProgressHUD.dismiss()
        }
        
        
        userId = UserDefaults.standard.object(forKey: "userId") as! String
        print("---------------->>>\(userId)")
        
        
        
        if UserDefaults.standard.object(forKey: "newsTitleArray") != nil{
            
            
            
            newsTitleArray = UserDefaults.standard.object(forKey: "newsTitleArray") as! [String]
            
            newsLinkArray = UserDefaults.standard.object(forKey: "newsLinkArray") as! [String]
            
            newsDateArray = UserDefaults.standard.object(forKey: "newsDateArray") as! [String]
            
            newsUrlArray = UserDefaults.standard.object(forKey: "newsUrlArray") as! [String]
            
            newsLink_NameArray = UserDefaults.standard.object(forKey: "newsLink_NameArray") as! [String]
            
            
        }
        
        
        
    }
    
    //navBarImage.png
    //タブバーいずひぢゅん
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let navBarImage = UIImage(named: "navBarImage.png") as UIImage?
        self.navigationController?.navigationBar.setBackgroundImage(navBarImage,for:.default)
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        
        tableView.reloadData()
        
   
    }
    
    //引っ張って更新メソッド
    //引っ張って更新メソッドの時にもパースしたものを更新したいので上のコードをメソッドの中に入れる
    
    
    func delay(){
        
        if refresh_Chack == false{
//        totalBox = []
//            dataArray = []
            refresh_Chack = true
        convery_count = urlArray.count
        
        for url_string in urlArray{
            download_rss(url_str: url_string)
            
            }
            tableView.reloadData()
            }else{
            

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
        
        self.tabBarController?.tabBar.isHidden = true
        
        let newsModalViewController = self.storyboard?.instantiateViewController(withIdentifier: "news") as! NewsModalViewController
        
        let linkURL = (dataArray[indexPath.row] as AnyObject).value(forKey: "link") as? String
        newsModalViewController.str = linkURL!
        
        //navigationControllerをstoryboardでセットしてから使う
        
        self.navigationController?.pushViewController(newsModalViewController, animated: true)
        
        
    }
    
    
    func download_rss(url_str:String){
        // 通信のコンフィグを用意.
        let config: URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        // Sessionを作成する.
        let session: URLSession = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        
        // ダウンロード先のURLからリクエストを生成.
        let url:NSURL = NSURL(string: url_str)!
        let request: URLRequest =  URLRequest(url: url as URL)
        
        // ダウンロードタスクを生成.
        let myTask: URLSessionDownloadTask = session.downloadTask(with: request)
        
        // タスクを実行.
        myTask.resume()
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        
        print("finish download")
        
        var data: NSData!
        
        do {
            data = try NSData(contentsOf: location, options: NSData.ReadingOptions.alwaysMapped)
        } catch {
            print(error)
        }
        
        let rss = String(data: data as Data, encoding: .utf8)!
        
        
        ///rss入れた
        //メソッド作る
        
        
        convertRSS(rss:rss)
        
    }
    
    func convertRSS(rss:String){
        
      
        
        
        // 正規表現に置き換える
        
        var result:String = ""
        var result2:String = ""
        var result3:String = ""
        var result4:String = ""
        var result5:String = ""
        var result6:String = ""
        var result7:String = ""
        
        
        
        convery_count -= 1
        
        
        if convery_count == 1{
            print(convery_count)
            //     ///////
            //            ///
            //            ////
            //            ///
            //            ///
            //           result = rss
            //
            ////            result = rss.pregReplace(pattern: "<\\?xml.+\\s\\s.+\\s.+\\s.+\\s.+\\s.+\\s.+\\s.+\\s.+\\s\\s.+\\s.+\\s.+\\s.+\\s.+\\s.+\\s.+\\s.+\\s.+\\s.+\\s.+\\s.+\\s.+\\s.+\\s.+|<rdf.+|<dc:language>.+\\s.+\\s.+\\s.+\\s.+\\s.+\\s.+\\s.+\\s.+|<\\/rdf:Seq>\\s.+\\s.+\\s.+\\s.+\\s.+\\s.+(\\s|.).+|<description><\\/description>|<description>\\s.+\\s<\\/description>|</rdf:Seq>\\s.+\\s.+\\s\\s.+\\s.+\\s.+\\s.+\\s.+|</image>|<description>\\s\\s.+", with: "")
            ////
            ////            result2 = rss.pregReplace(pattern: "<item.+", with: "<item>")
            ////
            //           result3 = result.pregReplace(pattern: "dc:date", with: "pubDate")
            ////
            ////            result4 = result3.pregReplace(pattern: "<\\/rdf:RDF>", with: "")
            ////
            //            result5 = result3.pregReplace(pattern: "\\t|\\n|\\[ 　]", with: "")
            //
            //
            //
            //
            //result = rss
            //        rss_data += result
            //
            result = rss
            
            
            
            
            
            
            
            result2 = result.pregReplace(pattern: "<description>.+src=.", with: "\\\t<image>")
            
            result3 = result2.pregReplace(pattern: "jpeg\\n\\t", with: "jpeg")
            
            result4 = result3.pregReplace(pattern: "jpeg\" class=\"", with: "jpeg<\\/image><description><\\!\\[CDATA\\[")
            
            
            result5 = result4.pregReplace(pattern: "\n\t\t", with: "")
            
            result6 = result5.pregReplace(pattern: "<\\/rss>", with: "\\\t<item>\\\t<title>RSS_Check<\\/title><\\/item><\\/ rss>")
            
            
            
//            print(result5.debugDescription)
            
            
            
            rss_data += result6
        }else if convery_count == 0{
            print(convery_count)
            //
            //            result = rss.pregReplace(pattern: "<\\/script>", with: "")
            //
            //            result2 = result.pregReplace(pattern: "\\<\\?xml[.\\s]*.+[\\s]+[.\\s]+xmlns:content=.+\\s+.+.+\\s+.+.+\\s+.+.+\\s+.+.+\\s+.+m.+\\s.+|<channel>[.\\s]*.+\\s*.+[.\\s]*.+\\s*.+\\s.+\\s.+\\s.+\\s.+\\s.+tor>|<image>[.\\s]*.+\\s*.+[.\\s]*.+[.\\s]*.+[.\\s]*.+[.\\s]*.+[.\\s]*.+site>|<comments>.+[comments>.]|<h6.+|<p><strong>.+<\\/p>|<span.+|\\].+content:encoded>|<wfw:commentRss>.+[wfw:commentRss>.]|<slash:comments>.+[slash:comments>.]|<post-id.+id>|<\\/channel>|<\\/rss>.*|<category>.+[category>.]|<dc:creator>.+[creator>.]|<ins.+\\s+.+\\s+.+\\s+.+<\\/ins>|resize.+<\\/p>|<p>[^<].+<\\/p>|<guid.+[guid>.]|<description>.+[description>.]|<content:encoded>.+image-\\d{0,6}\"|<p>\\<.+<\\/p>|<!--.+-->|<\\/blockquote>|<blockquote.+|<strong>|<p>|<script.+|.adsbygoogle.+", with: "")
            //
            result = rss
            
            
            result2 = result.pregReplace(pattern: "<content:encoded>.+class.{30,50}src..", with: "\\\t<image>")
            
            result3 = result2.pregReplace(pattern: "resize.+|<p><img.+", with: "")
            
            result4 = result3.pregReplace(pattern: "jpg\\?", with: "jpg\\?</image><content:encoded><!\\[CDATA\\[")
            
            result5 = result4.pregReplace(pattern: "jpeg\\?", with: "jpeg\\?</image><content:encoded><!\\[CDATA\\[")
            
            result6 = result5.pregReplace(pattern: "\n\t\t", with: "")
            
            result7 = result6.pregReplace(pattern: "<\\/rss>", with: "\\\t<item>\\\t<title>RSS_END<\\/title><\\/item><\\/ rss>")

            
            
            
            
            /*<content:encoded><!\\[CDATA\\[などの[CDATA\\[に問題があった。
             //[CDATA\\[の中にイメージがあったため取り出すことができなかった。
             <content:encoded>を<image>に変えて</image>で閉じた後に<content:encoded><!\\[CDATA\\[をずらして書くことで、上手くいった。
             */
            
            
            
            
            
            
            rss_data2 += result7
            
//            print(result7.debugDescription)
            
            self.data = self.rss_data.data(using: String.Encoding.utf8)! as NSData
            self.data2 = self.rss_data2.data(using: String.Encoding.utf8)! as NSData
            
            
            //            let formatter = DateFormatter()
            //            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss" //表示形式を設定
            //
            //            //現在時刻
            //            let now = Date(timeIntervalSinceNow: 0) //"Dec 13, 2016, 4:10 PM"
            //
            //            //現在時刻を文字列で取得                   nouにデートストリング入れる
            //            let nowString = formatter.string(from: now) //"2016/12/13 16:10:31"
            //
            //            //文字列から日付を取得
            //            let dateFromString = formatter.date(from: "2005/12/12 9:24:21")! //"Dec 12, 2005, 9:24 AM"
            
            
            //print(self.rss_data2)
            //print(rss_data.debugDescription)
            //print(data.debugDescription)
            
            for i in 0...1{
                if i == 0 {self.parser = XMLParser(data: self.data as! Data)
                    if self.parser != nil {
                        
                        self.totalBox = []
                        self.dataArray = []
                        
                        convery_count = 1
                        
                        self.parser!.delegate = self
                        self.parser!.parse()
                        
                        print("パース成功")
                    } else {
                        // パースに失敗した時
                        print("パース失敗")
                    }
                    
                }else{
                    self.parser = XMLParser(data: self.data2 as! Data)
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
            
            print("itemを見つけた")
            
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
            
            print("titleを見つけた")
            
            titleString.append(string)
            
            
            
            
        }else if element == "link"{
            
            print("linkを見つけた")
            
            linkString.append(string)
        }
        else if element == "pubDate"{
            
            print("pubDateを見つけた")
            
            dateString.append(string)
        }
        else if element == "image"{
            
            print("imageを見つけた")
            
            imageString.append(string)
        }

    }
    
    //タグの終了を見つけた時
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?){
        
        //itemという要素の中にあるなら
        if elementName == "item"{
            
            if titleString != ""{
                
                print("title---------->\(titleString)")
                elements.setObject(titleString, forKey: "title" as NSCopying)
            
                if (self.convery_count == 1){
                    link_Name = "白猫テニス攻略まとめ！ダグラス速報"
                elements.setObject(link_Name, forKey: "link_Name" as NSCopying)
                }else if (self.convery_count == 0){
                    link_Name = "白猫テニスまとめ速報"
                elements.setObject(link_Name, forKey: "link_Name" as NSCopying)
                }
                
            }
            if linkString != "" {
                //elementsにキー値を付与しながらtitleString(linkStrung)をセットする
                print("link---------->\(linkString)")
                elements.setObject(linkString, forKey: "link" as NSCopying)
            }
            if dateString != ""{
               
                if (self.convery_count == 1)||(self.convery_count == 0){

                var date = ""
                
//                var date1 = ""
                var date2 = ""
                var date3 = ""
                var date3_2 = ""
                var date3_3 = ""
                var date3_4 = ""
                var date4 = ""
                var date5 = ""
                var date_Set = ""
                
                date = String(dateString).pregReplace(pattern: "\\s|,", with: "")
                
                
//     サンプル     Mon03Jul201701:00:38+0000
               
                
//                date1 = String(date).pregReplace(pattern: "[a-z|A-Z]{3}\\d\\d[a-z|A-Z]{3}|.........0000", with: "")
                //2017
                
                
                    date2 = date.pregReplace(pattern: "[a-zA-Z]{3}|\\d{4}\\d\\d:\\d\\d:\\d\\d\\+0000", with: "")
                //日　03
               
                date3 = date.pregReplace(pattern: "[a-z|A-Z]{3}\\d\\d[a-z|A-Z]{3}\\d\\d\\d\\d|:\\d\\d\\+0000", with: "")
                //日時　09:10
                
                date3_2 = date3.pregReplace(pattern: ":..", with: "")
                //　09
                    
                    switch date3_2 {
                    case "00":
                        date3_2 = "08"
                    case "01":
                        date3_2 = "09"
                    case "02":
                        date3_2 = "10"
                    case "03":
                        date3_2 = "11"
                    case "04":
                        date3_2 = "12"
                    case "05":
                        date3_2 = "13"
                    case "06":
                        date3_2 = "14"
                    case "07":
                        date3_2 = "15"
                    case "08":
                        date3_2 = "16"
                    case "09":
                        date3_2 = "17"
                    case "10":
                        date3_2 = "18"
                    case "11":
                        date3_2 = "19"
                    case "12":
                        date3_2 = "20"
                    case "13":
                        date3_2 = "21"
                    case "14":
                        date3_2 = "22"
                    case "15":
                        date3_2 = "23"
                    case "16":
                        date3_2 = "00"
                    case "17":
                        date3_2 = "01"
                    case "18":
                        date3_2 = "02"
                    case "19":
                        date3_2 = "03"
                    case "20":
                        date3_2 = "04"
                    case "21":
                        date3_2 = "05"
                    case "22":
                        date3_2 = "06"
                    case "23":
                        date3_2 = "07"
                    default:
                        break
                    }
               
                    
                    date3_3 = date3.pregReplace(pattern: "..:", with: ":")
                    print("date---------->\(date3_3)")

                //日時　:10
                    
                date4 = date.pregReplace(pattern: "\\d{4}\\d\\d:\\d\\d:\\d\\d\\+0000", with: "")
                date5 = date4.pregReplace(pattern: "[a-zA-Z]{3}\\d\\d", with: "")
                //月
                
                switch date5 {
                case "Jan":
                    date5 = "01"
                case "Feb":
                    date5 = "02"
                case "Mar":
                    date5 = "03"
                case "Apr":
                    date5 = "04"
                case "May":
                    date5 = "05"
                case "Jun":
                    date5 = "06"
                case "Jul":
                    date5 = "07"
                case "Aug":
                    date5 = "08"
                case "Sep":
                    date5 = "09"
                case "Oct":
                    date5 = "10"
                case "Nov":
                    date5 = "11"
                case "Dec":
                    date5 = "12"
                default:
                    break
                }
                
                date_Set = "\(date5)-\(date2) \(date3_2)\(date3_3)"
                
                    print("date---------->\(date_Set)")
                
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
                }
                else{
                    elements.setObject(dateString, forKey: "pubDate" as NSCopying)

                }
            
            }
            if imageString != ""{
                print("image---------->\(imageString)")
                
                elements.setObject(imageString, forKey: "image" as NSCopying)
                
            }
            
            if titleString != "RSS_Check"{
            
            if titleString != "RSS_END"{
                totalBox.add(elements)

            }else{
                sortAndReloadData()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                   self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    self.refresh_Chack = false
                    SVProgressHUD.dismiss()
                print(self.totalBox.debugDescription)
                }

                            }
            }
           
        }
        
       
    }
    
    func sortAndReloadData() {
        let dateDiscripter:NSSortDescriptor = NSSortDescriptor.init(key: "pubDate", ascending: false)
        let sortDescriptors:NSArray = [dateDiscripter]
        
        let data:NSArray = totalBox as NSArray
        
        dataArray = data.sortedArray(using: sortDescriptors as! [NSSortDescriptor]) as NSArray
      
        
        /////////
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
        self.tableView.reloadData()
        print("dataArray------->\(self.dataArray.description)")
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
        
        
        newsTitleArray.append(newsTitle)
        UserDefaults.standard.set(newsTitleArray, forKey: "newsTitleArray")
        
        newsLinkArray.append(newsLink)
        UserDefaults.standard.set(newsLinkArray, forKey: "newsLinkArray")
        
        newsDateArray.append(newsDate)
        UserDefaults.standard.set(newsDateArray, forKey: "newsDateArray")
        
        newsUrlArray.append(newsUrl)
        UserDefaults.standard.set(newsUrlArray, forKey: "newsUrlArray")
        
        newsLink_NameArray.append(newsLink_Name)
        UserDefaults.standard.set(newsLink_NameArray, forKey: "newsLink_NameArray")

        
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

       
        
        
        for i in newsLinkArray {
            if i == newsLink{
                SVProgressHUD.showError(withStatus: "この記事はお気に入りに登録済みです")
                return
            }
        }
        
        showAlert(newsTitle:newsTitle!,newsLink:newsLink!,newsDate:newsDate!,newsUrl:newsUrl!,newsLink_Name: newsLink_Name!)
    }
    
    //    override func prepare(for segue:UIStoryboardSegue, sender:Any?){
    //        let newsModalViewController:NewsModalViewController = segue.destination as! NewsModalViewController
    //        NewsModalViewController.url =  ""
    
    
    
    
    func loadAllData(){
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
            let firebase = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "0")
            firebase.queryLimited(toLast: 50).observe(.value) { (snapshot,error) in
                
                if self.auto_Reload_Check == true{
                    
                    return
                }
                
                self.auto_Reload_Check = true
                
                
                
                for item in(snapshot.children){
                    let child = item as! FIRDataSnapshot
                    let postData = BBS_PostData1(snapshot: child, myId: "")
                    
                    let data = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: postData.id)
                    data.observe(.value) { (snapshot,error) in
                        
                        for item in(snapshot.children){
                            let child = item as! FIRDataSnapshot
                            let postData = BBS_PostData1(snapshot: child, myId: "")
                            self.id.append(postData)
                    
                            let appDelegate_id:AppDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate_id.id = self.id
                        }
                        
                        
                    }

                    
                    
                    self.items.append(postData)
                    }
                
                self.items.reverse()
    
}
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
         appDelegate.items = self.items
        
        
        let firebase2 = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "1")
        firebase2.queryLimited(toLast:50).observe(.value) { (snapshot,error) in
            
            if self.auto_Reload_Check == true{
                
                return
            }
            
            self.auto_Reload_Check = true
            
            
            
            for item in(snapshot.children){
                let child = item as! FIRDataSnapshot
                let postData = BBS_PostData1(snapshot: child, myId: "")
                self.items2.append(postData)
            }
            
            self.items2.reverse()
            
        }
        
        let appDelegate2:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate2.items2 = self.items2

        
        let firebase3 = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "2")
        firebase3.queryLimited(toLast:50).observe(.value) { (snapshot,error) in
            
            if self.auto_Reload_Check == true{
                
                return
            }
            
            self.auto_Reload_Check = true
            
            
            
            for item in(snapshot.children){
                let child = item as! FIRDataSnapshot
                let postData = BBS_PostData1(snapshot: child, myId: "")
                self.items3.append(postData)
            }
            
            self.items3.reverse()
            
        }
        
        let appDelegate3:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate3.items3 = self.items3

        
        let firebase4 = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "3")
        firebase4.queryLimited(toLast:50).observe(.value) { (snapshot,error) in
            
            if self.auto_Reload_Check == true{
                
                return
            }
            
            self.auto_Reload_Check = true
            
            
            
            for item in(snapshot.children){
                let child = item as! FIRDataSnapshot
                let postData = BBS_PostData1(snapshot: child, myId: "")
                self.items4.append(postData)
            }
            
            self.items4.reverse()
            
        }
        
        let appDelegate4:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate4.items4 = self.items4

        
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension String {
    //絵文字など(2文字分)も含めた文字数を返します
    var count:Int{
        let string_NS = self as NSString
        return string_NS.length
    }
    
    //正規表現の検索をします
    func pregMatche(pattern: String, options: NSRegularExpression.Options = []) -> Bool {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        let matches = regex.matches(in: self, options: [], range: NSMakeRange(0, self.count))
        return matches.count > 0
    }
    
    //正規表現の検索結果を利用できます
    func pregMatche(pattern: String, options: NSRegularExpression.Options = [], matches: inout [String]) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return false
        }
        let targetStringRange = NSRange(location: 0, length: self.count)
        let results = regex.matches(in: self, options: [], range: targetStringRange)
        for i in 0 ..< results.count{
            for j in 0 ..< results[i].numberOfRanges{
                let range = results[i].rangeAt(j)
                matches.append((self as NSString).substring(with: range))
            }
        }
        return results.count > 0
    }
    
    //正規表現の置換をします
    func pregReplace(pattern: String, with: String, options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [], range: NSMakeRange(0, self.count), withTemplate: with)

}

    
    func toDate(dateFormat:String) -> Date?{
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        return formatter.date(from: self)
    }
    
}

extension Date{
    
    func toString(dateFormat:String) -> String? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        return formatter.string(from: self)
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
