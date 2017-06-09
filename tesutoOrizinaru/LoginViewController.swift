//
//  LoginViewController.swift
//  tesutoOrizinaru
//
//  Created by 小本裕也 on 2017/04/18.
//  Copyright © 2017年 小本裕也. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {

    
    
    @IBOutlet var emailtextField: UITextField!
    
    @IBOutlet var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    
    
    
    @IBAction func createNewUser(_ sender: AnyObject) {
        
        if let address = emailtextField.text, let password = passwordTextField.text{
       
            if address.characters.isEmpty || password.characters.isEmpty {
            SVProgressHUD.showError(withStatus: "何かが空です")
            return
        }
        
       
        SVProgressHUD.show()
        
       
        FIRAuth.auth()?.createUser(withEmail: address, password: password) { user, error in
            if let error = error {
                
                print("DEBUG_PRINT: " + error.localizedDescription)
               
                SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。")
                return
            }
            
            }
    SVProgressHUD.dismiss()
        }
   self.dismiss(animated: true, completion: nil)
    }

    
    
    @IBAction func userLogin(_ sender: AnyObject) {
        
        //ログイン
        
        if let address = emailtextField.text, let password = passwordTextField.text{
            
            if address.characters.isEmpty || password.characters.isEmpty {
                SVProgressHUD.showError(withStatus: "何かが空です")
                return
            }
            
            
            SVProgressHUD.show()
            
            
            FIRAuth.auth()?.signIn(withEmail: address, password: password) { user, error in
                if let error = error {
                    
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました")
                    return
                }
                
            }
            SVProgressHUD.dismiss()
        }
        self.dismiss(animated: true, completion: nil)    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
}
