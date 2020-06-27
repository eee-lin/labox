//
//  ForgetPWViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/28.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit
import NCMB
import PKHUD

class ForgetPWViewController: UIViewController,UITextFieldDelegate {

    var users = [NCMBUser]()
    
    @IBOutlet var checkButton: UIButton!
    @IBOutlet var emailTextField: UITextField!
//    @IBOutlet var nameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        //変更ボタンを丸くする
        checkButton.layer.cornerRadius = checkButton.bounds.width / 20.0
        emailTextField.delegate = self
//        nameTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func checkPW() {
        NCMBUser.requestPasswordResetForEmail(inBackground: emailTextField.text) { (error) in
            if error != nil {
                
            }else{
                HUD.flash(.labeledSuccess(title: "メールを送信しました", subtitle: "再パスワードを設定してください"), delay: 2)
                self.navigationController?.popViewController(animated: true)
            }
        }
//        if (emailTextField.text?.count)! > 0 && (nameTextField.text?.count)! > 0 {
//
//            let query = NCMBUser.query()
//            // 名前
//            query?.whereKey("userName", equalTo: nameTextField.text)
//            //メール
//            query?.whereKey("mailAddress", equalTo: emailTextField.text)
//            // 退会済みアカウントを除外
//            query?.whereKey("active", notEqualTo: false)
//
//            query?.findObjectsInBackground({ (result, error) in
//                if error != nil {
//                    HUD.flash(.labeledError(title: "入力が間違っているようです", subtitle: "もう一度入力してください"), delay: 2)
//                } else {
//                    HUD.show(.progress)
//                    self.users = result as! [NCMBUser]
//                    let user = self.users.first
//                    if user != nil {
//                            let PW = user?.object(forKey: "PW") as! String
//                            HUD.hide()
//                            let alertController = UIAlertController(title: "パスワード", message: PW, preferredStyle: .actionSheet)
//                            let checkAction = UIAlertAction(title: "確認しました", style: .default) { (action) in
//                            //HUD.flash(.progress, delay: 2)
//                            self.navigationController?.popViewController(animated: true)
//                            }
//                        alertController.addAction(checkAction)
//                        self.present(alertController, animated: true, completion: nil)
//                    } else {
//                        HUD.flash(.labeledError(title: "入力が間違っているようです", subtitle: "もう一度入力してください"), delay: 2)
//                    }
//                }
//            })
//        } else {
//            HUD.flash(.labeledError(title: "未記入のものがあります", subtitle: "記入してください"), delay: 2.5)
//        }
    }

}
