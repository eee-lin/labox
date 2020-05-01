//
//  UserPageViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/21.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit
import NCMB
import PKHUD

class UserPageViewController: UIViewController,UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MyPostTableViewCellDelegate {
    
    
    var selectedPost: Post?
    var posts = [Post]()
    
    let placeholderImage = UIImage(named: "photo-placeholder")
    var resizedImage: UIImage!
    var items1 = [String]()
    var items2 = [String]()
    var items3 = [String]()
//    var postArray = [NCMBObject]()
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var backImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var introduceTextView: UITextView!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var postCountLabel: UILabel!
    
    @IBOutlet var postTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //画像を丸くする
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true

        
        backImageView.image = UIImage(named: "back.png")
        userImageView.backgroundColor = UIColor.white
        userImageView.image = UIImage(named: "丸底フラスコのフリーアイコン3.png")
        //editbutton
        //変更ボタンを丸くする
        editButton.layer.cornerRadius = editButton.bounds.width / 5.0
        editButton.layer.borderColor = UIColor(red: 234/255, green: 136/255, blue: 89/255, alpha: 1.0).cgColor
        editButton.layer.borderWidth = 2
        editButton.layer.masksToBounds = true
        editButton.setTitleColor(UIColor.white, for: .normal)
        editButton.backgroundColor = UIColor(red: 234/255, green: 136/255, blue: 89/255, alpha: 1.0)
        
        postTableView.delegate = self
        postTableView.dataSource = self
        //TableViewの不要な線を消す
        postTableView.tableFooterView = UIView()
        //1行目でxibファイルの取得
        let nib = UINib(nibName: "MypostTableViewCell", bundle: Bundle.main)
        //2行目で取得したファイルをtimelineTableViewに登録
        postTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        nameLabel.text = NCMBUser.current().object(forKey: "userName") as? String
        
        // 引っ張って更新
        setRefreshControl()
        
