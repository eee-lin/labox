//
//  MyImageDetailViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/23.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit
import NCMB
import PKHUD
import Kingfisher

class MyImageDetailViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var selectedPost: Post?
    //var selectedUser: NCMBUser?
    var count: Int = 0
    var items = [String]()
    var selectedImage: String!
    
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

    @IBOutlet var imagesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //UIScrollViewのインスタンス作成
        let scrollView = UIScrollView()
        scrollView.delegate = self
        
        //scrollViewの大きさを設定。
        scrollView.frame = self.view.frame

        //スクロール領域の設定
        scrollView.contentSize = CGSize(width:1000, height:1000)

        //scrollViewをviewのSubViewとして追加
        self.view.addSubview(scrollView)
        
        // 枠のカラー
                textTextView.layer.borderColor =  UIColor(red: 53/255, green: 72/255, blue: 79/255, alpha: 1.0).cgColor

        //        postTextView.frame = CGRect(x : 100, y : 100, width : 100, height : 100)
                
                // 枠の幅
                textTextView.layer.borderWidth = 1.0
                
                // 枠を角丸にする
                textTextView.layer.cornerRadius = textTextView.bounds.width / 30.0
                textTextView.layer.masksToBounds = true
        
        //collectionViewの関連付け
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
        
        // レイアウト設定
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        imagesCollectionView.collectionViewLayout = layout
        
        recorddateLabel.text = selectedPost?.recorddate
        titleLabel.text = selectedPost?.title
        textTextView.text = selectedPost?.text
        let date = stringFromDate(date: selectedPost!.createDate, format: "yyyy年MM月dd日 HH時mm分ss秒 ")
        dateLabel.text = date
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
            
            // "Cell" はストーリーボードで設定したセルのID
            let cell =
                imagesCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                   for: indexPath)
            
            // Tag番号を使ってImageViewのインスタンス生成
            let photoimageView = cell.contentView.viewWithTag(1) as! UIImageView
            // 画像配列の番号で指定された要素の名前の画像をUIImageとする
            let imageUrl = items[indexPath.row]
            
            photoimageView.kf.setImage(with: URL(string: imageUrl))
            
            
            return cell
        }
        
    //    func numberOfSections(in collectionView: UICollectionView) -> Int {
    //        // section数は１つ
    //        return 1
    //    }
        
        //何枚セルを入れるか
        func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {
            // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
            return items.count
        }
    
       // Cell が選択された場合
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        // [indexPath.row] から画像名を探し、UImage を設定
        selectedImage = items[indexPath.row]
        
        // SubViewController へ遷移するために Segue を呼び出す
        performSegue(withIdentifier: "toSubImage",sender: nil)
       }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toEdit" {
            let editmypostViewController = segue.destination as! EditMyPostViewController
            //prepare for segueが呼ばれた時の今選択されているセルを代入する
            editmypostViewController.selectedPost = selectedPost
            editmypostViewController.items = items
            //showotherViewController.selectedUser = selectedUser
        }
        if segue.identifier == "toComments"  {
            let commentsViewController = segue.destination as! CommentsViewController
            //prepare for segueが呼ばれた時の今選択されているセルを代入する
            commentsViewController.postId = selectedPost?.objectId
        }
        if segue.identifier == "toSubImage" {
            let subimageViewController = segue.destination as! SubImageViewController
            subimageViewController.selectedImg = selectedImage
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
        
        //なんで二重に警告ができないの？？
        let deleteAction = UIAlertAction(title: "削除", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
            self.delete()
            self.navigationController?.popViewController(animated: true)
//            let alert = UIAlertController(title: "削除", message: "投稿を削除しますか？", preferredStyle: .alert)
//            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
//                self.delete()
//                self.dismiss(animated: true, completion: nil)
//                self.navigationController?.popViewController(animated: true)
//            })
//            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
//                alert.dismiss(animated: true, completion: nil)
//            })
//            alert.addAction(okAction)
//            alert.addAction(cancelAction)
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
                print(error)
            } else {
                let post = result as! [NCMBObject]
                let postObject = post.first
                postObject?.deleteInBackground({ (error) in
                    if error != nil {
                        print(error)
                    } else {
                        print("delete succeed")
                    }
                })
            }
        })
    }
    
    @IBAction func gotoComments() {
        performSegue(withIdentifier: "toComments", sender: nil)
    }
    
}
