//
//  MyDetailViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/23.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit
import NCMB
import PKHUD
import Kingfisher

class MyDetailViewController: UIViewController {

    var selectedPost: Post?
//    var selectedUser: NCMBUser?
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var recorddateLabel: UILabel!
    @IBOutlet var labnameLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var textTextView: UITextView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var heartButton: UIButton!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var goCommentButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recorddateLabel.text = selectedPost?.recorddate
        titleLabel.text = selectedPost?.title
        textTextView.text = selectedPost?.text
        let date = stringFromDate(date: selectedPost!.createDate, format: "yyyy年MM月dd日 HH時mm分ss秒 ")
        dateLabel.text = date
        
        // 枠のカラー
                textTextView.layer.borderColor =  UIColor(red: 53/255, green: 72/255, blue: 79/255, alpha: 1.0).cgColor

        //        postTextView.frame = CGRect(x : 100, y : 100, width : 100, height : 100)
                
                // 枠の幅
                textTextView.layer.borderWidth = 1.0
                
                // 枠を角丸にする
                textTextView.layer.cornerRadius = textTextView.bounds.width / 30.0
                textTextView.layer.masksToBounds = true
        
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "toEdit" {
            let editmypostViewController = segue.destination as! EditMyPostViewController
            //prepare for segueが呼ばれた時の今選択されているセルを代入する
            editmypostViewController.selectedPost = selectedPost
            //showotherViewController.selectedUser = selectedUser
        }
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
    
    @IBAction func select() {
        let alert = UIAlertController()
        //alertは真ん中にポンと出てくる
        //actionSheetはアプリの下からにゅっと出てくる
        
        let editAction = UIAlertAction(title: "編集", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.performSegue(withIdentifier: "toEdit", sender: nil)
        }
        
        let deleteAction = UIAlertAction(title: "削除", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.delete()
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            //キャンセルボタンを押した時のアクション
        }
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        //alertにactionを加える
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func tapImage() {
        let userpageViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserPageViewController") as! UINavigationController

        present(userpageViewController, animated: true, completion: nil)

    }
    
    func delete() {
        let query = NCMBQuery(className: "Post")
        query?.whereKey("objectId", equalTo: selectedPost?.objectId)
        query?.findObjectsInBackground({ (result, error) in
        if error != nil {
            HUD.flash(.error)
            } else {
                let post = result as! [NCMBObject]
                let postObject = post.first
                postObject?.deleteInBackground({ (error) in
                    if error != nil {
                        HUD.flash(.labeledError(title: "削除できませんでした", subtitle: ""))
                    } else {
                        print("delete succeed")
                    }
                })
            }
        })
    }
    
}


