//
//  SearchViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/18.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit
import NCMB
import PKHUD

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SearchUserTableViewCellDelegate{
    
    var users = [NCMBUser]()
    var posts = [Post]()
    var post: Post?
    
    var searchBar: UISearchBar!
    var followingUserIds = [String]()

    // テーブルビュー
    @IBOutlet weak var searchTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let queue = DispatchQueue.global(qos: .default)
        print("----- \(queue.label) start -----")
            queue.async {
                self.loadothers()
                
        }
        print("----- \(queue.label) end -----")
//        DispatchQueue.main.async{
//            self.loadothers()
//        }
        
        
        guard NCMBUser.current() != nil else {
            //Todo：アラート書く
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            // ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
            return
        }
        
        DispatchQueue.main.async{
            self.setSearchBar()
        }
        
        // 引っ張って更新
        setRefreshControl()
        
//        loadothers()
        
        //カスタムセルの登録
        //1行目でxibファイルの取得
        let nib = UINib(nibName: "SearchTableViewCell", bundle: Bundle.main)
        //2行目で取得したファイルをtimelineTableViewに登録
        searchTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        //デリゲートの設定
        searchTableView.delegate = self
        searchTableView.dataSource = self
        
        // 余計な線を消す
        searchTableView.tableFooterView = UIView()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUsers(searchText: nil)
    }
    
    func setSearchBar() {
        // NavigationBarにSearchBarをセット
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "ユーザーを検索"
            searchBar.autocapitalizationType = UITextAutocapitalizationType.none
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        loadUsers(searchText: nil)
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        loadUsers(searchText: searchBar.text)
    }
    
    // 画面遷移処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 検索画面に値を渡す。
        if segue.identifier == "toUser" {
            let showUserViewController = segue.destination as! ShowUserViewController
            let selectedIndex = searchTableView.indexPathForSelectedRow!
            showUserViewController.selectedUser = users[selectedIndex.row]
            showUserViewController.post = post
        }
    }
    
    // テーブルビューのデリゲードメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // テーブルビューのセル数の設定する。
        return users.count
    }
    
    //セルの高さを設定
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 60
     }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //idをつけたcellの取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SearchTableViewCell
//        //忘れない
//        cell.delegate = self
//        cell.tag = indexPath.row
        // プロフィール画像の読み込み
        let user = posts[indexPath.row].user
        print(user)
        //画像を取得
        let file = NCMBFile.file(withName: user.objectId + "user", data: nil) as! NCMBFile
        file.getDataInBackground { (data, error) in
            if error != nil {
                HUD.flash(.labeledError(title: "画像取得エラー", subtitle: "通信状況を確認してください"), delay: 1)
            } else {
                if data != nil {
                    //dataの中身があれば画像を表示
                    let image = UIImage(data: data!)
                    cell.userImageView.image = image
                }
            }
        }
        cell.followButton.layer.cornerRadius = cell.followButton.bounds.width / 20.0
        cell.followButton.backgroundColor = UIColor.white
        cell.followButton.layer.borderColor = UIColor(red: 234/255, green: 136/255, blue: 89/255, alpha: 1.0).cgColor
        cell.followButton.layer.borderWidth = 1
        
        
        cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
        cell.userImageView.layer.masksToBounds = true
        
        cell.userNameLabel.text = users[indexPath.row].object(forKey: "displayName") as? String
        
        // Followボタンを機能させる
        cell.tag = indexPath.row
        cell.delegate = self
        
        if followingUserIds.contains(users[indexPath.row].objectId) == true {
            cell.followButton.isHidden = true
        } else {
            cell.followButton.isHidden = false
        }

        return cell
    }
    
