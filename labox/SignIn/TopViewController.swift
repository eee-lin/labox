//
//  TopViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/17.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit

class TopViewController: UIViewController {
    
    @IBOutlet var startButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

       //変更ボタンを丸くする
        startButton.layer.cornerRadius = startButton.bounds.width / 20.0
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
