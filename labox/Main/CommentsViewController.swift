//
//  CommentsViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/22.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit
import NCMB
import PKHUD
import Kingfisher
import NYXImagesKit

class CommentsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //前のスライドから渡されるため
    var postId: String!

    var comments = [Comment]()
    
    @IBOutlet var commentTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        commentTableView.dataSource = self

        commentTableView.tableFooterView = UIView()
        
        //カスタムセルの登録
        //1行目でxibファイルの取得
        let nib = UINib(nibName: "CommentTableViewCell", bundle: Bundle.main)
        //2行目で取得したファイルをtimelineTableViewに登録
        commentTableView.register(nib, forCellReuseIdentifier: "Cell")
        commentTableView.rowHeight = 100

        loadComments()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //idをつけたcellの取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! CommentTableViewCell
        // let createDateLabel = cell.viewWithTag(4) as! UILabel

        // ユーザー画像を丸く
        cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
        cell.userImageView.layer.masksToBounds = true

        let user = comments[indexPath.row].user
        let file = NCMBFile.file(withName: user.objectId + "user", data: nil) as! NCMBFile
        file.getDataInBackground { (data, error) in
            if error != nil {
                HUD.flash(.labeledError(title: "画像取得エラー", subtitle: ""), delay: 2.0)
            } else {
                if data != nil {
                    let image = UIImage(data: data!)
                    cell.userImageView.image = image
                }
            }
        }
        cell.nameLabel.text = user.displayName
        cell.commentTextView.text = comments[indexPath.row].text
        let date = stringFromDate(date: comments[indexPath.row].createDate, format: "yyyy年MM月dd日 HH時mm分ss秒 ")
        cell.dateLabel.text = date

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    //呼び出し
    func loadComments() {
        comments = [Comment]()
        let query = NCMBQuery(className: "Comment")
        query?.whereKey("postId", equalTo: postId)
        //Comment呼び出しと同時にユーザーの情報もとる
        query?.includeKey("user")
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                HUD.flash(.error, delay: 2)
            } else {
                for commentObject in result as! [NCMBObject] {
                    // コメントをしたユーザーの情報を取得
                    //objectforkeyで引っ張り出した情報をusermodelに格納
                    let user = commentObject.object(forKey: "user") as! NCMBUser
                    let userModel = User(objectId: user.objectId, userName: user.userName, displayName: user.object(forKey: "displayName") as! String)
                    //userModel.displayName = user.object(forKey: "displayName") as? String

                    // コメントの文字を取得
                    let text = commentObject.object(forKey: "text") as! String

                    // Commentクラスに格納
                    let comment = Comment(postId: self.postId, user: userModel, text: text, createDate: commentObject.createDate)
                    self.comments.append(comment)

                    // テーブルをリロード
                    self.commentTableView.reloadData()
                }
            }
        })
    }

    //アラートコントローラーの中でメモを書く
    @IBAction func addComment() {
        let alert = UIAlertController(title: "コメント", message: "コメントを入力して下さい", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            HUD.show(.progress)
            let object = NCMBObject(className: "Comment")
            object?.setObject(self.postId, forKey: "postId")
            object?.setObject(NCMBUser.current(), forKey: "user")
            object?.setObject(alert.textFields?.first?.text, forKey: "text")
            object?.saveInBackground({ (error) in
                if error != nil {
                    HUD.flash(.error, delay: 2)
                } else {
                    HUD.hide()
                    self.loadComments()
                }
            })
        }

        alert.addAction(cancelAction)
        alert.addAction(okAction)
        alert.addTextField { (textField) in
            textField.placeholder = "ここにコメントを入力"
        }
        self.present(alert, animated: true, completion: nil)
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
