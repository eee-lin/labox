//
//  FirstSignInViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/06/11.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit

import UIKit
import NCMB
import PKHUD

class FirstSignInViewController: UIViewController, UITextFieldDelegate {
    
    var checkPW: Bool! = false
    var selectedTextField: String = ""
    
    @IBOutlet var showPW: UIButton!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        //変更ボタンを丸くする
        loginButton.layer.cornerRadius = loginButton.bounds.width / 20.0
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func signIn() {
        // 任意フィールドに値を設定
        if (emailTextField.text?.count)! > 0 && (passwordTextField.text?.count)! > 0 {
            NCMBUser.logInWithUsername(inBackground: emailTextField.text, password: passwordTextField.text) { (user, error) in
                if error != nil {
                    HUD.flash(.labeledError(title: "アカウントがありません", subtitle: "ご記入にお間違いがないかご確認ください"), delay: 3)
                } else {
                    if user!.object(forKey: "active") as? Bool == false {
                        HUD.flash(.labeledError(title: "そのユーザーは退会済みです", subtitle: "アカウントを作成してください"), delay: 3)
                    } else {
                        // 任意フィールドに値を設定
                        let user = NCMBUser.current()
                        user?.setObject(self.selectedTextField, forKey: "displayName")
                        user?.saveInBackground({ (error) in
                            if error != nil {
//                                HUD.flash(.labeledError(title: "送信エラー", subtitle: error?.localizedDescription), delay: 2.0)
                                print("displayName失敗")
                            } else {
                                print(self.selectedTextField)
                            }
                        })
                            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                            UIApplication.shared.keyWindow?.rootViewController = rootViewController
                            // ログイン状態の保持
                            //このアプリの一番下(奥)にある画面を取得することができる
                            let ud = UserDefaults.standard
                            ud.set(true, forKey: "isLogin")
                            //この３行がログイン状態の保持
                    }
                }
            }
        }
    }
    
    @IBAction func showpw() {
        if checkPW == false {
            passwordTextField.isSecureTextEntry = false
            checkPW = true
        } else if checkPW == true {
            passwordTextField.isSecureTextEntry = true
            checkPW = false
        }
    }
//
    @IBAction func forgetPassword() {
        performSegue(withIdentifier: "toForgetPW", sender: nil)
    }
    

}

