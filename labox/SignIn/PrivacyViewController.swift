//
//  PrivacyViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/15.
//  Copyright © 2020 Yilin. All rights reserved.
//

import SnapKit
import UIKit

class PrivacyViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var agreeButton:UIButton!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var privacyTextView: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setScrollView(content: contentView)
        scrollView.delegate = self
        //scrollView.contentSize.height = CGFloat(signOf: 414, magnitudeOf: 3500)
        
        // 枠を角丸にする
        agreeButton.layer.cornerRadius = agreeButton.bounds.width / 30.0
        agreeButton.layer.masksToBounds = true
        
        self.view.addSubview(self.scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
//            make.left.right.equalToSuperview().inset(0) //左右は固定マージン
//            make.height.lessThanOrEqualToSuperview() //scrollView高さ最大値はsuperview
//            make.center.equalToSuperview() //scrollViewを中央配置
         }
        
        self.scrollView.addSubview(contentView)

         contentView.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.scrollView)
            make.left.right.equalTo(self.view)
            make.width.equalTo(self.scrollView)
            make.height.equalTo(self.scrollView)
            
//            make.width.equalTo(scrollView.frameLayoutGuide) //縦スクロール設定
//            make.left.right.bottom.equalTo(scrollView.contentLayoutGuide) //contentLayoutGuideに合わせる
//            make.top.bottom.greaterThanOrEqualTo(scrollView.contentLayoutGuide) //条件で上下をcontentLayoutGuideに合わせる
            //make.center.lessThanOrEqualToSuperview() //条件でscrollviewを中央配置
         }
        
        self.contentView.addSubview(privacyTextView)
        privacyTextView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView).inset(UIEdgeInsets(top: 0, left: 0, bottom: 130, right: 0))
        }
        contentView.translatesAutoresizingMaskIntoConstraints = false
        //scrollView.addSubview(contentView)
    }
    
    func setScrollView(content: UIView) {
        // called in ViewController
        
        self.edgesForExtendedLayout = []
        let scrollView = UIScrollView()
        let wrapper = UIView()
        
        self.view.addSubview(scrollView)
        scrollView.addSubview(content)
        
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.topAnchor as! ConstraintRelatableTarget)
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        wrapper.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            
            // only vertical scroll
            make.width.equalToSuperview()
            
            // only horizontal scroll
            //make.height.equalToSuperview()
        }
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
