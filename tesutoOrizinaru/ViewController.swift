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
    
    var reload_Time = Timer()
    
    
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
    
    var userId:String = ""
    
    var items:[BBS_PostData1] = []
    
    @IBOutlet var tableView: UITableView!
    
    
    
    
    
    //ストリング型でもいい
    
    
    
    
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
        
        
        convery_count = urlArray.count

        for url_string in urlArray{
            download_rss(url_str: url_string)
            
        }
    
        
        
        loadAllData()
      
        
        
        
        //引っ張って更新
      
        
        refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refreshControl.addTarget(self, action:#selector(delay), for:UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl)
        
        tableView.addSubview(refreshControl)
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        
        
        
       
        
        
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
            
            
        }
//       DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
//        print("totalBox----------->\(self.totalBox.debugDescription)")
//        self.tableView.reloadData()
//        }
        
        
        
    }
    
    
    func reload_Timer2(){
       reload_Time.invalidate()
        self.refresh_Chack = false
        tableView.reloadData()
    }

    
    //引っ張って更新メソッド
    //引っ張って更新メソッドの時にもパースしたものを更新したいので上のコードをメソッドの中に入れる
    
    
    func delay(){
        
        if refresh_Chack == false{
        refresh_Chack = true
        convery_count = urlArray.count
        
        for url_string in urlArray{
            download_rss(url_str: url_string)
            
            }
            
            refreshControl.endRefreshing()
            
            reload_Time = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(reload_Timer2), userInfo: nil, repeats: true)

        }else{
            refreshControl.endRefreshing()

        }
            }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //セクションの数
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalBox.count //セルの数 totalBoxが取得した数
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        
        let titleLabel = cell.viewWithTag(1) as! UILabel
        let linkLabel = cell.viewWithTag(2) as! UILabel
        let dateLabel = cell.viewWithTag(3) as! UILabel
       let thumbnailImage = cell.viewWithTag(4) as! UIImageView
        let favoriteButton = cell.viewWithTag(5) as! UIButton
        favoriteButton.backgroundColor = UIColor.clear
        
        titleLabel.text = (totalBox[indexPath.row] as AnyObject).value(forKey: "title") as? String
        
        linkLabel.text = (totalBox[indexPath.row] as AnyObject).value(forKey: "link_Name") as? String
        
        dateLabel.text = (totalBox[indexPath.row] as AnyObject).value(forKey: "pubDate") as? String
        
        
        if (( (totalBox[indexPath.row] as AnyObject).value(forKey: "image") ) != nil) {
            let urlstr = (totalBox[indexPath.row] as AnyObject).value(forKey: "image") as! String
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
        
        let linkURL = (totalBox[indexPath.row] as AnyObject).value(forKey: "link") as? String
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
                print("date---------->\(dateString)")
                
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
                
                elements.setObject(dateString, forKey: "pubDate" as NSCopying)
                
            }
            if imageString != ""{
                print("image---------->\(imageString)")
                
                elements.setObject(imageString, forKey: "image" as NSCopying)
                
            }
            
            if titleString != "RSS_Check"{
            
            if titleString != "RSS_END"{
                totalBox.add(elements)

            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.tableView.reloadData()
                    SVProgressHUD.dismiss()
                print(self.totalBox.debugDescription)
                }

                            }
            }
           
        }
        
        
        //        print("elements----------->\(elements)")
        //        
        //        
        //
        //        print("totalBox----------->\(totalBox)")
        //        print(totalBox)

    }
    
//    func sortAndReloadData() {
//        let dateDiscripter:NSSortDescriptor = NSSortDescriptor.init(key: "pubDate", ascending: false)
//        let sortDescriptors:NSArray = [dateDiscripter]
//        
//        let data:NSArray = totalBox as NSArray
//        
//        dataArray = data.sortedArray(using: sortDescriptors as! [NSSortDescriptor]) as NSArray
//        
//        print(dataArray.description)
//        tableView.reloadData()
//    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        if error == nil {
            print("ダウンロードが完了しました")
        } else {
            convery_count -= 1
            print("ダウンロードが失敗しました")
        }
        
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
        
        let newsTitle = (totalBox[(indexPath?.row)!] as AnyObject).value(forKey: "title") as? String
        let newsLink = (totalBox[(indexPath?.row)!] as AnyObject).value(forKey: "link") as? String
        let newsDate = (totalBox[(indexPath?.row)!] as AnyObject).value(forKey: "pubDate") as? String
        let newsUrl = (totalBox[(indexPath?.row)!] as AnyObject).value(forKey: "image") as? String
        
        
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
                    self.items.append(postData)
                    }
                
                self.items.reverse()
    
}
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
         appDelegate.items = self.items
        
        
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
