//
//  DoneSignUpViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/06/11.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit
import NCMB
import PKHUD

class DoneSignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var displayNameTextField: UITextField!
    @IBOutlet var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        displayNameTextField.delegate = self
        //変更ボタンを丸くする
        startButton.layer.cornerRadius = startButton.bounds.width / 20.0
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func next() {
        if (displayNameTextField.text!.count > 0) {
            performSegue(withIdentifier: "toFirstSignUp", sender: nil)
        } else {
            HUD.flash(.labeledError(title: "ユーザー名を記入してください", subtitle: ""), delay: 1.0)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFirstSignUp" {
            let firstSignInViewController = segue.destination as! FirstSignInViewController
            //prepare for segueが呼ばれた時の今選択されているセルを代入する
            firstSignInViewController.selectedTextField = displayNameTextField.text!
        }
    }

}
