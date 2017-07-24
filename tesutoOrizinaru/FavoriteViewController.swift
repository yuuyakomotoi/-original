//
//  FavoriteViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/05/08.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD

class FavoriteViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var segmentCount = 0
    
    var alert_Check = false
    
    // ニュース
    var newsTitleArray:[String] = []
    var newsLinkArray:[String] = []
    var newsDateArray:[String] = []
    var newsUrlArray:[String] = []
    var newsLink_NameArray:[String] = []

    //動画
    var m_TitleArray:[String] = []
    var m_LinkArray:[String] = []
    var m_DateArray:[String] = []
    var m_UrlArray:[String] = []
    var m_nameArray:[String] = []
    
    var support_Button = UIBarButtonItem()
    
    
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.navicheck == true{
            self.tabBarController?.tabBar.isHidden = true
        }
        
        
        
        support_Button = UIBarButtonItem(title: "説明", style: UIBarButtonItemStyle.plain, target: self, action:#selector(support))
    
        self.title = "お気に入り"
        /////////////////
        //オートレイアウト
        
                self.navigationItem.rightBarButtonItem = support_Button
        
    }
        

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
              
        
            if UserDefaults.standard.object(forKey: "newsTitleArray") != nil{
            
            
            
            newsTitleArray = UserDefaults.standard.object(forKey: "newsTitleArray") as! [String]
            
            newsLinkArray = UserDefaults.standard.object(forKey: "newsLinkArray") as! [String]
            
            newsDateArray = UserDefaults.standard.object(forKey: "newsDateArray") as! [String]
            
            newsUrlArray = UserDefaults.standard.object(forKey: "newsUrlArray") as! [String]
                
        newsLink_NameArray = UserDefaults.standard.object(forKey: "newsLink_NameArray") as! [String]
   
            
                
        }
       
       
            if UserDefaults.standard.object(forKey: "movieTitleArray") != nil{
            
            
                
                m_TitleArray = UserDefaults.standard.object(forKey: "movieTitleArray") as! [String]
                
                m_LinkArray = UserDefaults.standard.object(forKey: "movieLinkArray") as! [String]
                
                m_DateArray = UserDefaults.standard.object(forKey: "movieDateArray") as! [String]
                
                m_UrlArray = UserDefaults.standard.object(forKey: "movieUrlArray") as! [String]
             
                m_nameArray = UserDefaults.standard.object(forKey: "movienameArray") as! [String]
                }
                

       SVProgressHUD.dismiss()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if UserDefaults.standard.object(forKey: "check") == nil{
            
            
            
            let navBarImage = UIImage(named: "navBarImage.png") as UIImage?
            self.navigationController?.navigationBar.setBackgroundImage(navBarImage,for:.default)
            self.navigationController?.navigationBar.backgroundColor = UIColor.white
            
                
                
            
            
            
            if (alert_Check == false){
            
                alert_Check = true
                
            let alertViewControler = UIAlertController(title: "お気に入りの利用方法を確認しますか？", message: "", preferredStyle:.alert)
            let okAction = UIAlertAction(title: "確認する", style: .default, handler:{
                (action:UIAlertAction!) -> Void in
                
                let support = self.storyboard?.instantiateViewController(withIdentifier: "support")
                self.navigationController?.pushViewController(support!, animated: true)
                                
            })
            
            let checkAction = UIAlertAction(title: "今後このアラートを表示しない", style: .default, handler:{
                (action:UIAlertAction!) -> Void in
                
                let check = "check"
                UserDefaults.standard.set(check, forKey: "check")
                
                
                
            })
            
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
            
            
            alertViewControler.addAction(okAction)
            alertViewControler.addAction(cancelAction)
            alertViewControler.addAction(checkAction)
            
            
            present(alertViewControler, animated: true, completion: nil)
            
        }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 //セクションの数
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (segmentCount == 0){
        return newsTitleArray.count
        }else {
        return m_TitleArray.count
        }
    }
    
    func  tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath)
        
        if (segmentCount == 0){
        
        let titleLabel = cell.viewWithTag(1) as! UILabel
        
        titleLabel.text = newsTitleArray.reversed()[indexPath.row]
        
        let linkLabel = cell.viewWithTag(2) as! UILabel
        
        linkLabel.text = newsLink_NameArray.reversed()[indexPath.row]


        
        let dateLabel = cell.viewWithTag(3) as! UILabel
        dateLabel.text = newsDateArray.reversed()[indexPath.row]
        
        
            let thumbnailImage = cell.viewWithTag(4) as! UIImageView!
        

            if UserDefaults.standard.object(forKey: "newsLink_NameArray") != nil {
                let urlstr = newsUrlArray.reversed()[indexPath.row]
                let encodedString = urlstr.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
                let url:URL = URL(string: encodedString!)!
                thumbnailImage?.sd_setImage(with:url,placeholderImage:UIImage(named: "No Image.png"))
            }
            else {
                thumbnailImage?.image = UIImage(named: "No Image.png")
            }

            
        
            let deleteButton = cell.viewWithTag(5) as! UIButton
            deleteButton.backgroundColor = UIColor.clear
            deleteButton.addTarget(self, action:#selector(deleteButton(sender:event:)), for: UIControlEvents.touchUpInside)
            

        
        }else {
            let titleLabel = cell.viewWithTag(1) as! UILabel
            
            titleLabel.text = m_TitleArray.reversed()[indexPath.row]
            
            let linkLabel = cell.viewWithTag(2) as! UILabel
            
            linkLabel.text = m_nameArray.reversed()[indexPath.row]
            
            
            let dateLabel = cell.viewWithTag(3) as! UILabel
            dateLabel.text = m_DateArray.reversed()[indexPath.row]
            
            let thumbnailImage = cell.viewWithTag(4) as! UIImageView!
            
            let urlstr = m_UrlArray.reversed()[indexPath.row]
            
            
            let url:URL = URL(string: urlstr)!
            
            
            thumbnailImage?.sd_setImage(with:url,placeholderImage:UIImage(named: ""))
        
            let deleteButton = cell.viewWithTag(5) as! UIButton
            deleteButton.backgroundColor = UIColor.clear
            deleteButton.addTarget(self, action:#selector(deleteButton(sender:event:)), for: UIControlEvents.touchUpInside)
        }
       
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tabBarController?.tabBar.isHidden = true
        
        let newsModalViewController = self.storyboard?.instantiateViewController(withIdentifier: "news") as! NewsModalViewController
        
    
        if (segmentCount == 0){
        let linkURL = UserDefaults.standard.object(forKey: "newsLinkArray") as! [String]
            newsModalViewController.str = linkURL.reversed()[indexPath.row]
            newsModalViewController.app_News_Check = true
        
        }else{
            let linkURL = UserDefaults.standard.object(forKey: "movieLinkArray") as! [String]
            newsModalViewController.str = linkURL.reversed()[indexPath.row]
        newsModalViewController.app_News_Check = true
        }
        //navigationControllerをstoryboardでセットしてから使う
        
        self.navigationController?.pushViewController(newsModalViewController, animated: true)
        }
    

    @IBAction func segmentButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            segmentCount = 0
            self.tableView.reloadData()
            print(segmentCount)

            break
        case 1:
            segmentCount = 1
            self.tableView.reloadData()
            print(segmentCount)

            break
                   
        default:
            
            break
        }
    }
   
    func showAlert(t:Int,l:Int,d:Int,u:Int,n:Int,m_t:Int,m_l:Int,m_d:Int,m_u:Int,m_n:Int,segmentCount:Int) {
        
        if (segmentCount == 0){
        
            let alertViewControler = UIAlertController(title: "この記事をお気に入り\nから削除しますか？", message: "", preferredStyle:.actionSheet)
        let okAction = UIAlertAction(title: "削除", style: .default, handler:{
            (action:UIAlertAction!) -> Void in
            self.addFavorite(t:t,l:l,d:d,u:u,n:n,m_t:m_t,m_l:m_l,m_d:m_d,m_u:m_u,m_n:m_n)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        alertViewControler.addAction(okAction)
        alertViewControler.addAction(cancelAction)
        present(alertViewControler, animated: true, completion: nil)
        
        
        }else if (segmentCount == 1){
            let alertViewControler = UIAlertController(title: "この動画をお気に入り\nから削除しますか？", message: "", preferredStyle:.actionSheet)
            let okAction = UIAlertAction(title: "削除", style: .default, handler:{
                (action:UIAlertAction!) -> Void in
                self.addFavorite(t:t,l:l,d:d,u:u,n:n,m_t:m_t,m_l:m_l,m_d:m_d,m_u:m_u,m_n:m_n)

            })
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
            
            alertViewControler.addAction(okAction)
            alertViewControler.addAction(cancelAction)
            present(alertViewControler, animated: true, completion: nil)

        }
    }

    
    func addFavorite(t:Int,l:Int,d:Int,u:Int,n:Int,m_t:Int,m_l:Int,m_d:Int,m_u:Int,m_n:Int) {
       
           if segmentCount == 0{
           
            newsTitleArray.remove(at:t)
            
            newsLinkArray.remove(at:l)
            
            newsDateArray.remove(at:d)
            
            newsUrlArray.remove(at:u)
            
            newsLink_NameArray.remove(at: n)
            
            UserDefaults.standard.set(newsTitleArray, forKey: "newsTitleArray")
            UserDefaults.standard.set(newsLinkArray, forKey: "newsLinkArray")
            UserDefaults.standard.set(newsDateArray, forKey: "newsDateArray")
            UserDefaults.standard.set(newsUrlArray, forKey: "newsUrlArray")
            UserDefaults.standard.set(newsLink_NameArray, forKey: "newsLink_NameArray")

            
            
            
            tableView.reloadData()
       
           
           
           }else if segmentCount == 1{

            m_TitleArray.remove(at:m_t)
            
            m_LinkArray.remove(at:m_l)
            
            m_DateArray.remove(at:m_d)
            
            m_UrlArray.remove(at:m_u)
            
            m_nameArray.remove(at:m_n)
            
            
            UserDefaults.standard.set(m_TitleArray, forKey: "movieTitleArray")
                        UserDefaults.standard.set(m_LinkArray, forKey: "movieLinkArray")
                        UserDefaults.standard.set(m_DateArray, forKey: "movieDateArray")
                        UserDefaults.standard.set(m_UrlArray, forKey: "movieUrlArray")
                        UserDefaults.standard.set(m_nameArray, forKey: "movienameArray")
                        
                        tableView.reloadData()
        }
    }
    
    func deleteButton(sender: UIButton, event:UIEvent){
     
        let touch = event.allTouches?.first
        let point = touch!.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
       
            
            let t = (newsTitleArray.count - (indexPath?.row)! - 1)
            
            let l = (newsLinkArray.count - (indexPath?.row)! - 1)
            
            let d = (newsDateArray.count - (indexPath?.row)! - 1)
            
            let u = (newsUrlArray.count - (indexPath?.row)! - 1)
        
            let n = (newsLink_NameArray.count - (indexPath?.row)! - 1)

        
        
        
        
            let m_t = (m_TitleArray.count - (indexPath?.row)! - 1)
            
            let m_l = (m_LinkArray.count - (indexPath?.row)! - 1)
            
            let m_d = (m_DateArray.count - (indexPath?.row)! - 1)
            
            let m_u = (m_UrlArray.count - (indexPath?.row)! - 1)
            
            let m_n = (m_nameArray.count - (indexPath?.row)! - 1)

       
        
        showAlert(t:t,l:l,d:d,u:u,n:n,m_t:m_t,m_l:m_l,m_d:m_d,m_u:m_u,m_n:m_n,segmentCount:segmentCount)

        
    }
    
    
     func support() {
        
        
                
        let support_ViewController = self.storyboard?.instantiateViewController(withIdentifier: "support") as! Support_ViewController
        self.navigationController?.pushViewController(support_ViewController, animated: true)
           }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
}
