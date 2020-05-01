//
//  UserImageDetailViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/24.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit
import NCMB
import PKHUD
import Kingfisher

class UserImageDetailViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var selectedPost: Post?
    var selectedUser: NCMBUser?
    var count: Int = 0
    var items = [String]()
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var recorddateLabel: UILabel!
    @IBOutlet var firstlabnameLabel: UILabel!
    @IBOutlet var labnameLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var textTextView: UITextView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var heartButton: UIButton!
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var goUserButton: UIButton!

    @IBOutlet var imagesCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(items.count)
        //collectionViewの関連付け
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
        
        // レイアウト設定
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.sectionInset = UIEdgeInsets(top: 24, left: 24, bottom: 24, right: 24)
        imagesCollectionView.collectionViewLayout = layout
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        
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

        nameLabel.text = selectedPost?.user.userName
        recorddateLabel.text = selectedPost?.recorddate
        titleLabel.text = selectedPost?.title
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
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toUser" {
            let showotherViewController = segue.destination as! ShowOtherViewController
            //prepare for segueが呼ばれた時の今選択されているセルを代入する
            showotherViewController.selectedPost = selectedPost
            showotherViewController.selectedUser = selectedUser
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
    
//    @IBAction func movetoUser() {
//        performSegue(withIdentifier: "toUser", sender: nil)
//    }

//    @IBAction func tapImage() {
//        let userpageViewController = self.storyboard?.instantiateViewController(withIdentifier: "UserPageViewController") as! UINavigationController
//
//        present(userpageViewController, animated: true, completion: nil)
//
//    }
    
}
