//
//  FirstPageSignUpViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/15.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit

class FirstpageSignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.delegate = self
        emailTextField.delegate = self
        //変更ボタンを丸くする
        nextButton.layer.cornerRadius = nextButton.bounds.width / 20.0
    }
    
    //改行ボタンがつく
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let secondpageviewcontroller = segue.destination as! SecondpageSignUpViewController
        secondpageviewcontroller.passedName = nameTextField.text
        secondpageviewcontroller.passedEmail = emailTextField.text
    }

    @IBAction func next() {
        if (nameTextField.text == nil || emailTextField.text == nil) {
            print("入力してください")
            return
        } else {
            performSegue(withIdentifier: "toSecond", sender: nil)
        }
    }
}
