//
//  SignUpViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/15.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit
import NCMB
import PKHUD

class SignUpViewController: UIViewController, UITextFieldDelegate {

//    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
//    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var registerButton: UIButton!
    
//    var passedName: String!
//    var passedEmail: String!
//    var passedPassword: String!
//    var userurl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        nameTextField.delegate = self
        emailTextField.delegate = self
//        passwordTextField.delegate = self
        
//        nameTextField.text = passedName
//        emailTextField.text = passedEmail
//        passwordTextField.text = passedPassword
        
        //変更ボタンを丸くする
        registerButton.layer.cornerRadius = registerButton.bounds.width / 20.0
    }
    
    //改行ボタンがつく
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    @IBAction func signUp() {
        
//        let user = NCMBUser()
//        user.mailAddress = emailTextField.text
        var error : NSError? = nil
        NCMBUser.requestAuthenticationMail(emailTextField.text, error: &error)
        if error != nil {
            HUD.flash(.labeledError(title: "会員登録用メールの要求に失敗しました", subtitle: "通信状況を確認してください"), delay: 1)
        }else {
            HUD.flash(.labeledSuccess(title: "会員登録用メールの要求に成功しました", subtitle: "メールをご確認ください"), delay: 1)
            performSegue(withIdentifier: "toSignIn", sender: nil)
        }
        }
        
//        // 任意フィールドに値を設定
//        user.setObject(passedPassword, forKey: "PW")
        
//        user.signUpInBackground { (error) in
//            if error != nil {
//                // エラーがあった場合
//                HUD.flash(.labeledError(title: "サインインできません", subtitle: "通信状況を確認してください"), delay: 2)
//            } else {
//                let userimage = UIImage(named: "丸底フラスコのフリーアイコン3.png")
//                let userimagedata = userimage!.pngData()
//                let userfile = NCMBFile.file(withName: NCMBUser.current()!.objectId + "user", data: userimagedata) as! NCMBFile
//                userfile.saveInBackground({ (error) in
//                    if error != nil {
//                        HUD.flash(.labeledError(title: "画像取得エラー", subtitle: "通信状況を確認してください"), delay: 1)
//                    } else {
////                        self.userurl = "https://mbaas.api.nifcloud.com/2013-09-01/applications/U6JMTv054XyGhBEa/publicFiles/" + userfile.name
//                    }
//                }) { (progress) in
//                    print(progress)
//                }
//                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//                let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
//                UIApplication.shared.keyWindow?.rootViewController = rootViewController
//
//                // ログイン状態の保持
//                //このアプリの一番下(奥)にある画面を取得することができる
//                let ud = UserDefaults.standard
//                ud.set(true, forKey: "isLogin")
//                ud.synchronize()
//                //この３行がログイン状態の保持
//            }
//        }

}

