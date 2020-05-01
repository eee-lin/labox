//
//  MyNavigationViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/25.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit

class MyNavigationViewController: UINavigationController {

    // MyUINavigationController.class
    override func viewDidLoad() {
            super.viewDidLoad()
            //　ナビゲーションバーの背景色
            navigationBar.barTintColor = UIColor(red: 53/255, green: 72/255, blue: 79/255, alpha: 1.0)
            // ナビゲーションバーのアイテムの色　（戻る　＜　とか　読み込みゲージとか）
            navigationBar.tintColor = .white
            // ナビゲーションバーのテキストを変更する
            navigationBar.titleTextAttributes = [
                // 文字の色
                .foregroundColor: UIColor.white
            ]
            // Do any additional setup after loading the view.
        }

}
