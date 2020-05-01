//
//  ShowUserViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/18.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher
import PKHUD
import SwiftDate

//, UITableViewDataSource, UITableViewDelegate
class ShowUserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, userPostTableViewCellDelegate {
    
    var selectPost: Post?

        var selectedUser: NCMBUser!
        
        var followingInfo: NCMBObject?
        
        var posts = [Post]()
        
        var post: Post?
    
    var items1 = [String]()
    var items2 = [String]()
    var items3 = [String]()
        
        @IBOutlet var userImageView: UIImageView!
        
        @IBOutlet var userNameLabel: UILabel!
        
        @IBOutlet var userIntroductionTextView: UITextView!
        
        @IBOutlet var userpostTableView: UITableView!
        
        @IBOutlet var postCountLabel: UILabel!
        
        @IBOutlet var followerCountLabel: UILabel!
        
        @IBOutlet var followingCountLabel: UILabel!
        
        @IBOutlet var followButton: UIButton!
    
        @IBOutlet var backImageView: UIImageView!
    
        @IBOutlet var labnameLabel: UILabel!

        override func viewDidLoad() {
            super.viewDidLoad()
            
            backImageView.image = UIImage(named: "back.png")
            userImageView.backgroundColor = UIColor.white
            
            followButton.layer.borderColor = UIColor(red: 234/255, green: 136/255, blue: 89/255, alpha: 1.0).cgColor
            followButton.layer.borderWidth = 2
            followButton.layer.cornerRadius = followButton.bounds.width / 8.0
            followButton.layer.masksToBounds = true
            followButton.setTitleColor(UIColor(red: 234/255, green: 136/255, blue: 89/255, alpha: 1.0), for: .normal)

            userpostTableView.dataSource = self
            userpostTableView.delegate = self
            
            userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
            userImageView.layer.masksToBounds = true
            
            // TODO: CurrentUserがいないときにはサインイン画面に移動させる（他のVCのコードみてbyせのお）
            // ユーザー基礎情報の読み込み
            userNameLabel.text = selectedUser.object(forKey: "userName") as? String
            userIntroductionTextView.text = selectedUser.object(forKey: "introduction") as? String
            labnameLabel.text = selectedUser.object(forKey: "labname") as? String
            self.navigationItem.title = selectedUser.userName
            
            // プロフィール画像の読み込み
            let userfile = NCMBFile.file(withName: selectedUser.objectId + "user", data: nil) as! NCMBFile
            userfile.getDataInBackground { (data, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    if data != nil {
                        let userimage = UIImage(data: data!)
                        self.userImageView.image = userimage
                    }
                }
            }
            // 背景画像の読み込み
            let backfile = NCMBFile.file(withName: selectedUser.objectId + "back", data: nil) as! NCMBFile
            backfile.getDataInBackground { (data, error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    if data != nil {
                        let backimage = UIImage(data: data!)
                        self.backImageView.image = backimage
                    }
                }
            }
            
            
            //カスタムセルの登録
            let nib = UINib(nibName: "userPostTableViewCell", bundle: Bundle.main)
            userpostTableView.register(nib, forCellReuseIdentifier: "Cell")
            //TableViewの余計な線を消す
            userpostTableView.tableFooterView = UIView()
            // ユーザーの投稿した写真の読み込み
            loadPosts()
            
            // フォロー状態の読み込み
            loadFollowingStatus()
            
            // フォロー数の読み込み
            loadFollowingInfo()
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    
    override func viewWillAppear(_ animated: Bool) {
        // フォロー状態の読み込み
        loadFollowingStatus()
        
        // フォロー数の読み込み
        loadFollowingInfo()
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectPost = posts[indexPath.row]
        
        if selectPost?.howmanyimages == 1 {
            let imageUrl1 = selectPost?.imageUrl1
            self.items1.append(imageUrl1!)
        } else if selectPost?.howmanyimages == 2 {
            let imageUrl1 = selectPost?.imageUrl1
            let imageUrl2 = selectPost?.imageUrl2
            self.items2.append(imageUrl1!)
            self.items2.append(imageUrl2!)
        } else {
            let imageUrl1 = selectPost?.imageUrl1
            let imageUrl2 = selectPost?.imageUrl2
            let imageUrl3 = selectPost?.imageUrl3
            self.items3.append(imageUrl1!)
            self.items3.append(imageUrl2!)
            self.items3.append(imageUrl3!)
        }
        if selectPost?.howmanyimages == 0 {
            self.performSegue(withIdentifier: "toSearchPost", sender: nil)
        }else {
            self.performSegue(withIdentifier: "toSearchPost1", sender: nil)
        }
        //print(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! userPostTableViewCell
        //idをつけたcellの取得
        cell.delegate = self
        cell.tag = indexPath.row
        
        cell.doDateLabel.layer.cornerRadius = cell.doDateLabel.bounds.width / 30.0
        cell.doDateLabel.layer.masksToBounds = true

        cell.doDateLabel.text = posts[indexPath.row].recorddate
        cell.titleLabel.text = posts[indexPath.row].title
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

        return cell
    }

    //セルの高さを設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
     }
    
