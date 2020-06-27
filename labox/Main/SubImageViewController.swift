//
//  SubImageViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/05/21.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit

class SubImageViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    var selectedImg: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        imageView.kf.setImage(with: URL(string: selectedImg))
        // 画像のアスペクト比を維持しUIImageViewサイズに収まるように表示
        imageView.contentMode = UIView.ContentMode.scaleAspectFit
    
    }
}
