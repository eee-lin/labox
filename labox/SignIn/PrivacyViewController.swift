//
//  PrivacyViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/15.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit
import WebKit

class PrivacyViewController: UIViewController, WKUIDelegate {
    
    @IBOutlet var agreeButton:UIButton!
    @IBOutlet var contentView: UIView!
    var cancelButton:UIButton!
    var webView: WKWebView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // 枠を角丸にする
//        agreeButton.layer.cornerRadius = agreeButton.bounds.width / 30.0
//        agreeButton.layer.masksToBounds = true
        
        let myURL = URL(string:"https://qiita.com/masuhara/private/42bea0635e88529303fe")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
        //キャンセルボタン
        cancelButton = UIButton()
        cancelButton.frame = CGRect(x: 20, y:100, width: 50, height: 50)
        cancelButton.setImage(UIImage(named:"icons8-back-arrow-50"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        self.view.addSubview(cancelButton)
    }


    @IBAction func agree(){
    //        navigationController?.popViewController(animated: true)
    //        今回はmodalで遷移しているからdismissで
            self.dismiss(animated: true, completion: nil)
        }
        
        @IBAction func back() {
            self.navigationController?.popViewController(animated: true)
        }

    
    //webViewを隠すメソッド
    @objc func cancel(){
        //すべて非表示にする
        webView.isHidden = true
        cancelButton.isHidden = true
        dismiss(animated: true, completion: nil)
    }
}