    func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    //遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            if segue.identifier == "toSearchPost" {
                let searchdetailViewController = segue.destination as! SearchDetailViewController
                let selectedIndex = userpostTableView.indexPathForSelectedRow!
                //prepare for segueが呼ばれた時の今選択されているセルを代入する
                searchdetailViewController.selectedPost = posts[selectedIndex.row]
        }
            
            if segue.identifier == "toSearchPost1" {
                let searchimagedetailviewcontroller = segue.destination as! SearchImageDetailViewController
                let selectedIndex = userpostTableView.indexPathForSelectedRow!
                //prepare for segueが呼ばれた時の今選択されているセルを代入する
                searchimagedetailviewcontroller.selectedPost = posts[selectedIndex.row]
                if posts[selectedIndex.row].howmanyimages == 1 {
                            searchimagedetailviewcontroller.items = items1
                            items1 = [String]()
                        } else if posts[selectedIndex.row].howmanyimages == 2 {
                            searchimagedetailviewcontroller.items = items2
                            items2 = [String]()
                        } else {
                            searchimagedetailviewcontroller.items = items3
                            items3 = [String]()
                        }
            }
    }
       
        
        func loadFollowingStatus() {
            let query = NCMBQuery(className: "Follow")
            query?.includeKey("user") //自分
            query?.includeKey("following") //フォローしたオブジェクトID
            query?.whereKey("user", equalTo: NCMBUser.current())
            
            query?.findObjectsInBackground({ (result, error) in
                
                guard error == nil else {
                    HUD.flash(.error, delay: 2)
                    return
                }
                guard let result = result else { return }
                for following in result as! [NCMBObject] {
                    let user = following.object(forKey: "following") as! NCMBUser
                    
                    // フォロー状態だった場合、ボタンの表示を変更
                    if self.selectedUser.objectId == user.objectId {
                        // 表示変更を高速化するためにメインスレッドで処理
                        DispatchQueue.main.async {
                            self.followButton.layer.cornerRadius = self.followButton.bounds.width / 8.0
                            self.followButton.layer.masksToBounds = true
                            self.followButton.setTitle("フォロー解除", for: .normal)
                            self.followButton.setTitleColor(UIColor.white, for: .normal)
                            self.followButton.backgroundColor = UIColor(red: 234/255, green: 136/255, blue: 89/255, alpha: 1.0)
                        }
                        // フォロー状態を管理するオブジェクトを保存
                        self.followingInfo = following
                        
                    } else {
                        
                    }
                }
                
            })
        }
    

        func loadPosts() {
            let query = NCMBQuery(className: "Post")
            query?.includeKey("user")
            query?.whereKey("user", equalTo: selectedUser)
            query?.findObjectsInBackground({ (result, error) in
                if error != nil {
                    HUD.flash(.error, delay: 2)
                } else {
                    self.posts = [Post]()
                    
                    for postObject in result as! [NCMBObject] {
                        // ユーザー情報をUserクラスにセット
                        let user = postObject.object(forKey: "user") as! NCMBUser
                        let userModel = User(objectId: user.objectId, userName: user.userName)
                        userModel.displayName = user.object(forKey: "displayName") as? String
                        
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
                    self.userpostTableView.reloadData()
                    
                    // post数を表示
                    self.postCountLabel.text = String(self.posts.count)
                }
            })
        }
        
        func loadFollowingInfo() {

            // フォロー中
            let followingQuery = NCMBQuery(className: "Follow")
            followingQuery?.includeKey("user")
            followingQuery?.whereKey("user", equalTo: selectedUser)
            followingQuery?.countObjectsInBackground({ (count, error) in
                if error != nil {
                    HUD.flash(.error, delay: 2)
                } else {
                    // 非同期通信後のUIの更新はメインスレッドで
                    DispatchQueue.main.async {
                        self.followingCountLabel.text = String(count)

                    }
                }
            })

            // フォロワー
            let followerQuery = NCMBQuery(className: "Follow")
            followerQuery?.includeKey("following")
            followerQuery?.whereKey("following", equalTo: selectedUser)
            followerQuery?.countObjectsInBackground({ (count, error) in
                if error != nil {
                    HUD.flash(.error, delay: 2)
                } else {
                    DispatchQueue.main.async {
                        // 非同期通信後のUIの更新はメインスレッドで
                        self.followerCountLabel.text = String(count)
                    }
                }
            })
        }

        @IBAction func follow() {
            // すでにフォロー状態だった場合、フォロー解除
            if let info = followingInfo {

                let userName = selectedUser.object(forKey: "userName") as? String

                let message = userName! + "のフォローを解除しますか？"
                let alert = UIAlertController(title: "フォロー解除", message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        info.deleteInBackground({ (error) in
                        if error != nil {
                            HUD.flash(.error, delay: 2)
                        } else {
                            DispatchQueue.main.async {
                                self.followButton.setTitle("フォローする", for: .normal)
                                self.followButton.setTitleColor(UIColor(red: 234/255, green: 136/255, blue: 89/255, alpha: 1.0), for: .normal)
                                self.followButton.backgroundColor = UIColor.white
                                self.followButton.layer.borderColor = UIColor(red: 234/255, green: 136/255, blue: 89/255, alpha: 1.0).cgColor
                                self.followButton.layer.borderWidth = 2
                                self.followingInfo = nil //これ大事
                            }

                            // フォロー状態の再読込
                            self.loadFollowingStatus()

                            // フォロー数の再読込
                            self.loadFollowingInfo()
                        }
                    })
                }
                let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            } else { //フォローしてない時
                let userName = selectedUser.object(forKey: "userName") as? String

                let message = userName! + "をフォローしますか？"
                let alert = UIAlertController(title: "フォロー", message: message, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    let object = NCMBObject(className: "Follow")
                    if let currentUser = NCMBUser.current() {
                        object?.setObject(currentUser, forKey: "user")
                        object?.setObject(self.selectedUser, forKey: "following")
                        object?.saveInBackground({ (error) in
                            if error != nil {
                                HUD.flash(.error, delay: 2)
                            } else {
                                self.loadFollowingStatus()
                            }
                        })
                    } else {
                        // currentUserが空(nil)だったらログイン画面へ
                        let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                        let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                        UIApplication.shared.keyWindow?.rootViewController = rootViewController

                        // ログイン状態の保持
                        let ud = UserDefaults.standard
                        ud.set(false, forKey: "isLogin")
                        ud.synchronize()
                    }
                }
                let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }

        
        func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {
            // 選ばれた投稿を一時的に格納
            post = posts[tableViewCell.tag]
            
    //        // 遷移させる(このとき、prepareForSegue関数で値を渡す)
    //        self.performSegue(withIdentifier: "toComments", sender: nil)
    //
            //登録成功 storyboardの呼び出し
            let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "CommentViewController")
            //奥底のコードwindowの取得
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
        }
        
    @IBAction func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //ログアウト
    @IBAction func showMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let reportAction = UIAlertAction(title: "報告する", style: .destructive) { (action) in
            HUD.flash(.labeledSuccess(title: "このユーザーを報告しました", subtitle: "ご協力ありがとうございました"), onView: self.view, delay: 2)
            self.reportUser()
        }
//        let blockAction = UIAlertAction(title: "ブロック", style: .destructive) { (action) in
//            HUD.flash(.labeledSuccess(title: "この投稿をブロックしました", subtitle: "今後は表示されません"), onView: self.view, delay: 3)
//            self.blockUser()
//        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(reportAction)
//        alertController.addAction(blockAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func reportUser(){
        let object = NCMBObject(className: "ReportUser")
        object?.setObject(selectedUser.objectId, forKey: "postId")
//        object?.setObject(NCMBUser.current(), forKey: "user")
        object?.saveInBackground({ (error) in
            if error != nil {
                HUD.flash(.error, delay: 2)
            } else {
                HUD.hide()
            }
        })
    }
    
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton) {
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
                        self.loadPosts()
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
                            self.loadPosts()
                        }
                    })
                }
            })
        }
    }
    
    
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
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
        // 他人の投稿なので、報告ボタンを出す
        alertController.addAction(reportAction)
        alertController.addAction(blockAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
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
                        self.loadPosts()
                        HUD.hide()
                    }
                })
            }
        })
    }
    
//
//    func blockUser(){
//        let query = NCMBQuery(className: "Post")
//        query?.whereKey("objectId", equalTo: self.posts[tableViewCell.tag].objectId)
//        query?.findObjectsInBackground({ (result, error) in
//            if error != nil {
//                HUD.flash(.error, delay: 2)
//            } else {
//                let objectArray = result as! [NCMBObject]
//                let object = objectArray.first
//                object?.setObject("block", forKey: "block")
//                // 取得した投稿オブジェクトを保存
//                object?.saveInBackground({ (error) in
//                    if error != nil {
//                        HUD.flash(.error, delay: 2)
//                    } else {
//                        // 再読込
//                        self.loadTimeline()
//                        HUD.hide()
//                    }
//                })
//            }
//        })
//    }

    }


