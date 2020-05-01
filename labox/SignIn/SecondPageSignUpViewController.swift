//
//  SecondPageSignUpViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/15.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit

class SecondpageSignUpViewController: UIViewController, UITextFieldDelegate {
    
    var passedName: String!
    var passedEmail: String!
    
    var checkPW: Bool! = false
    
    @IBOutlet var showPW: UIButton!
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        passwordTextField.delegate = self
        
        //変更ボタンを丸くする
        nextButton.layer.cornerRadius = nextButton.bounds.width / 20.0
    }
    //改行ボタンがつく
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let signupviewcontroller = segue.destination as! SignUpViewController
        signupviewcontroller.passedName = passedName
        signupviewcontroller.passedEmail = passedEmail
        signupviewcontroller.passedPassword = passwordTextField.text
    }
    
    @IBAction func next() {
        if (passwordTextField.text?.count)! < 6 {
            print("文字数が足りません")
            return
        } else {
            performSegue(withIdentifier: "toSignUp", sender: nil)
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

}

