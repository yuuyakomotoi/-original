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

class MovieViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,XMLParserDelegate {
    
    var refreshControl:UIRefreshControl!
    
    var parser = XMLParser()
    
    var dataArray = NSArray()
    
    var totalBox = NSMutableArray()
    
    
    var elements = NSMutableDictionary()
    
    var element = String() //　タイトルが入ったり、リンクが入ったりする
    
    var titleString = NSMutableString() //キー値を決めて取り出したり、セットしたりする
    var linkString = String()
    
    var dateString = NSMutableString()
    
    var nameString = NSMutableString()
    
    var imageString = String()
    
    var urlArray = ["https://www.youtube.com/feeds/videos.xml?channel_id=UCbdmvBJuphbyB2_LjBMW3MA","https://www.youtube.com/feeds/videos.xml?channel_id=UCdMjv0p4OPjyR8cPMRlQAdg","https://www.youtube.com/feeds/videos.xml?channel_id=UCDOD89CZCNdJZPPM1hudUPQ"]
    
    
    //お気に入りに登録用の配列
    var movieTitleArray:[String] = []
    var movieLinkArray:[String] = []
    var movieDateArray:[String] = []
    var movieUrlArray:[String] = []
    var movienameArray:[String] = []

    
    @IBOutlet var tableView: UITableView!
    
    
    
    
    //ストリング型でもいい
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().tintColor = UIColor(red: 1, green: 0.6, blue: 0, alpha: 1)
        
        
        
        
        //引っ張って更新
        refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.gray
        refreshControl.attributedTitle = NSAttributedString(string: "引っ張って更新")
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        
        tableView.addSubview(refreshControl)
        
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        
        SVProgressHUD.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
           
            self.totalBox = []
            self.dataArray = []
            
