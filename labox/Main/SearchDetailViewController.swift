//
//  SearchDetailViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/27.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit
import NCMB
import PKHUD

class SearchDetailViewController: UIViewController {

    var selectedPost: Post?
    var selectedUser: NCMBUser?
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var recorddateLabel: UILabel!
    @IBOutlet var labnameLabel: UILabel!
    @IBOutlet var firstlabnameLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var textTextView: UITextView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var heartButton: UIButton!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var goUserButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedPost?.user.labname != nil {
            labnameLabel.text = selectedPost?.user.labname
        } else {
            labnameLabel.isHidden = true
            firstlabnameLabel.isHidden = true
        }
        // 枠のカラー
        textTextView.layer.borderColor =  UIColor(red: 53/255, green: 72/255, blue: 79/255, alpha: 0.5).cgColor
        // 枠の幅
        textTextView.layer.borderWidth = 1.0
                
        // 枠を角丸にする
        textTextView.layer.cornerRadius = textTextView.bounds.width / 30.0
        textTextView.layer.masksToBounds = true
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0

        nameLabel.text = selectedPost?.user.userName
        textTextView.text = selectedPost?.text
        let date = stringFromDate(date: selectedPost!.createDate, format: "yyyy年MM月dd日 HH時mm分ss秒 ")
        dateLabel.text = date
        //画像を取得
        let user = selectedPost?.user
        let file = NCMBFile.file(withName: user!.objectId + "user", data: nil) as! NCMBFile
        file.getDataInBackground { (data, error) in
            if error != nil {
                HUD.flash(.labeledError(title: "画像取得エラー", subtitle: "通信状況を確認してください"), delay: 1)
            } else {
                if data != nil {
                    //dataの中身があれば画像を表示
                    let image = UIImage(data: data!)
                    self.userImageView.image = image
                }
            }
        }
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toComments"  {
            let commentsViewController = segue.destination as! CommentsViewController
            //prepare for segueが呼ばれた時の今選択されているセルを代入する
            commentsViewController.postId = selectedPost?.objectId
        }
    }
    
    func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    @IBAction func back(){
        navigationController?.popViewController(animated: true)
    }
    
}