//    func showfollowButton() {
//        let query = NCMBQuery(className: "Follow")
//        query?.includeKey("user")
//        query?.includeKey("following")
//        query?.whereKey("user", equalTo: NCMBUser.current())
//        query?.findObjectsInBackground({ (result, error) in
//            if error != nil {
//                SVProgressHUD.showError(withStatus: error!.localizedDescription)
//            } else {
//                let follow = result as! [NCMBObject]
//                follow.first?.deleteInBackground({ (error) in
//                    if error != nil {
//                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
//                    } else {
//                        print("delete succeed")
//                    }
//                })
//                }
//        })
//    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toUser", sender: nil)
        // 選択状態の解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func didTapFollowButton(tableViewCell: UITableViewCell, button: UIButton) {
        
        //let userName = users[tableViewCell.tag].object(forKey: "userName") as? String
        let displayName = users[tableViewCell.tag].object(forKey: "displayName") as? String
        let message = displayName! + "をフォローしますか？"

        let alert = UIAlertController(title: "フォロー", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.follow(selectedUser: self.users[tableViewCell.tag])
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    //選択したユーザーの情報をデータベースに保存する
    func follow(selectedUser: NCMBUser) {
        let object = NCMBObject(className: "Follow")
        if let currentUser = NCMBUser.current() {
            object?.setObject(currentUser, forKey: "user")
            object?.setObject(selectedUser, forKey: "following")
            object?.saveInBackground({ (error) in
                if error != nil {
                    HUD.flash(.error, delay: 2)
                } else {
                    self.loadUsers(searchText: nil)
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
    
    func loadUsers(searchText: String?) {
        let query = NCMBUser.query()
        // 自分を除外
        query?.whereKey("objectId", notEqualTo: NCMBUser.current().objectId)
        
        // 退会済みアカウントを除外
        query?.whereKey("active", notEqualTo: false)
        
        // 検索ワードがある場合
        if let text = searchText {
            query?.whereKey("displayName", equalTo: text)
        }
        
        // 新着ユーザー50人だけ拾う
        query?.limit = 50
        query?.order(byDescending: "createDate")
        
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                HUD.flash(.error, delay: 2)
            } else {
                // 取得した新着50件のユーザーを格納
                self.users = result as! [NCMBUser]
                print(self.users.count)
                print("どすこい")
                self.loadFollowingUserIds()
                //self.searchTableView.reloadData()
            }
        })
    }
    
    //データベースのFollowから自分がフォローしたオブジェクトIDをfollowingUserIdsに格納
    func loadFollowingUserIds() {
        let query = NCMBQuery(className: "Follow")
        query?.includeKey("user")
        query?.includeKey("following")
        query?.whereKey("user", equalTo: NCMBUser.current())
        
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                HUD.flash(.error, delay: 2)
            } else {
                self.followingUserIds = [String]()
                for following in result as! [NCMBObject] {
                    let user = following.object(forKey: "following") as! NCMBUser
                    self.followingUserIds.append(user.objectId)
                }
                
                self.searchTableView.reloadData()
            }
        })
    }
    
    //更新
    func loadothers() {
        //guard文以降currentUserが使える
        guard NCMBUser.current() != nil else {
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
                // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
            query?.findObjectsInBackground({ (result, error) in
                if error != nil {
                    HUD.flash(.error, delay: 2)
                } else {
                    self.posts = [Post]()

                    for postObject in result as! [NCMBObject] {
                            // ユーザー情報をUserクラスにセット
                        let user = postObject.object(forKey: "user") as! NCMBUser
                            //退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
                            if user.object(forKey: "active") as? Bool != false {
                                    // 投稿したユーザーの情報をUserモデルにまとめる
                                let userModel = User(objectId: user.objectId, userName: user.userName, displayName: user.object(forKey: "displayName") as! String)
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
                                if likeUsers?.contains(NCMBUser.current().objectId) == true
                                {
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
                                print("iiiiiiiiiiiiii")
                                print(self.post as Any)
                            }
                        print("aaaaaaaaaaaaaaa")
                        }
                        //self.posts = result as! [NCMBObject] //any型から他の型に変える
                    self.searchTableView.reloadData()
                    print("aaaaaaaaaaaaaaa")
                    print(self.posts.count)
                }
            })
        }
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        searchTableView.addSubview(refreshControl)
    }

    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        self.loadUsers(searchText: nil)
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
        refreshControl.endRefreshing()
        }
    }
    
}

