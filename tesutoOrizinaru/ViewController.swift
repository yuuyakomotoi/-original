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
    
//    var refresh_Chack = false
    
    
    
    
    
    var convery_count = 10
    
    var parser:XMLParser? = XMLParser()
    
    var data:NSData? = NSData()
    var data2:NSData? = NSData()
    var data3:NSData? = NSData()
    
    
    
    var rss:String?
    
    var totalBox = NSMutableArray()
    
    var elements:NSMutableDictionary? = NSMutableDictionary()
    
    var element = String() //　タイトルが入ったり、リンクが入ったりする
    
    var titleString = NSMutableString() //キー値を決めて取り出したり、セットしたりする
    
    var linkString = NSMutableString()
    
    var link_Name = String()
    
    var dateString = NSMutableString()
    
    var imageString = NSMutableString()
    
    //お知らせ用
    var notice_Image = UIBarButtonItem()
    var notice_Array:[String] = []
    
    
    //お知らせ用&マルチのカテゴリー配列
    
    var o_TitleArray:[String] = []
    var o_DateArray:[String] = []
    var o_ContentArray:[String] = []
    var o_MultiArray:[String] = []
    
    
    var o_ContentString = NSMutableString()
    var o_MultiString = NSMutableString()

    
    
    //http://2chmatomeru.info/entries/index.rss
   // http://xn--zckzap0809doqd.jp/feed/
     let urlArray = ["http://shironekotennisms.net/feed","http://xn--zckzap0809doqd.jp/feed/","http://iosapp01.blog.fc2.com/?xml"]//URLリスト
    
    
    var dataArray = NSArray()
    
    var download_Check = true
    
    //お気に入りに登録用の配列
    var newsTitleArray:[String] = []
    var newsLinkArray:[String] = []
    var newsDateArray:[String] = []
    var newsUrlArray:[String] = []
    var newsLink_NameArray:[String] = []
    
    
    //Firebase関連
    var userId:String = ""
    
    var items:[BBS_PostData1] = []
    
    var config: URLSessionConfiguration?
    
    @IBOutlet var tableView: UITableView!
    
    
    
    
    
    
    //ストリング型でもいい
    
    
    //バージョン管理
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        config = URLSessionConfiguration()
        
                
        UITabBar.appearance().tintColor = UIColor(red: 1, green: 0.6, blue: 0, alpha: 1)
        
       self.totalBox = []
        
        if totalBox == []{
            SVProgressHUD.show()
        }
        
        loadAllData()
        
        for url_string in urlArray{
            download_rss(url_str: url_string)
            
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
        
        
        
    
        
        
       
      
        
        
        
        //引っ張って更新
      
        
        refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refreshControl.addTarget(self, action:#selector(refresh), for:UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
       
       
        
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        
        
        if (download_Check == false){
            if totalBox == []{
                SVProgressHUD.dismiss()
            }
        }
       
        if UserDefaults.standard.object(forKey: "notice_Array") != nil{
        notice_Array = UserDefaults.standard.object(forKey: "notice_Array") as! [String]
        }else{
            
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
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController!.interactivePopGestureRecognizer!.isEnabled = true

        if (download_Check == false){
         if totalBox == []{
            SVProgressHUD.dismiss()
        }
        }
        
        
        
        
       
        
//        self.totalBox = []
        
        
        

//        if self.dataArray2 != []{
//            if self.dataArray != self.dataArray2{
//            self.dataArray = []
//                self.dataArray = self.dataArray2
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                   self.tableView.reloadData()
//                }
//                
//            
//            }
//            }
        
        
        //        if(self.dataArray.count != 20){
//        convery_count = urlArray.count
//            self.totalBox = []
//            self.dataArray = []
//        for url_string in urlArray{
//            download_rss(url_str: url_string)
//            
//        }
//        }
        
   
    }
    
    //引っ張って更新メソッド
    //引っ張って更新メソッドの時にもパースしたものを更新したいので上のコードをメソッドの中に入れる
    
    func refresh(){
        self.totalBox = []
         o_TitleArray = []
         o_DateArray = []
        o_ContentArray = []
         o_MultiArray = []
        perform(#selector(delay), with: nil, afterDelay: 0.5)
    }
    
    
    func delay(){
        
        
        for url_string in urlArray{
            download_rss(url_str: url_string)
            
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
        }else{
            
        }
        
        if (( (dataArray[indexPath.row] as AnyObject).value(forKey: "link_Name") ) != nil) {
        linkLabel.text = (dataArray[indexPath.row] as AnyObject).value(forKey: "link_Name") as? String
        }else{
            
        }
       
        if (( (dataArray[indexPath.row] as AnyObject).value(forKey: "pubDate") ) != nil) {
        dateLabel.text = (dataArray[indexPath.row] as AnyObject).value(forKey: "pubDate") as? String
        }else{
            
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

        config = URLSessionConfiguration()
        
        config = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        
        //        let config: URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
//        
        
        config?.timeoutIntervalForRequest = 5
        config?.timeoutIntervalForResource = 5
        
        
        if (config != nil){
        
        // Sessionを作成する.
        let session:URLSession? = URLSession(configuration: config!, delegate: self, delegateQueue: nil)
        
        
        // ダウンロード先のURLからリクエストを生成.
        let url:NSURL = NSURL(string: url_str)!
        let request: URLRequest =  URLRequest(url: url as URL)
        
        
        
            // ダウンロードタスクを生成.
            let myTask: URLSessionDownloadTask = (session?.downloadTask(with: request))!
            
            
            // タスクを実行.
            myTask.resume()
        
        
        }
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        
        print("finish download")
        
        var data: NSData!
        
        
        
        do {
            data = try NSData(contentsOf: location, options: NSData.ReadingOptions.alwaysMapped)
            
            if data != nil{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.rss = String(data: data as Data, encoding: .utf8)!
                    
                    //ここ
                    
                    
                    ///rss入れた
                    //メソッド作る
                    
                    
                    //ここ
                    self.convertRSS(rss:self.rss!)
                }

            }
            
                     } catch {
            print(error)
        }
        
        
       
        
    }
    
    func convertRSS(rss:String){
        
      
        
        
        // 正規表現に置き換える
        
        
        if rss.pregMatche(pattern: ".link.http...xn--zckzap0809doqd.jp..link."){
          
            var result:String = ""
            var result2:String = ""
            var result3:String = ""
            var rss_data3:String = ""
            data3 = NSData()
            
            result = rss
            
            
            
            
            
            result2 = result.pregReplace(pattern: "\n\t\t", with: "")
            
            result3 = result2.pregReplace(pattern: "<\\/rss>", with: "\\\t<item>\\\t<title>RSS_Check<\\/title><\\/item><\\/ rss>")
            
            
            rss_data3 += result3
            
            print(rss_data3)
            
            data3 = rss_data3.data(using: String.Encoding.utf8)! as NSData
            
            parser = XMLParser(data: data3! as Data)
            if parser != nil {
                
                
                
                convery_count = 2
                
                parser!.delegate = self
                parser!.parse()
                
                print("パース成功")
            } else {
                // パースに失敗した時
                print("パース失敗")
            }
        
        }else if rss.pregMatche(pattern: ".link.http...shironekotennisms.net") {
            print(convery_count)
            
            
            var result2:String = ""
           
            
            var rss_data2:String = ""
            data2 = NSData()
            
            
            
            result2 = rss.pregReplace(pattern: "\n\t\t", with: "")
            
            
            
            
            rss_data2 += result2
            
            
            
            data2 = rss_data2.data(using: String.Encoding.utf8)! as NSData
            
            
            
            
            parser = XMLParser(data: data2! as Data)
            if parser != nil {
                
                convery_count = 1
                
                parser!.delegate = self
                parser!.parse()
                print("パース成功")
            } else {
                // パースに失敗した時
                print("パース失敗")
                
            }
            
          }else if rss.pregMatche(pattern: "http...iosapp01.blog.fc2.com") {
        
            var result:String = ""
            var result2:String = ""
            var result3:String = ""
            var rss_data:String = ""
            data = NSData()
            
            result = rss
            
            
            result2 = result.pregReplace(pattern: "dc:date", with: "pubDate")
            
            result3 = result2.pregReplace(pattern: "\\<\\!\\[CDATA\\[|\\]\\]\\>", with: "")
            
//           result4 = result3.pregReplace(pattern: "<\\/rdf:RDF>", with: "\\\t<item>\\\t<title>RSS_END<\\/title><\\/item><\\/rdf:RDF>")
            
            
            rss_data += result3
            
            print(rss_data)
            
            data = rss_data.data(using: String.Encoding.utf8)! as NSData
            
            parser = XMLParser(data: data! as Data)
            if parser != nil {
                
                
                
                convery_count = 0
                
                parser!.delegate = self
                parser!.parse()
                
                print("パース成功")
            } else {
                // パースに失敗した時
                print("パース失敗")
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
            o_ContentString = NSMutableString()
            o_ContentString = ""
            o_MultiString = NSMutableString()
            o_MultiString = ""
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
       
       
        else if element == "content:encoded"{
               
            if(convery_count != 0){
            //画像
                imageString.append(string)
            }else{
               //お知らせ内容
                o_ContentString.append(string)
           
            }
       
            //マルチ用の配列
        }else if element == "dc:subject"{
            if (convery_count == 0){
                o_MultiString.append(string)
            
            
            }
        }
        
        
        
    }
    
    //タグの終了を見つけた時
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?){
        
        //itemという要素の中にあるなら
        if elementName == "item"{
            
            if titleString != ""{
                
                print("title---------->\(titleString)")
               
                if(convery_count != 0){
                elements?.setObject(titleString, forKey: "title" as NSCopying)
                }else{
                   //\nが入る
                    o_TitleArray.append(titleString as String)
               
                }
                
                
                if (convery_count == 2){
                    link_Name = "白猫テニス徹底攻略ガイド"
                elements?.setObject(link_Name, forKey: "link_Name" as NSCopying)
                }else if (convery_count == 1){
                    link_Name = "白猫テニスまとめ速報"
                elements?.setObject(link_Name, forKey: "link_Name" as NSCopying)
                }
                
            }
            if linkString != "" {
                //elementsにキー値を付与しながらtitleString(linkStrung)をセットする
                   if(convery_count != 0){
                elements?.setObject(linkString, forKey: "link" as NSCopying)
                }
                }
            if dateString != ""{
               
                if (convery_count == 2)||(convery_count == 1){

                
                    
                var date = ""
                
//                var date1 = ""
                var date2 = ""
                var date3 = ""
                var date3_2 = ""
                var date3_3 = ""
              
                var date4 = ""
                var date5 = ""
                var date_Set = ""
                
                let day_count = 1
                    
                    
                date = String(dateString).pregReplace(pattern: "\\s|,", with: "")
                
                
//     サンプル     Mon03Jul201701:00:38+0000
               
                
//                date1 = String(date).pregReplace(pattern: "[a-z|A-Z]{3}\\d\\d[a-z|A-Z]{3}|.........0000", with: "")
                //2017
                    //<pubDate>Sat,05Aug201707:00:09+0000</pubDate>
                    //<pubDate>Wed, 02 Aug 2017 21:00:38 +0000</pubDate>
                    //<pubDate>Fri, 04 Aug 2017 14:11:42 +0000</pubDate>
                
                    
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
                //08-13 09:05
                    
                    if date3_2 == "00" || date3_2 == "01" || date3_2 == "02" || date3_2 == "03" || date3_2 == "04" || date3_2 == "05" || date3_2 == "06" || date3_2 == "07"{
                     
                        
                        

                        func dd(){
                            switch date2 {
                            case "01":
                                date2 = "02"
                            case "02":
                                date2 = "03"
                            case "03":
                                date2 = "04"
                            case "04":
                                date2 = "05"
                            case "05":
                                date2 = "06"
                            case "06":
                                date2 = "07"
                            case "07":
                                date2 = "08"
                            case "08":
                                date2 = "09"
                            case "09":
                                date2 = "10"
                            case "10":
                                date2 = "11"
                            case "11":
                                date2 = "12"
                            case "12":
                                date2 = "13"
                            case "13":
                                date2 = "14"
                            case "14":
                                date2 = "15"
                            case "15":
                                date2 = "16"
                            case "16":
                                date2 = "17"
                            case "17":
                                date2 = "18"
                            case "18":
                                date2 = "19"
                            case "19":
                                date2 = "20"
                            case "20":
                                date2 = "21"
                            case "21":
                                date2 = "22"
                            case "22":
                                date2 = "23"
                            case "23":
                                date2 = "24"
                            case "24":
                                date2 = "25"
                            case "25":
                                date2 = "26"
                            case "26":
                                date2 = "27"
                            case "27":
                                date2 = "28"
                            default:
                                break
                            }
                        }
                        
//                        var date2 = Int(date2)! + day_count
                   
                        
                        
                        
                        print("!!!!!!!date2----------->\(date2)")//3
                        
                        switch date5 {
                        case "01":
                            dd()
                            switch date2 {
                            case "28":
                                date2 = "29"
                            case "29":
                                date2 = "30"
                            case "30":
                                date2 = "31"
                            case "31":
                                date2 = "32"
                            default:
                                break
                            }
                            if date2 == "32"{
                                date2 = "01"
                                date5 = "02"
                            }
                        case "02":
                            dd()
                            switch date2 {
                            case "28":
                                date2 = "29"
                            default:
                                break
                            }

                            if date2 == "29"{
                                date2 = "01"
                                date5 = "03"
                            }
                        case "03":
                            dd()
                            switch date2 {
                            case "28":
                                date2 = "29"
                            case "29":
                                date2 = "30"
                            case "30":
                                date2 = "31"
                            case "31":
                                date2 = "32"
                            default:
                                break
                            }

                            if date2 == "32"{
                                date2 = "01"
                                date5 = "04"
                            }
                        case "04":
                            dd()
                            switch date2 {
                            case "28":
                                date2 = "29"
                            case "29":
                                date2 = "30"
                            case "30":
                                date2 = "31"
                            default:
                                break
                            }

                            if date2 == "31"{
                                date2 = "01"
                                date5 = "05"
                            }
                        case "05":
                            dd()
                            switch date2 {
                            case "28":
                                date2 = "29"
                            case "29":
                                date2 = "30"
                            case "30":
                                date2 = "31"
                            case "31":
                                date2 = "32"
                            default:
                                break
                            }

                            if date2 == "32"{
                                date2 = "01"
                                date5 = "06"
                            }
                        case "06":
                           dd()
                           switch date2 {
                           case "28":
                            date2 = "29"
                           case "29":
                            date2 = "30"
                           case "30":
                            date2 = "31"
                           default:
                            break
                           }

                           if date2 == "31"{
                                date2 = "01"
                                date5 = "07"
                            }
                        case "07":
                           dd()
                           switch date2 {
                           case "28":
                            date2 = "29"
                           case "29":
                            date2 = "30"
                           case "30":
                            date2 = "31"
                           case "31":
                            date2 = "32"
                           default:
                            break
                           }
                           if date2 == "32"{
                                date2 = "01"
                                date5 = "08"
                            }
                        case "08":
                            dd()
                            switch date2 {
                            case "28":
                                date2 = "29"
                            case "29":
                                date2 = "30"
                            case "30":
                                date2 = "31"
                            case "31":
                                date2 = "32"
                            default:
                                break
                            }

                            if date2 == "32"{
                                date2 = "01"
                                date5 = "09"
                            }
                        case "09":
                            dd()
                            switch date2 {
                            case "28":
                                date2 = "29"
                            case "29":
                                date2 = "30"
                            case "30":
                                date2 = "31"
                            default:
                                break
                            }

                            if date2 == "31"{
                                date2 = "01"
                                date5 = "10"
                            }
                        case "10":
                           dd()
                           switch date2 {
                           case "28":
                            date2 = "29"
                           case "29":
                            date2 = "30"
                           case "30":
                            date2 = "31"
                           case "31":
                            date2 = "32"
                           default:
                            break
                           }

                           if date2 == "32"{
                                date2 = "01"
                                date5 = "11"
                            }
                        case "11":
                            dd()
                            switch date2 {
                            case "28":
                                date2 = "29"
                            case "29":
                                date2 = "30"
                            case "30":
                                date2 = "31"
                            default:
                                break
                            }

                            if date2 == "31"{
                                date2 = "01"
                                date5 = "12"
                            }
                        case "12":
                           
                            dd()
                            switch date2 {
                            case "28":
                                date2 = "29"
                            case "29":
                                date2 = "30"
                            case "30":
                                date2 = "31"
                            case "31":
                                date2 = "32"
                            default:
                                break
                            }

                            if date2 == "32"{
                                date2 = "01"
                                date5 = "01"
                            }
                        default:
                            break
                        }

                                                
                    date_Set = "\(date5)-\(date2) \(date3_2)\(date3_3)"
                   
                    }else{
                    
                    date_Set = "\(date5)-\(date2) \(date3_2)\(date3_3)"
                    }
                    
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
                
                elements?.setObject(date_Set, forKey: "pubDate" as NSCopying)
                print("date_Set------------->\(date_Set)")
                
                }
                else if(convery_count == 0){
                    var date1 = ""
                    var date2 = ""
                    var date3 = ""
                    var date4 = ""
                    
                    date1 = String(dateString).pregReplace(pattern: "\\s|,", with: "")
                    date2 = date1.pregReplace(pattern: "20...", with: "")
                    date3 = date2.pregReplace(pattern: "T", with: " ")
                    date4 = date3.pregReplace(pattern: ":\\d\\d.\\d\\d:\\d\\d", with: "")
                   
                    
                    
                    o_DateArray.append(date4 as String)
                    
                    
                }
            
            }
           
            if imageString != ""{
//                print("image---------->\(imageString)")
                
                if (convery_count == 1){
                    var result:String = ""
                    var result2:String = ""
                    var result3:String = ""
                    
                    result = String(imageString).pregReplace(pattern: "\\s", with: "")
                    result2 = result.pregReplace(pattern: "resize.+", with: "")
                    result3 = result2.pregReplace(pattern: ".+src=.", with: "")
                    
//                    print("image---------->\(result3)")

                    elements?.setObject(result3, forKey: "image" as NSCopying)
                }else if(convery_count == 2){
                    
                    var result:String = ""
                    var result2:String = ""
                    var result3:String = ""
                    var result4:String = ""
                    var result5:String = ""
                    var result6:String = ""
                    var result7:String = ""
                   
                    result = String(imageString).pregReplace(pattern: "src.+72.+alt", with: "")
                    
                    result2 = result.pregReplace(pattern: "\\s", with: "")
                    
                    result3 = result2.pregReplace(pattern: "alt.+", with: "")
                    
                    result4 = result3.pregReplace(pattern: ".+src=.", with: "")

                    result5 = result4.pregReplace(pattern: "jpg.", with: "jpg")
                    
                    result6 = result5.pregReplace(pattern: "jpeg.", with: "jpeg")
                    
                    result7 = result6.pregReplace(pattern: "png.", with: "png")
                    
                    

                    print("image---------->\(result7)")
                    
                    
                    
                    elements?.setObject(result7, forKey: "image" as NSCopying)
                
                
                }
            }
            
            //お知らせ用日記の内容
                if o_ContentString != ""{
                   
                    if(convery_count == 0){
                   
                        o_ContentArray.append(o_ContentString as String)
                 
                    }
                }
            
            //マルチ用の配列
            if o_MultiString != ""{
                
                if(convery_count == 0){
                   
                    var result:String = ""
                    
                    result = String(o_MultiString).pregReplace(pattern: "\\s", with: "")
                    
                    o_MultiArray.append(result)
      
                
                }
            }

            
            
            
            if (titleString != "RSS_Check"){
            
                
//                if (check(elements: elements)) {

                if (convery_count != 0){
                
                    if elements != nil{
                totalBox.add(elements!)
                    }
                }else{
                
               
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                self.sortAndReloadData()
                    }
                    
                }
                
            }
           
        }
        
       
    }
    
    func check(elements:NSMutableDictionary) -> Bool {
        let image:String = elements.value(forKey: "image") as! String
        var ok = true
        
        if image.pregMatche(pattern: "http.+jp"){
            
        }else{
            ok = false
        }
        
        
      
        return ok
    }

    
    
    
    func sortAndReloadData() {
        let dateDiscripter:NSSortDescriptor = NSSortDescriptor.init(key: "pubDate", ascending: false)
        let sortDescriptors:NSArray = [dateDiscripter]
        
        let data:NSArray = totalBox as NSArray
        
        
        dataArray = data.sortedArray(using: sortDescriptors as! [NSSortDescriptor]) as NSArray
        
        
        
        
        
        
            self.refreshControl.endRefreshing()
            tableView.reloadData()
            SVProgressHUD.dismiss()
            self.download_Check = false
        
        
//        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.o_TitleArray = self.o_TitleArray
//        appDelegate.o_DateArray = self.o_DateArray
//        appDelegate.o_ContentArray = self.o_ContentArray
//        appDelegate.o_MultiArray = self.o_MultiArray
//        
//        if UserDefaults.standard.object(forKey: "notice_Array") == nil{
//            UserDefaults.standard.set(o_TitleArray, forKey: "notice_Array")
//            let image2 = UIImage(named: "NewNotice.png")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
//            
//            notice_Image = UIBarButtonItem(image: image2, style: UIBarButtonItemStyle.plain, target: self, action:#selector(loadAllData))
//            
//            self.navigationItem.rightBarButtonItem = notice_Image
//        }else{
//            if(notice_Array != o_TitleArray){
//                let image2 = UIImage(named: "NewNotice.png")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
//                
//                
//                notice_Image = UIBarButtonItem(image: image2, style: UIBarButtonItemStyle.plain, target: self, action:#selector(loadAllData))
//                
//                self.navigationItem.rightBarButtonItem = notice_Image
//            //イメージのボタンをタップした時にUserDefaultsにo_TitleArrayを入れる
//                UserDefaults.standard.set(o_TitleArray, forKey: "notice_Array")
//
//                
//            }else{
//                let image = UIImage(named: "Notice.png")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
//                
//                notice_Image = UIBarButtonItem(image: image, style: UIBarButtonItemStyle.plain, target: self, action:#selector(loadAllData))
//                
//                self.navigationItem.rightBarButtonItem = notice_Image
//            }
//            
//        }
        
        
        
        
             print(o_TitleArray)
            print(o_DateArray)
            print(o_ContentArray)
            print(o_MultiArray)
            //APPデリゲートに送る処理と、RSSENDじゃないテーブルのリロード
            //APPデリゲートに書く? //APPデリゲートはサーバーのものもアプリを開くたびにとってくるのでviewでぃロードに書いた方がいいかも
          
        
        
        
        
        
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if error == nil {
            print("ダウンロードが完了しました")
        } else {
//            convery_count -= 1
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
            
        }
        
        
        
        
        let firebase2 = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "1")
        
        firebase2.queryLimited(toLast:50).observe(.value) { (snapshot,error) in
            
        }
        
        
        
        
        let firebase3 = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "2")
        firebase3.queryLimited(toLast:50).observe(.value) { (snapshot,error) in
            
        }
        
        
        
        
        let firebase4 = FIRDatabase.database().reference().child(Const.PostPath1).queryOrdered(byChild: "comment_id").queryEqual(toValue: "3")
        firebase4.queryLimited(toLast:50).observe(.value) { (snapshot,error) in
            
            
        }
        
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
   
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // 画面の自動回転をさせない
    override var shouldAutorotate: Bool {
        
        return false
        
    }
    
    // 画面をPortraitに指定する
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        return .portrait
        
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
//画面の縦横
extension UINavigationController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return visibleViewController?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }
    
    open override var shouldAutorotate: Bool {
        return visibleViewController?.shouldAutorotate ?? super.shouldAutorotate
    }
}

