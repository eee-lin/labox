//
//  MyPostViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/21.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit
import NCMB
import PKHUD

class MyPostViewController: UIViewController {

    var selectedPost: Post?
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var textTextView: UITextView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var heartButton: UIButton!
    @IBOutlet var userImageView: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0

        nameLabel.text = selectedPost?.user.displayName
        textTextView.text = selectedPost?.text
        let date = stringFromDate(date: selectedPost!.createDate, format: "yyyy年MM月dd日 HH時mm分ss秒 ")
        dateLabel.text = date
        //画像を取得
        let user = selectedPost?.user
        let file = NCMBFile.file(withName: user!.objectId + "user", data: nil) as! NCMBFile
        file.getDataInBackground { (data, error) in
            if error != nil {
                let alert = UIAlertController(title: "画像取得エラー", message: error!.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in

                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                if data != nil {
                    //dataの中身があれば画像を表示
                    let image = UIImage(data: data!)
                    self.userImageView.image = image
                }
            }
        }
    }
    

//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toComments"  {
//            let commentsViewController = segue.destination as! CommentsViewController
//            //prepare for segueが呼ばれた時の今選択されているセルを代入する
//            commentsViewController.postId = selectedPost?.objectId
//        }
//    }
    
    func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
}