            for urlAll in self.urlArray{
                
                let url = urlAll  //ここにサイトのURLを入れる
                
                let urlToSend:URL = URL(string:url)!
                
                
                
                
                self.parser = XMLParser(contentsOf: urlToSend)!
                self.parser.delegate = self
                self.parser.parse()
                self.tableView.reloadData()//テーブルビュー更新
            SVProgressHUD.dismiss()
            }
 
        }
    
    
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if totalBox != []{
            SVProgressHUD.dismiss()
        }
        
        if UserDefaults.standard.object(forKey: "movieTitleArray") != nil{
            
            
            
            movieTitleArray = UserDefaults.standard.object(forKey: "movieTitleArray") as! [String]
            
            movieLinkArray = UserDefaults.standard.object(forKey: "movieLinkArray") as! [String]
            
            movieDateArray = UserDefaults.standard.object(forKey: "movieDateArray") as! [String]
            
            movieUrlArray = UserDefaults.standard.object(forKey: "movieUrlArray") as! [String]
            
            movienameArray = UserDefaults.standard.object(forKey: "movienameArray") as! [String]
            
        }

    
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let navBarImage = UIImage(named: "navBarImage.png") as UIImage?
        self.navigationController?.navigationBar.setBackgroundImage(navBarImage,for:.default)
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        
        
        
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
            self.refreshControl.endRefreshing()
            tableView.reloadData()//テーブルビュー更新
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

        linkLabel.text = (dataArray[indexPath.row] as AnyObject).value(forKey: "name") as? String

        dateLabel.text = (dataArray[indexPath.row] as AnyObject).value(forKey: "published") as? String
        
        let urlstr = (dataArray[indexPath.row] as AnyObject).value(forKey: "url") as! String
        
        let url:URL = URL(string: urlstr)!

        thumbnailImage?.sd_setImage(with:url,placeholderImage:UIImage(named: ""))
        
         favoriteButton.addTarget(self, action:#selector(favoriteButton(sender:event:)), for:  UIControlEvents.touchUpInside)
        
        
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
        
        /*let linkURL = (totalBox[indexPath.row] as AnyObject).value(forKey: "href") as? String
         //let urlStr = linkURL?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) これがあるとうまく表示されない
         let url:URL = URL(string: linkURL!)!
         let urlRequest = NSURLRequest(url:url)
         webView.loadRequest(urlRequest as URLRequest)
         */
        self.tabBarController?.tabBar.isHidden = true
        
        let newsModalViewController = self.storyboard?.instantiateViewController(withIdentifier: "news") as! NewsModalViewController
        
        let linkURL = (dataArray[indexPath.row] as AnyObject).value(forKey: "href") as? String
        
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
        
        
        if element == "entry"{
            
            elements = NSMutableDictionary()
            elements = [:]
            titleString = NSMutableString()
            titleString = ""
            dateString = NSMutableString()
            dateString = ""
            nameString = NSMutableString()
            nameString = ""
            
            
        }
        else if element == "media:thumbnail"{
            imageString = String()
            imageString = attributeDict["url"]!
        }
        else if element == "link"{
            linkString = String()
            linkString = attributeDict["href"]!
        }
    }
    
    //タグの間にデータがあった(開始タグと終了タグでくくられた箇所にデータが存在位した時に実行されるメソッド)
    //parserのデリゲートメソッド
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if element == "title"{
            
            titleString.append(string)
            
        }
        else if element == "published"{
            dateString.append(string)
        }
        else if element == "name"{
            nameString.append(string)
        }
        
    }
    
    //タグの終了を見つけた時
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?){
        
        //itemという要素の中にあるなら
        if elementName == "entry"{
            //titleStringの中身(linkString)の中身が空でないなら
            if titleString != ""{
                //elementsにキー値を付与しながらtitleString(linkStrung)をセットする
                elements.setObject(titleString, forKey: "title" as NSCopying)
            }
            if dateString != ""{
                let msg = dateString.replacingOccurrences(of: "T", with: " ")
                let msg2 = msg.replacingOccurrences(of: "+00:00\n", with: "")
                let dateFormatter = DateFormatter()
                dateFormatter.locale = NSLocale(localeIdentifier: NSLocale.Key.languageCode.rawValue) as Locale!
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let r_date = dateFormatter.date(from: msg2 as String)
                
                if let d = r_date {
                    dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale!
                    dateFormatter.dateFormat = "MM-dd HH:mm"
                    elements.setObject(dateFormatter.string(from: d), forKey: "published" as NSCopying)
                }
                else {
                    elements.setObject(dateString, forKey: "published" as NSCopying)
                }
            }
            if nameString != ""{
                elements.setObject(nameString, forKey: "name" as NSCopying)
            }
            elements.setObject(imageString,forKey:"url" as NSCopying)
            elements.setObject(linkString,forKey:"href" as NSCopying)
            
            if ( !checkMovie(elements: elements) ) {
                //totalBoxの中にelementsを入れる
                totalBox.add(elements)
            }
            sortAndReloadData()
        }
    }
    
    //elements.value(forKey: "title")の中の白猫とついた文のものだけを選別をする
    
    let ng_words = ["白猫"]
    
    
    func checkMovie(elements:NSMutableDictionary) -> Bool {
        let title:String = elements.value(forKey: "title") as! String
        
        var ok = true
        
        for word in ng_words {
            if ( title.contains(word) ) {
                ok = false
            }
        }
        return ok
    }
    
    //toolBoxに格納されている　forKey: "updated"　の中身を日付順に並べるため変数dataArrayに格納する
    
    func sortAndReloadData(){
        let dateDiscripter:NSSortDescriptor = NSSortDescriptor.init(key: "published", ascending: false)
        
        let sortDescriptors:NSArray = [dateDiscripter]
        
        let data:NSArray = totalBox as NSArray
        
        dataArray = data.sortedArray(using: sortDescriptors as! [NSSortDescriptor]) as NSArray
        
        tableView.reloadData()
        
    }
    
    func showAlert(movieTitle:String,movieLink:String,movieDate:String,movieUrl:String,moviename:String) {
        let alertViewControler = UIAlertController(title: "この動画をお気に入り登録しますか？", message: "「ホーム」→「お気に入り」\nより閲覧が可能となります", preferredStyle:.actionSheet)
        let okAction = UIAlertAction(title: "お気に入りに追加", style: .default, handler:{
            (action:UIAlertAction!) -> Void in
            self.addFavorite(movieTitle:movieTitle,movieLink:movieLink,movieDate:movieDate,movieUrl:movieUrl,moviename:moviename
            )
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alertViewControler.addAction(okAction)
        alertViewControler.addAction(cancelAction)
        present(alertViewControler, animated: true, completion: nil)
        
    }
    
    func addFavorite(movieTitle:String,movieLink:String,movieDate:String,movieUrl:String,moviename:String) {
        
        
                movieTitleArray.append(movieTitle)
        
                UserDefaults.standard.set(movieTitleArray, forKey: "movieTitleArray")
        
        
        
        
        
                movieLinkArray.append(movieLink)
        
                UserDefaults.standard.set(movieLinkArray, forKey: "movieLinkArray")
        
        
        
                movieDateArray.append(movieDate)
        
                UserDefaults.standard.set( movieDateArray, forKey: "movieDateArray")
        
        
        
                movieUrlArray.append(movieUrl)
        
                UserDefaults.standard.set(movieUrlArray, forKey: "movieUrlArray")
        
        
        
                movienameArray.append(moviename)
                
                UserDefaults.standard.set(movienameArray, forKey: "movienameArray")
        
                
                SVProgressHUD.showSuccess(withStatus: "お気に入りに\n追加しました")
    
    }
    
    
    
    func favoriteButton(sender: UIButton, event:UIEvent){
        
        let touch = event.allTouches?.first
        let point = touch!.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        
        
        let movieTitle = (dataArray[(indexPath?.row)!] as AnyObject).value(forKey: "title") as? String
        let movieLink = (dataArray[(indexPath?.row)!] as AnyObject).value(forKey: "href") as? String
        let movieDate = (dataArray[(indexPath?.row)!] as AnyObject).value(forKey: "published") as? String
        let movieUrl = (dataArray[(indexPath?.row)!] as AnyObject).value(forKey: "url") as? String
        let moviename = (dataArray[(indexPath?.row)!] as AnyObject).value(forKey: "name") as? String
        
        
        for i in movieLinkArray {
            
            
            if i == movieLink{
                
                SVProgressHUD.showError(withStatus: "この動画はお気に入りに登録済みです")
                return
                
            }
       
        }

        
    showAlert(movieTitle:movieTitle!,movieLink:movieLink!,movieDate:movieDate!,movieUrl:movieUrl!,moviename:moviename!)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