extension UITabBarController {
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let selected = selectedViewController {
            return selected.supportedInterfaceOrientations
        }
        return super.supportedInterfaceOrientations
    }
    
    open override var shouldAutorotate: Bool {
        if let selected = selectedViewController {
            return selected.shouldAutorotate
        }
        return super.shouldAutorotate
    }
}

//〇〇秒前
extension Date {
    func timeAgoSinceDate(numericDates:Bool) -> String {
        let calendar = NSCalendar.current
        let now = NSDate()
        let earliest = now.earlierDate(self as Date)
        let latest = (earliest == now as Date) ? self : now as Date
        let components = calendar.dateComponents([.minute , .hour , .day , .weekOfYear , .month , .year , .second], from: earliest, to: latest as Date)
        
        if (components.year! >= 2) {
            return "\(components.year!) 年前"
        } else if (components.year! >= 1){
            if (numericDates){
                return "1 年前"
            } else {
                return "去年"
            }
        } else if (components.month! >= 2) {
            return "\(components.month!) ヶ月前"
        } else if (components.month! >= 1){
            if (numericDates){
                return "1 ヶ月前"
            } else {
                return "先月"
            }
        } else if (components.weekOfYear! >= 2) {
            return "\(components.weekOfYear!) 週間前"
        } else if (components.weekOfYear! >= 1){
            if (numericDates){
                return "1 週間前"
            } else {
                return "先週"
            }
        } else if (components.day! >= 2) {
            return "\(components.day!) 日前"
        } else if (components.day! >= 1){
            if (numericDates){
                return "1 日前"
            } else {
                return "昨日"
            }
        } else if (components.hour! >= 2) {
            return "\(components.hour!) 時間前"
        } else if (components.hour! >= 1){
            if (numericDates){
                return "1 時間前"
            } else {
                return "1 時間前"
            }
        } else if (components.minute! >= 2) {
            return "\(components.minute!) 分前"
        } else if (components.minute! >= 1){
            if (numericDates){
                return "1 分前"
            } else {
                return "1 分前"
            }
        } else if (components.second! >= 5) {
            return "\(components.second!) 秒前"
        } else {
            return "今"
        }
        
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
