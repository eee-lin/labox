//
//  ViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/15.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit
import NCMB
import PKHUD
import Kingfisher
import SwiftDate
import FSCalendar

//extension ViewController: FSCalendarDataSource, FSCalendarDelegate {
//    // MARK: - FSCalendar Delegate
//    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//
//        let tmpDate = Calendar(identifier: .gregorian)
//        let year = tmpDate.component(.year, from: date)
//        let month = tmpDate.component(.month, from: date)
//        let day = tmpDate.component(.day, from: date)
//        dateLabel.text = "\(year)/\(month)/\(day)"
//
//        print("didSelect")
//        //日付選択時に呼ばれるメソッド
////        diaryArray = Diary.search(date: date)
////
////        diaryTitleTableView.reloadData()
//
//    }
//
//}

class ImageLoader {
    func loadImage(url: URL, completion: @escaping (_ succeeded: Bool, _ image: UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                completion(true, UIImage(data: data))
            }
        }.resume()
    }
}

//Timeline_4_TableViewCellDelegate, Timeline_5_TableViewCellDelegate
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TimelineTableViewCellDelegate, Timeline_1_TableViewCellDelegate, Timeline_2_TableViewCellDelegate, Timeline_3_TableViewCellDelegate{
    
    var selectedPost: Post?
    var posts = [Post]()
    var comments = [Comment]()
    var followings = [NCMBUser]()
    var users = [NCMBUser]()
    var items1 = [String]()
    var items2 = [String]()
    var items3 = [String]()
    
    //@IBOutlet var tweetButton: UIButton! //ボタンを定義
    @IBOutlet var timelineTableView: UITableView!
    
//    @IBOutlet weak var calendar: FSCalendar!
//    @IBOutlet var dateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        calendar.delegate = self
//        calendar.dataSource = self
        
        
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        //TableViewの不要な線を消す
        timelineTableView.tableFooterView = UIView()
        
        //カスタムセルの登録
        //1行目でxibファイルの取得
        let nib0 = UINib(nibName: "TimelineTableViewCell", bundle: Bundle.main)
        //2行目で取得したファイルをtimelineTableViewに登録
        timelineTableView.register(nib0, forCellReuseIdentifier: "Cell0")
        
        let nib1 = UINib(nibName: "Timeline_1_TableViewCell", bundle: Bundle.main)
        timelineTableView.register(nib1, forCellReuseIdentifier: "Cell1")
        
        let nib2 = UINib(nibName: "Timeline_2_TableViewCell", bundle: Bundle.main)
        timelineTableView.register(nib2, forCellReuseIdentifier: "Cell2")
        
        let nib3 = UINib(nibName: "Timeline_3_TableViewCell", bundle: Bundle.main)
        timelineTableView.register(nib3, forCellReuseIdentifier: "Cell3")
        
        // 引っ張って更新
        setRefreshControl()
        
        loadTimeline()
        //loadComments()
        
        // フォロー中のユーザーを取得する。その後にフォロー中のユーザーの投稿のみ読み込み
        loadFollowingUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadTimeline()
        if posts.count == 0 {
            HUD.flash(.labeledImage(image: UIImage(named: "icons8-メモ-64.png"), title: "投稿がありません", subtitle: "+を押してください"), delay: 2)
        }
        //loadComments()
    }

    //1. TableViewに関するデータの個数の表示
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            //配列内の個数より多くならないように数を設定する
            return posts.count
        }

        //2. TableViewに表示するデータの内容
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            if posts[indexPath.row].howmanyimages == 0 {
                //idをつけたcellの取得
                        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell0") as! TimelineTableViewCell
                        
                        cell.delegate = self
                        cell.tag = indexPath.row
                //        cell.profileImageView.image = posts[indexPath.row].object(forKey: "")
                        let user = posts[indexPath.row].user
                        //画像を取得
                        let file = NCMBFile.file(withName: user.objectId + "user", data: nil) as! NCMBFile
                        file.getDataInBackground { (data, error) in
                            if error != nil {
                                cell.userImageView.image = UIImage(named: "丸底フラスコのフリーアイコン3.png")
//                                let alert = UIAlertController(title: "画像取得エラー", message: error!.localizedDescription, preferredStyle: .alert)
//                                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
//
//                                })
//                                alert.addAction(okAction)
//                                self.present(alert, animated: true, completion: nil)
                            } else {
                                if data != nil {
                                    //dataの中身があれば画像を表示
                                    let image = UIImage(data: data!)
                                    cell.userImageView.image = image
                                }
                            }
                        }
//                        cell.doDateLabel.text = posts[indexPath.row].recorddate
//                        cell.doDateLabel.layer.cornerRadius = cell.doDateLabel.bounds.width / 20.0
//                        cell.doDateLabel.clipsToBounds = true
                cell.doDateLabel.layer.borderColor = UIColor(red: 53/255, green: 72/255, blue: 79/255, alpha: 1.0).cgColor
                cell.doDateLabel.layer.borderWidth = 2
                cell.doDateLabel.layer.cornerRadius = cell.doDateLabel.bounds.width / 20.0
                cell.doDateLabel.layer.masksToBounds = true
                cell.doDateLabel.text = posts[indexPath.row].recorddate
                
                
                        cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
                        cell.userImageView.clipsToBounds = true
                        cell.titleLabel.text = posts[indexPath.row].title
                        cell.nameLabel.text = posts[indexPath.row].user.userName
                        let date = stringFromDate(date: posts[indexPath.row].createDate, format: "yyyy年MM月dd日 HH時mm分ss秒 ")
                        cell.dateLabel.text = date
                        
                        // Likeによってハートの表示を変える
                        if posts[indexPath.row].isLiked == true {
                            cell.likeButton.setImage(UIImage(named: "icons8-いいね-24 (1).png"), for: .normal)
                        } else {
                            cell.likeButton.setImage(UIImage(named: "icons8-ハート-48.png"), for: .normal)
                        }

                         //Likeの数
                        cell.countLikeLabel.text = "\(posts[indexPath.row].likeCount)"
                        //Commentの数
                        //cell.countCommentsLabel.text = "\(comments[indexPath.row].commentsCount)"
                        
                return cell
            } else if posts[indexPath.row].howmanyimages == 1 {
                //idをつけたcellの取得
                        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1") as! Timeline_1_TableViewCell
                        
                        cell.delegate = self
                        cell.tag = indexPath.row
                //        cell.profileImageView.image = posts[indexPath.row].object(forKey: "")
                        let user = posts[indexPath.row].user
                        //画像を取得
                        let file = NCMBFile.file(withName: user.objectId + "user", data: nil) as! NCMBFile
                        file.getDataInBackground { (data, error) in
                            if error != nil {
                                cell.userImageView.image = UIImage(named: "丸底フラスコのフリーアイコン3.png")
                            } else {
                                if data != nil {
                                    //dataの中身があれば画像を表示
                                    let image = UIImage(data: data!)
                                    cell.userImageView.image = image
                                }
                            }
                        }
                //画像を丸くする
                cell.upImageView.layer.cornerRadius = cell.upImageView.bounds.width / 30.0
                cell.upImageView.clipsToBounds = true
                
                        cell.doDateLabel.layer.borderColor = UIColor(red: 53/255, green: 72/255, blue: 79/255, alpha: 1.0).cgColor
                        cell.doDateLabel.layer.borderWidth = 2
                        cell.doDateLabel.layer.cornerRadius = cell.doDateLabel.bounds.width / 20.0
                        cell.doDateLabel.layer.masksToBounds = true
                cell.doDateLabel.text = posts[indexPath.row].recorddate
                
                        cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
                        cell.userImageView.clipsToBounds = true
                        cell.titleLabel.text = posts[indexPath.row].title
                        print(posts[indexPath.row].text)
                        cell.nameLabel.text = posts[indexPath.row].user.userName
                        let date = stringFromDate(date: posts[indexPath.row].createDate, format: "yyyy年MM月dd日 HH時mm分ss秒 ")
                        cell.dateLabel.text = date
                        
                        // Likeによってハートの表示を変える
                        if posts[indexPath.row].isLiked == true {
                            cell.likeButton.setImage(UIImage(named: "icons8-いいね-24 (1).png"), for: .normal)
                        } else {
                            cell.likeButton.setImage(UIImage(named: "icons8-ハート-48.png"), for: .normal)
                        }

                        // Likeの数
                        cell.countLikeLabel.text = "\(posts[indexPath.row].likeCount)"
                        //Commentの数
                        //cell.countCommentsLabel.text = "\(comments[indexPath.row].commentsCount)"
                        //print(comments[indexPath.row].commentsCount)
                
                        let imageUrl1 = posts[indexPath.row].imageUrl1
                        print(imageUrl1)
                        cell.upImageView.kf.setImage(with: URL(string: imageUrl1))

                return cell
            } else if posts[indexPath.row].howmanyimages == 2 {
                //idをつけたcellの取得
                        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2") as! Timeline_2_TableViewCell
                        
                        cell.delegate = self
                        cell.tag = indexPath.row
                //        cell.profileImageView.image = posts[indexPath.row].object(forKey: "")
                        let user = posts[indexPath.row].user
                        //画像を取得
                        let file = NCMBFile.file(withName: user.objectId + "user", data: nil) as! NCMBFile
                        file.getDataInBackground { (data, error) in
                            if error != nil {
                                cell.userImageView.image = UIImage(named: "丸底フラスコのフリーアイコン3.png")
                            } else {
                                if data != nil {
                                    //dataの中身があれば画像を表示
                                    let image = UIImage(data: data!)
                                    cell.userImageView.image = image
                                }
                            }
                        }
                //画像を丸くする
                cell.up2ImageView.layer.cornerRadius = cell.up2ImageView.bounds.width / 30.0
                cell.up2ImageView.clipsToBounds = true
                
                cell.up1ImageView.layer.cornerRadius = cell.up1ImageView.bounds.width / 30.0
                cell.up1ImageView.clipsToBounds = true
                
                        cell.doDateLabel.layer.borderColor = UIColor(red: 53/255, green: 72/255, blue: 79/255, alpha: 1.0).cgColor
                        cell.doDateLabel.layer.borderWidth = 2
                        cell.doDateLabel.layer.cornerRadius = cell.doDateLabel.bounds.width / 20.0
                        cell.doDateLabel.layer.masksToBounds = true
                cell.doDateLabel.text = posts[indexPath.row].recorddate
                
                        cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
                        cell.userImageView.clipsToBounds = true
                        cell.titleLabel.text = posts[indexPath.row].title
                        cell.nameLabel.text = posts[indexPath.row].user.userName
                        let date = stringFromDate(date: posts[indexPath.row].createDate, format: "yyyy年MM月dd日 HH時mm分ss秒 ")
                        cell.dateLabel.text = date
                        
                        // Likeによってハートの表示を変える
                        if posts[indexPath.row].isLiked == true {
                            cell.likeButton.setImage(UIImage(named: "icons8-いいね-24 (1).png"), for: .normal)
                        } else {
                            cell.likeButton.setImage(UIImage(named: "icons8-ハート-48.png"), for: .normal)
                        }

                        // Likeの数
                        cell.countLikeLabel.text = "\(posts[indexPath.row].likeCount)"
                        //Commentの数
                        //cell.countCommentsLabel.text = "\(comments[indexPath.row].commentsCount)"
                        
                        let imageUrl1 = posts[indexPath.row].imageUrl1
                        let imageUrl2 = posts[indexPath.row].imageUrl2
                        cell.up1ImageView.kf.setImage(with: URL(string: imageUrl1))
                        cell.up2ImageView.kf.setImage(with: URL(string: imageUrl2))
                return cell
            } else {
                //idをつけたcellの取得
                        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3") as! Timeline_3_TableViewCell
                        
                        cell.delegate = self
                        cell.tag = indexPath.row
                //        cell.profileImageView.image = posts[indexPath.row].object(forKey: "")
                        let user = posts[indexPath.row].user
                        //画像を取得
                        let file = NCMBFile.file(withName: user.objectId + "user", data: nil) as! NCMBFile
                        file.getDataInBackground { (data, error) in
                            if error != nil {
                                cell.userImageView.image = UIImage(named: "丸底フラスコのフリーアイコン3.png")
                            } else {
                                if data != nil {
                                    //dataの中身があれば画像を表示
                                    let image = UIImage(data: data!)
                                    cell.userImageView.image = image
                                }
                            }
                        }
                //画像を丸くする
                cell.up2ImageView.layer.cornerRadius = cell.up2ImageView.bounds.width / 30.0
                cell.up2ImageView.clipsToBounds = true
                
                cell.up1ImageView.layer.cornerRadius = cell.up1ImageView.bounds.width / 30.0
                cell.up1ImageView.clipsToBounds = true
                
                cell.up3ImageView.layer.cornerRadius = cell.up3ImageView.bounds.width / 30.0
                cell.up3ImageView.clipsToBounds = true
                
                        cell.doDateLabel.layer.borderColor = UIColor(red: 53/255, green: 72/255, blue: 79/255, alpha: 1.0).cgColor
                        cell.doDateLabel.layer.borderWidth = 2
                        cell.doDateLabel.layer.cornerRadius = cell.doDateLabel.bounds.width / 20.0
                        cell.doDateLabel.layer.masksToBounds = true
                cell.doDateLabel.text = posts[indexPath.row].recorddate
                
                        cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
                        cell.userImageView.clipsToBounds = true
                        cell.titleLabel.text = posts[indexPath.row].title
                        cell.nameLabel.text = posts[indexPath.row].user.userName
                        let date = stringFromDate(date: posts[indexPath.row].createDate, format: "yyyy年MM月dd日 HH時mm分ss秒 ")
                        cell.dateLabel.text = date
                        
                        // Likeによってハートの表示を変える
                        if posts[indexPath.row].isLiked == true {
                            cell.likeButton.setImage(UIImage(named: "icons8-いいね-24 (1).png"), for: .normal)
                        } else {
                            cell.likeButton.setImage(UIImage(named: "icons8-ハート-48.png"), for: .normal)
                        }

                        // Likeの数
                        cell.countLikeLabel.text = "\(posts[indexPath.row].likeCount)"
                        //Commentの数
                        //cell.countCommentsLabel.text = "\(comments[indexPath.row].commentsCount)"
                        
                        let imageUrl1 = posts[indexPath.row].imageUrl1
                        let imageUrl2 = posts[indexPath.row].imageUrl2
                        let imageUrl3 = posts[indexPath.row].imageUrl3
                        cell.up1ImageView.kf.setImage(with: URL(string: imageUrl1))
                        cell.up2ImageView.kf.setImage(with: URL(string: imageUrl2))
                        cell.up3ImageView.kf.setImage(with: URL(string: imageUrl3))
                
                return cell
            }
        }


        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            selectedPost = posts[indexPath.row]
            
            if selectedPost?.howmanyimages == 1 {
                let imageUrl1 = selectedPost?.imageUrl1
                self.items1.append(imageUrl1!)
                print(items1)
            } else if selectedPost?.howmanyimages == 2 {
                let imageUrl1 = selectedPost?.imageUrl1
                let imageUrl2 = selectedPost?.imageUrl2
                self.items2.append(imageUrl1!)
                self.items2.append(imageUrl2!)
                print(items2)
            } else {
                let imageUrl1 = selectedPost?.imageUrl1
                let imageUrl2 = selectedPost?.imageUrl2
                let imageUrl3 = selectedPost?.imageUrl3
                self.items3.append(imageUrl1!)
                self.items3.append(imageUrl2!)
                self.items3.append(imageUrl3!)
                print(items3)
            }
            
            if selectedPost?.howmanyimages == 0 {
                self.performSegue(withIdentifier: "toDetail", sender: nil)
            }
            
            else if selectedPost!.howmanyimages >= 1 {
                self.performSegue(withIdentifier: "toDetail1", sender: nil)
                
            }
            
            //選択状態解除
            timelineTableView.deselectRow(at: indexPath, animated: true)
        }
    
    /*
     セルの高さを設定
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

//        tableView.estimatedRowHeight = 130 //セルの高さ
//        return UITableView.automaticDimension //自動設定
        if posts[indexPath.row].howmanyimages == 0 {
            return 100
        } else {
            return 200
        }
     }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetail" {
            let detailViewController = segue.destination as! DetailViewController
            let selectedIndex = timelineTableView.indexPathForSelectedRow!
            //prepare for segueが呼ばれた時の今選択されているセルを代入する
            detailViewController.selectedPost = posts[selectedIndex.row]
            detailViewController.selectedUser = users[selectedIndex.row]
        }
        
        if segue.identifier == "toDetail1" {
            let imagedetailviewcontroller = segue.destination as! ImageDetailViewController
            let selectedIndex = timelineTableView.indexPathForSelectedRow!
            //prepare for segueが呼ばれた時の今選択されているセルを代入する
            imagedetailviewcontroller.selectedPost = posts[selectedIndex.row]
            imagedetailviewcontroller.selectedUser = users[selectedIndex.row]
            if posts[selectedIndex.row].howmanyimages == 1 {
//                imagedetailviewcontroller.items[0] = items1[0]
                imagedetailviewcontroller.items = items1
                items1 = [String]()
                print(items1)
            } else if posts[selectedIndex.row].howmanyimages == 2 {
                imagedetailviewcontroller.items = items2
//                imagedetailviewcontroller.items[0] = items2[0]
//                imagedetailviewcontroller.items[1] = items2[1]
                items2 = [String]()
                print(items2)
            } else {
                imagedetailviewcontroller.items = items3
//                imagedetailviewcontroller.items[0] = items3[0]
//                imagedetailviewcontroller.items[1] = items3[1]
//                imagedetailviewcontroller.items[2] = items3[2]
                items3 = [String]()
            }
        }
    }
    
    func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    

    //更新
        func loadTimeline() {
            //guard文以降currentUserが使える
            guard let currentUser = NCMBUser.current() else {
                //ログインに戻る

                let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                UIApplication.shared.keyWindow?.rootViewController = rootViewController

                // ログイン状態の保持
                let ud = UserDefaults.standard
                ud.set(false, forKey: "isLogin")
                ud.synchronize()
                return
            }
            
            let query = NCMBQuery(className: "Post")
            // 降順
            query?.order(byDescending: "createDate")
            // 親(Post)子(user)の情報も含めて取得 投稿したユーザーの情報も同時取得
            query?.includeKey("user")
//            query?.includeKey("comment")
            query?.whereKey("share", equalTo: true)
            // フォロー中の人 + 自分の投稿だけ持ってくる
            query?.whereKey("user", containedIn: followings)
            // blockを除外
            query?.whereKey("block", notEqualTo: "block")
            // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
            query?.findObjectsInBackground({ (result, error) in
                if error != nil {
                    HUD.flash(.error, delay: 2)
                } else {
                    self.posts = [Post]()

                    for postObject in result as! [NCMBObject] {
                        // ユーザー情報をUserクラスにセット
                        let user = postObject.object(forKey: "user") as! NCMBUser
                        
                        // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
                            if user.object(forKey: "active") as? Bool != false {
                                self.users.append(user)
                                // 投稿したユーザーの情報をUserモデルにまとめる
                                let userModel = User(objectId: user.objectId, userName: user.userName)
                                userModel.labname = user.object(forKey: "labname") as? String
                                userModel.major = user.object(forKey: "major") as? String
                                userModel.introduction = user.object(forKey: "introduction") as? String
                                //userModel.displayName = user.object(forKey: "displayName") as? String

                                // 投稿の情報を取得
                                
                                let imageUrl1 = postObject.object(forKey: "imageUrl1") as! String
                                let imageUrl2 = postObject.object(forKey: "imageUrl2") as! String
                                let imageUrl3 = postObject.object(forKey: "imageUrl3") as! String
                                
                                
                                let title = postObject.object(forKey: "title") as! String
                                let howmanyimages = postObject.object(forKey: "howmanyimages") as! Int
                                let recorddate = postObject.object(forKey: "recorddate") as! String
                                let share = postObject.object(forKey: "share") as! Bool
                                let text = postObject.object(forKey: "text") as! String

                                //2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                                let post = Post(objectId: postObject.objectId, user: userModel, recorddate: recorddate, share: share, title: title, text: text, createDate: postObject.createDate, howmanyimages: howmanyimages, imageUrl1: imageUrl1, imageUrl2: imageUrl2, imageUrl3: imageUrl3)

                                // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                                let likeUsers = postObject.object(forKey: "likeUser") as? [String]
                                if likeUsers?.contains(NCMBUser.current().objectId) == true {
                                    post.isLiked = true
                                } else {
                                    post.isLiked = false
                                }

                                // いいねの件数
                                if let likes = likeUsers {
                                    post.likeCount = likes.count
                                }
                                
                                // 配列に加える
                                self.posts.append(post)
                            }
                        }

                    //self.posts = result as! [NCMBObject] //any型から他の型に変える
                    self.timelineTableView.reloadData()
                }
            })
        }
    
    
    //どのセルが押されたか、どのボタンが押されたか
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton) {
        //guard文以降currentUserが使える
//        guard let currentUser = NCMBUser.current() else {
//            //ログインに戻る
//
//            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
//            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
//            UIApplication.shared.keyWindow?.rootViewController = rootViewController
//
//            // ログイン状態の保持
//            let ud = UserDefaults.standard
//            ud.set(false, forKey: "isLogin")
//            ud.synchronize()
//            return
//        }
        //もしpostsの中身のisLikedがfalseまたはnilだったら
        if posts[tableViewCell.tag].isLiked == false || posts[tableViewCell.tag].isLiked == nil {
            let query = NCMBQuery(className: "Post")
            //自分というオブジェクトが必ず一つになるようにする。一つしか追加されない。
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                post?.addUniqueObject(NCMBUser.current().objectId, forKey: "likeUser")
                post?.saveEventually({ (error) in
                    if error != nil {
                        HUD.flash(.error, delay: 2)
                    } else {
                        self.loadTimeline()
                    }
                })
            })
        } else {
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    HUD.flash(.error, delay: 2)
                } else {
                    //あった場合は前のものを削除する
                    post?.removeObjects(in: [NCMBUser.current().objectId as Any], forKey: "likeUser")
                    post?.saveEventually({ (error) in
                        if error != nil {
                            HUD.flash(.error, delay: 2)
                        } else {
                            self.loadTimeline()
                        }
                    })
                }
            })
        }
    }

    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "削除する", style: .destructive) { (action) in
            HUD.show(.progress)
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: self.posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    HUD.flash(.error, delay: 2)
                } else {
                    // 取得した投稿オブジェクトを削除
                    post?.deleteInBackground({ (error) in
                        if error != nil {
                            HUD.flash(.error, delay: 2)
                        } else {
                            // 再読込
                            self.loadTimeline()
                            HUD.hide()
                        }
                    })
                }
            })
        }
        let reportAction = UIAlertAction(title: "報告する", style: .destructive) { (action) in
            HUD.flash(.labeledSuccess(title: "この投稿を報告しました", subtitle: "ご協力ありがとうございました"), onView: self.view, delay: 2)
            self.report(tableViewCell: tableViewCell)
        }
        let blockAction = UIAlertAction(title: "ブロック", style: .destructive) { (action) in
            HUD.flash(.labeledSuccess(title: "この投稿をブロックしました", subtitle: "今後は表示されません"), onView: self.view, delay: 3)
            self.block(tableViewCell: tableViewCell)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        if posts[tableViewCell.tag].user.objectId == NCMBUser.current().objectId {
            // 自分の投稿なので、削除ボタンを出す
            alertController.addAction(deleteAction)
        } else {
            // 他人の投稿なので、報告ボタンを出す
            alertController.addAction(reportAction)
            alertController.addAction(blockAction)
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

//    @IBAction func upload(_ sender: Any) {
//        performSegue(withIdentifier: "toPost", sender: nil)
//    }
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        timelineTableView.addSubview(refreshControl)
    }

    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        self.loadFollowingUsers()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }
    
    func loadFollowingUsers() {
        // フォロー中の人だけ持ってくる
        let query = NCMBQuery(className: "Follow")
        query?.includeKey("user")
        query?.includeKey("following")
        query?.whereKey("user", equalTo: NCMBUser.current())
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                HUD.flash(.error, delay: 2)
            } else {
                self.followings = [NCMBUser]()
                for following in result as! [NCMBObject] {
                    self.followings.append(following.object(forKey: "following") as! NCMBUser)
                }
                
                self.followings.append(NCMBUser.current())

                self.loadTimeline()
            }
        })
    }
    
    func report(tableViewCell: UITableViewCell){
        let object = NCMBObject(className: "Report")
        object?.setObject(self.posts[tableViewCell.tag].objectId, forKey: "postId")
        object?.setObject(NCMBUser.current(), forKey: "user")
        object?.saveInBackground({ (error) in
            if error != nil {
                HUD.flash(.error, delay: 2)
            } else {
                HUD.hide()
            }
        })
    }
    
    
    func block(tableViewCell: UITableViewCell){
        let query = NCMBQuery(className: "Post")
        query?.whereKey("objectId", equalTo: self.posts[tableViewCell.tag].objectId)
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                HUD.flash(.error, delay: 2)
            } else {
                let objectArray = result as! [NCMBObject]
                let object = objectArray.first
                object?.setObject("block", forKey: "block")
                // 取得した投稿オブジェクトを保存
                object?.saveInBackground({ (error) in
                    if error != nil {
                        HUD.flash(.error, delay: 2)
                    } else {
                        // 再読込
                        self.loadTimeline()
                        HUD.hide()
                    }
                })
            }
        })
    }
    
}


