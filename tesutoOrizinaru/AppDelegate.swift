//
//  AppDelegate.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/03/26.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var items:[BBS_PostData1] = []
    var items2:[BBS_PostData1] = []
    var items3:[BBS_PostData1] = []
    var items4:[BBS_PostData1] = []
    
    var id1:[BBS_PostData1] = []
    var id2:[BBS_PostData1] = []
    var id3:[BBS_PostData1] = []
    var id4:[BBS_PostData1] = []

    
    
    var post_Check = false
    
    var navicheck = false
    
    var navicheck2 = false
    
    var ndataArray:NSArray = []
    
    var dataArray:NSArray = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FIRApp.configure() 
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
   
    
    
    
    
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
   loadAllData()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
   
    }
var count = 0
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


}

