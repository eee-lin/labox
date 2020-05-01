//
//  KiyakuViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/15.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit

class KiyakuViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var agreeButton:UIButton!
    @IBOutlet var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        scrollView.contentSize.height = CGFloat(signOf: 414, magnitudeOf: 3500)
        
        // 枠を角丸にする
        agreeButton.layer.cornerRadius = agreeButton.bounds.width / 30.0
        agreeButton.layer.masksToBounds = true
    }

    
    @IBAction func agree(){
    //        navigationController?.popViewController(animated: true)
    //        今回はmodalで遷移しているからdismissで
          self.dismiss(animated: true, completion: nil)
    }
        
    @IBAction func back() {
        self.navigationController?.popViewController(animated: true)
    }

}