        loadPosts()
        loadImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadPosts()
        loadImage()
    }
    
    func loadImage() {
        //ユーザー情報の取得
                if let user = NCMBUser.current() {
                    nameLabel.text = user.userName
                    introduceTextView.text = user.object(forKey: "introduction") as? String
                    self.navigationItem.title = user.userName
        //            let userId = NCMBUser.current().userName
                    //画像を取得
                    let userfile = NCMBFile.file(withName: user.objectId + "user", data: nil) as! NCMBFile
                    userfile.getDataInBackground { (data, error) in
                        if error != nil {
                            self.userImageView.image = UIImage(named: "丸底フラスコのフリーアイコン3.png")
//                            let alert = UIAlertController(title: "画像取得エラー", message: error!.localizedDescription, preferredStyle: .alert)
//                            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
//
//                            })
//                            alert.addAction(okAction)
//                            self.present(alert, animated: true, completion: nil)
                        } else {
                            if data != nil {
                                //dataの中身があれば画像を表示
                                let userimage = UIImage(data: data!)
                                self.userImageView.image = userimage
                            }
                        }
                    }
                    let backfile = NCMBFile.file(withName: user.objectId + "back", data: nil) as! NCMBFile
                    backfile.getDataInBackground { (data, error) in
                        if error != nil {
                            self.backImageView.image = UIImage(named: "back.png")
                        } else {
                            if data != nil {
                                //dataの中身があれば画像を表示
                                let backimage = UIImage(data: data!)
                                self.backImageView.image = backimage
                            }
                        }
                    }
                } else {
                    // NCMBUser.current()がnilだったとき
                    let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController

                    // ログイン状態の保持
                    let ud = UserDefaults.standard
                    ud.set(false, forKey: "isLogin")
                    ud.synchronize()
                }
    }
    
    @IBAction func toEdit(){
        performSegue(withIdentifier: "toEdit", sender: nil)
        
        //editbutton
        //変更ボタンを丸くする
        editButton.layer.cornerRadius = editButton.bounds.width / 5.0
        editButton.layer.borderColor = UIColor(red: 234/255, green: 136/255, blue: 89/255, alpha: 1.0).cgColor
        editButton.layer.borderWidth = 2
        editButton.layer.masksToBounds = true
        editButton.setTitleColor(UIColor(red: 234/255, green: 136/255, blue: 89/255, alpha: 1.0), for: .normal)
        editButton.backgroundColor = UIColor.white
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
            let alertController = UIAlertController(title: "退会", message: "退会しますか？", preferredStyle: .actionSheet)
            let checkAction = UIAlertAction(title: "退会", style: .default) { (action) in
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
            alertController.addAction(checkAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(signOutAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }

    //1. TableViewに関するデータの個数の表示
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            //配列内の個数より多くならないように数を設定する
            return posts.count
        }
        
        //2. TableViewに表示するデータの内容
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            //idをつけたcellの取得
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MypostTableViewCell
            
            cell.delegate = self
            cell.tag = indexPath.row
            
    //        cell.profileImageView.image = posts[indexPath.row].object(forKey: "")
            cell.titleLabel.text = posts[indexPath.row].title
            cell.doDateLabel.text = posts[indexPath.row].recorddate
            
            //DateLabelを丸くする
            cell.doDateLabel.layer.cornerRadius = cell.doDateLabel.bounds.width / 20.0
            cell.doDateLabel.clipsToBounds = true
            
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
            return cell
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 80
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
                self.performSegue(withIdentifier: "toMypost", sender: nil)
            }else {
                self.performSegue(withIdentifier: "toMypost1", sender: nil)
                
            }
            
            //選択状態解除
            postTableView.deselectRow(at: indexPath, animated: true)
        }
    
    func stringFromDate(date: Date, format: String) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toMypost" {
            let mydetailViewController = segue.destination as! MyDetailViewController
            let selectedIndex = postTableView.indexPathForSelectedRow!
            //prepare for segueが呼ばれた時の今選択されているセルを代入する
            mydetailViewController.selectedPost = posts[selectedIndex.row]
        }
        
        if segue.identifier == "toMypost1" {
            let myimagedetailViewController = segue.destination as! MyImageDetailViewController
            let selectedIndex = postTableView.indexPathForSelectedRow!
            //prepare for segueが呼ばれた時の今選択されているセルを代入する
            myimagedetailViewController.selectedPost = posts[selectedIndex.row]
            if posts[selectedIndex.row].howmanyimages == 1 {
            //                imagedetailviewcontroller.items[0] = items1[0]
                        myimagedetailViewController.items = items1
                        items1 = [String]()
                    } else if posts[selectedIndex.row].howmanyimages == 2 {
                        myimagedetailViewController.items = items2
            //                imagedetailviewcontroller.items[0] = items2[0]
            //                imagedetailviewcontroller.items[1] = items2[1]
                        items2 = [String]()                    
                    } else {
                        myimagedetailViewController.items = items3
            //                imagedetailviewcontroller.items[0] = items3[0]
            //                imagedetailviewcontroller.items[1] = items3[1]
            //                imagedetailviewcontroller.items[2] = items3[2]
                        items3 = [String]()
                    }
        }
    }
    

    //更新
    func loadPosts() {
        let query = NCMBQuery(className: "Post")
        // 親(Post)子(user)の情報も含めて取得
        query?.includeKey("user")
        //userがNCMBUser.current()に一致するオブジェクトを取得
        query?.whereKey("user", equalTo: NCMBUser.current())
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
//                self.posts = result as! [NCMBObject] //any型から他の型に変える
                self.postTableView.reloadData()

                // post数を表示
                //self.postCountLabel.text = String(self.posts.count)
            }
        })
    }
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        postTableView.addSubview(refreshControl)
    }

    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        self.loadPosts()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
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
                            self.loadPosts()
                            HUD.hide()
                        }
                    })
                }
            })
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        // 自分の投稿なので、削除ボタンを出す
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
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
}
