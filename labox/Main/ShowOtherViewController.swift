//
//  ShowOtherViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/22.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher
import PKHUD
import SwiftDate

//, UITableViewDataSource, UITableViewDelegate
class ShowOtherViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

        var selectedPost: Post?
    
        var selectedUser: NCMBUser?
    
    var selectPost: Post?
    
        var users = [NCMBUser]()
        
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
            
            userpostTableView.dataSource = self
            userpostTableView.delegate = self
            
            userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
            userImageView.layer.masksToBounds = true
            
            // TODO: CurrentUserがいないときにはサインイン画面に移動させる（他のVCのコードみてbyせのお）
            // ユーザー基礎情報の読み込み
            userNameLabel.text = selectedPost?.user.userName
            userIntroductionTextView.text = selectedPost?.user.introduction
            labnameLabel.text = selectedPost?.user.labname
            self.navigationItem.title = selectedPost?.user.userName
            
            // プロフィール画像の読み込み
            let user = selectedPost?.user
            let userfile = NCMBFile.file(withName: user!.objectId + "user", data: nil) as! NCMBFile
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
            let backfile = NCMBFile.file(withName: user!.objectId + "back", data: nil) as! NCMBFile
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
            
            // フォロー数の読み込み
            loadFollowingInfo()
            
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // フォロー数の読み込み
        loadFollowingInfo()
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! userPostTableViewCell
        //idをつけたcellの取得
//        cell.delegate = self
        cell.tag = indexPath.row

        cell.doDateLabel.text = posts[indexPath.row].recorddate
        //DateLabelを丸くする
        cell.doDateLabel.layer.cornerRadius = cell.doDateLabel.bounds.width / 20.0
        cell.doDateLabel.clipsToBounds = true
        
        cell.titleLabel.text = posts[indexPath.row].title
        let date = stringFromDate(date: posts[indexPath.row].createDate, format: "yyyy年MM月dd日 HH時mm分ss秒 ")
        cell.dateLabel.text = date

        return cell
    }

    //セルの高さを設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print(indexPath.row)
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
            self.performSegue(withIdentifier: "toUserPost", sender: nil)
        }else {
            self.performSegue(withIdentifier: "toUserPost1", sender: nil)
        }
        //選択状態解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    //遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
            if segue.identifier == "toUserPost" {
                let userdetailViewController = segue.destination as! UserDetailViewController
                let selectedIndex = userpostTableView.indexPathForSelectedRow!
                //prepare for segueが呼ばれた時の今選択されているセルを代入する
                userdetailViewController.selectedPost = posts[selectedIndex.row]
        }
            
            if segue.identifier == "toUserPost1" {
                let userimagedetailviewcontroller = segue.destination as! UserImageDetailViewController
                let selectedIndex = userpostTableView.indexPathForSelectedRow!
                //prepare for segueが呼ばれた時の今選択されているセルを代入する
                userimagedetailviewcontroller.selectedPost = posts[selectedIndex.row]
                if posts[selectedIndex.row].howmanyimages == 1 {
                            userimagedetailviewcontroller.items = items1
                            items1 = [String]()
                        } else if posts[selectedIndex.row].howmanyimages == 2 {
                            userimagedetailviewcontroller.items = items2
                            items2 = [String]()
                        } else {
                            userimagedetailviewcontroller.items = items3
                            items3 = [String]()
                        }
            }
    }
    

       
    

        func loadPosts() {
            let query = NCMBQuery(className: "Post")
            query?.includeKey("user")
            query?.whereKey("user", equalTo: selectedUser)
            query?.whereKey("share", equalTo: true)
            query?.findObjectsInBackground({ (result, error) in
                if error != nil {
                    HUD.flash(.error, delay: 2)
                } else {
                    self.posts = [Post]()
                    
                    for postObject in result as! [NCMBObject] {
                        // ユーザー情報をUserクラスにセット
                        let user = postObject.object(forKey: "user") as! NCMBUser
                        let userModel = User(objectId: user.objectId, userName: user.userName)
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
                        let likeUser = postObject.object(forKey: "likeUser") as? [String]
                        if likeUser?.contains(NCMBUser.current().objectId) == true {
                            post.isLiked = true
                        } else {
                            post.isLiked = false
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
        let alertController = UIAlertController(title: "メニュー", message: "メニューを選択して下さい。", preferredStyle: .actionSheet)
        
        let signOutAction = UIAlertAction(title: "ログアウト", style: .default) { (action) in
            NCMBUser.logOutInBackground({ (error) in
                if error != nil {
                    HUD.flash(.error, delay: 2)
                } else {
                    // ログアウト成功
                    let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    
                    // ログイン状態の保持
                    let ud = UserDefaults.standard
                    ud.set(false, forKey: "isLogin")
                    ud.synchronize()
                }
            })
        }
        
        let deleteAction = UIAlertAction(title: "退会", style: .default) { (action) in
            alertController.dismiss(animated: true, completion: nil)
            let user = NCMBUser.current()
            user?.deleteInBackground({ (error) in
                if error != nil {
                    print(error)
                } else {
                    // ログアウト成功
                    let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    
                    // ログイン状態の保持
                    let ud = UserDefaults.standard
                    ud.set(false, forKey: "isLogin")
                    ud.synchronize()
                }
            })
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(signOutAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
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

    }
