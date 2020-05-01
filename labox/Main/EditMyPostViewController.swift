//
//  EditMyPostViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/23.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit
import NYXImagesKit
import NCMB
import UITextView_Placeholder
import PKHUD
import DKImagePickerController
import Kingfisher

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func hideKeyboard() {
        view.endEditing(true)
    }
}


class EditMyPostViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    
    var selectedPost: Post?
    
        var selectedImage = [UIImage]()
        var checkImageView: Bool = false
        var userImages: [UIImage] = []
        var resizedImage: UIImage!
        var n = 0
        var isfirst = true
        var imageUrl = ""
        var userDate = ""
        var userTitle = ""
        var userText = ""
        var userSwitch = ""
        var items = [String]()
//    var countViewWill: Int = 0
        var isSecondCV = false
    
    //UIDatePickerを定義するための変数
    var datePicker: UIDatePicker = UIDatePicker()
        
        // 1行あたりのアイテム数
        private let itemsPerRow: CGFloat = 3
        // レイアウト設定　UIEdgeInsets については下記の参考図を参照。
        private let sectionInsets = UIEdgeInsets(top: 10.0, left: 2.0, bottom: 2.0, right: 2.0)

    //    @IBOutlet var postImageView: UIImageView!
        @IBOutlet var titleTextField: UITextField!
        @IBOutlet var postTextView: UITextView!
        @IBOutlet var dateTextField: UITextField!
        @IBOutlet var postButton: UIBarButtonItem!
        @IBOutlet var switchLabel: UILabel!
        @IBOutlet var shareSwitch: UISwitch!
        @IBOutlet var addImageButton: UIButton!
    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var firstCollectionView: UICollectionView!
//        @IBOutlet var wordCountLabel:UILabel!
        // collection viewのoutlet
        @IBOutlet var photoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // ナビゲーションバーのアイテムの色　（戻る　＜　とか　読み込みゲージとか）
        navigationBar.tintColor = UIColor.white
        
        // ツールバー生成 サイズはsizeToFitメソッドで自動で調整される。
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

        //サイズの自動調整。敢えて手動で実装したい場合はCGRectに記述してsizeToFitは呼び出さない。
        toolBar.sizeToFit()

        // 左側のBarButtonItemはflexibleSpace。これがないと右に寄らない。
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        // Doneボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(commitButtonTapped))

        // BarButtonItemの配置
        toolBar.items = [spacer, commitButton]
        // textViewのキーボードにツールバーを設定
        postTextView.inputAccessoryView = toolBar
        
        //datepicker
            // ピッカー設定
            datePicker.datePickerMode = UIDatePicker.Mode.date
            datePicker.timeZone = NSTimeZone.local
            datePicker.locale = Locale.current
            dateTextField.inputView = datePicker

            // 決定バーの生成
            let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
            let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
            let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
            toolbar.setItems([spacelItem, doneItem], animated: true)

            // インプットビュー設定(紐づいているUITextfieldへ代入)
            dateTextField.inputView = datePicker
            dateTextField.inputAccessoryView = toolbar
        
        
        
        //postImageView.image = placeholderImage
        postTextView.becomeFirstResponder()  //謎
        
        postTextView.delegate = self
        
        dateTextField.delegate = self
        titleTextField.delegate = self
        
        //collectionViewの関連付け
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        
        firstCollectionView.delegate = self
        firstCollectionView.dataSource = self

        //動くかどうか確認必要
        // 枠のカラー
        postTextView.layer.borderColor = UIColor(red: 53/255, green: 72/255, blue: 79/255, alpha: 1.0).cgColor

//        postTextView.frame = CGRect(x : 100, y : 100, width : 100, height : 100)
        
        // 枠の幅
        postTextView.layer.borderWidth = 1.0
        
        // 枠を角丸にする
        postTextView.layer.cornerRadius = postTextView.bounds.width / 30.0
        postTextView.layer.masksToBounds = true
        
        addImageButton.layer.cornerRadius = addImageButton.bounds.width / 30.0
        addImageButton.layer.masksToBounds = true
        
        if userDate == "" {
            dateTextField.placeholder = "2020/04/18"
            dateTextField.text = selectedPost?.recorddate
        } else {
            // データの呼び出し
            let ud = UserDefaults.standard
            userDate = ud.object(forKey: "userDate") as! String
            dateTextField.text  = userDate
        }
        
        if userTitle == "" {
            
            titleTextField.placeholder = "タイトル、概要"
            titleTextField.text = selectedPost?.title
        } else {
            // データの呼び出し
            let ud = UserDefaults.standard
            userTitle = ud.object(forKey: "userTitle") as! String
            titleTextField.text  = userTitle
        }
        
        if userText == "" {
            postTextView.placeholder = "気づいたことを書いてみよう"
            postTextView.text = selectedPost?.text
            
        } else {
            // データの呼び出し
            let ud = UserDefaults.standard
            userText = ud.object(forKey: "userText") as! String
            postTextView.text  = userText
        }
        
        if userSwitch == "" {
            if selectedPost?.share == true {
                shareSwitch.isOn = true
                switchLabel.text = "共有する"
            } else {
                shareSwitch.isOn = false
                 switchLabel.text = "共有しない"
            }
        } else {
            // データの呼び出し
            let ud = UserDefaults.standard
            userSwitch = ud.object(forKey: "userSwitch") as! String
            if userSwitch == "true" {
                shareSwitch.isOn = true
                switchLabel.text = "共有する"
            } else {
                shareSwitch.isOn = false
                switchLabel.text = "共有しない"
            }
        }
        
        // UITextField をファーストレスポンダにする（その結果、キーボードが表示される）
        dateTextField.becomeFirstResponder()
        
        confirmContent()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func commitButtonTapped() {
        self.view.endEditing(true)
    }
    
    // UIDatePickerのDoneを押したら発火
    @objc func done() {
        dateTextField.endEditing(true)

        // 日付のフォーマット
        let formatter = DateFormatter()

        //"yyyy年MM月dd日"を"yyyy/MM/dd"したりして出力の仕方を好きに変更できるよ
        formatter.dateFormat = "yyyy年MM月dd日"

        //(from: datePicker.date))を指定してあげることで
        //datePickerで指定した日付が表示される
        dateTextField.text = "\(formatter.string(from: datePicker.date))"
        
        let nextTag = dateTextField.tag + 1
        if let nextTextField = self.view.viewWithTag(nextTag) {
            nextTextField.becomeFirstResponder()
        }
    }
    

    override func viewWillAppear(_ animated: Bool) {
            photoCollectionView.dataSource = self
            photoCollectionView.delegate = self
        
        firstCollectionView.delegate = self
        firstCollectionView.dataSource = self
        confirmContent()
        }
        
//        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//            // 入力を反映させたテキストを取得する
//            let resultText: String = (postTextView.text! as NSString).replacingCharacters(in: range, with: text)
//            if resultText.count <= 140 {
//            self.wordCountLabel.text = "あと(" + String(140 - resultText.count) + "文字)"
//                return true
//            }
//            return false
//        }
        
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
          confirmContent()
          return true
        }
    
    func textViewDidChange(_ textView: UITextView) {
        confirmContent()
    }
    
//    // セルが選択されたときの処理
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("tapされたよ")
//    }
        
        //セルの配置について決める
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            let horizontalSpace : CGFloat = 20
            let cellSize : CGFloat = self.view.bounds.width / 3 - horizontalSpace
            return CGSize(width: cellSize, height: cellSize)
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
            
            if isSecondCV != true {
                // "Cell" はストーリーボードで設定したセルのID
                            let cell =
                                firstCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                                   for: indexPath)
                            
                            // Tag番号を使ってImageViewのインスタンス生成
                            let postimageView = cell.contentView.viewWithTag(1) as! UIImageView
                            let imageUrl = items[indexPath.row]
                            
                            postimageView.kf.setImage(with: URL(string: imageUrl))
                            // 画像配列の番号で指定された要素の名前の画像をUIImageとする
                            
                            return cell
            } else {
                // "Cell" はストーリーボードで設定したセルのID
                            let cell =
                                photoCollectionView.dequeueReusableCell(withReuseIdentifier: "Cell",
                                                                   for: indexPath)
                            
                            // Tag番号を使ってImageViewのインスタンス生成
                            let postimageView = cell.contentView.viewWithTag(1) as! UIImageView

                            // 画像配列の番号で指定された要素の名前の画像をUIImageとする
                            // UIImageをUIImageViewのimageとして設定
                            postimageView.image = selectedImage[indexPath.row]
                            
                            return cell
            }
            
        }
        
    //    func numberOfSections(in collectionView: UICollectionView) -> Int {
    //        // section数は１つ
    //        return 1
    //    }
        
        //何枚セルを入れるか
        func collectionView(_ collectionView: UICollectionView,
                            numberOfItemsInSection section: Int) -> Int {
            // 要素数を入れる、要素以上の数字を入れると表示でエラーとなる
            if isSecondCV == false {
                return items.count
            } else {
                return selectedImage.count
            }
        }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        confirmContent()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        confirmContent()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        confirmContent()
    }
        
        //キーボードの完了が押されたときに呼ばれるデリケードメソッド
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//            userDate = dateTextField.text!
//            userTitle = titleTextField.text!
//            userText = postTextView.text!
            //キーボードを閉じる
            titleTextField.resignFirstResponder()
            // 次のTag番号を持っているテキストボックスがあれば、フォーカスする
            let nextTag = titleTextField.tag + 1
            if let nextTextView = self.view.viewWithTag(nextTag) {
                OperationQueue.main.addOperation({
                nextTextView.becomeFirstResponder()
                });
            }
            confirmContent()
            
            return true
        }
    
    
        func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
            postTextView.resignFirstResponder()
//            confirmContent()
            return true
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
//            confirmContent()
            postTextView.resignFirstResponder()
        }
    
//        override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//            if (self.titleTextField.isFirstResponder) {
//                self.titleTextField.resignFirstResponder()
//            }
//        }
    

        //画像を取り出す
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
//
//            resizedImage = selectedImage.scale(byFactor: 0.3)
//
//            postImageView.image = resizedImage
//            //pickerを閉じるコード
//            picker.dismiss(animated: true, completion: nil)
//
//            checkImageView = true
//
//            confirmContent()
//        }
    
    @IBAction func tapped(_ sender: UISwitch) {
        if sender.isOn {
            //on
            self.switchLabel.text = "共有する"
        } else {
            self.switchLabel.text = "共有しない"
        }
    }


        @IBAction func selectImage() {
            selectedImage = []
            
            isSecondCV = true
            
            userDate = dateTextField.text!
            userTitle = titleTextField.text!
            userText = postTextView.text!
            
            if shareSwitch.isOn == true {
                userSwitch = "true"
            } else {
                userSwitch = "false"
            }
            
            // データの保持
            let ud = UserDefaults.standard
            ud.set(userDate, forKey: "userDate")
            ud.set(userTitle, forKey: "userTitle")
            ud.set(userText, forKey: "userText")
            ud.set(userSwitch,forKey: "userSwitch")
            
            let alertController = UIAlertController(title: "画像選択", message: "画像を選択して下さい。", preferredStyle: .actionSheet)

            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                alertController.dismiss(animated: true, completion: nil)
            }

            let cameraAction = UIAlertAction(title: "カメラで撮影", style: .default) { (action) in
                // カメラ起動
                if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                    //DKImagePickerControllerのインスタンスを生成
                    let picker = UIImagePickerController()
                    picker.sourceType = .camera
                    picker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
                    self.present(picker, animated: true, completion: nil)
                } else {
                    print("この機種ではカメラが使用出来ません。")
                }
            }

            let photoLibraryAction = UIAlertAction(title: "フォトライブラリから選択", style: .default) { (action) in
                // アルバム起動
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
                    //DKImagePickerControllerのインスタンスを生成
                    let pickerController = DKImagePickerController()
                                // 選択可能な枚数を4にする
                        pickerController.maxSelectableCount = 3
                        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
                            print("Selected!")

                        // 選択された画像はassetsに入れて返却されるのでfetchして取り出す
                        for asset in assets {
                        asset.fetchFullScreenImage(completeBlock: { (image, info) in
                        // ここで取り出せる
                            if self.selectedImage.count <= 3 {
                                self.resizedImage = image?.scale(byFactor: 0.3)
                                self.selectedImage.append(self.resizedImage!)
                            } else {
                                self.selectedImage.removeFirst()
                                self.resizedImage = image?.scale(byFactor: 0.3)
                                self.selectedImage.append(self.resizedImage!)
                            }
                        
                                })
                            
                            self.loadView()
                            //loadviewすると全て一新するからtextviewもnilになってしまう
                            //self.viewWillAppear(true)
                            self.viewDidLoad()
                            }
                        }
                       self.present(pickerController, animated: true) {}
                        } else {
                        print("この機種ではフォトライブラリが使用出来ません。")
                    }
            }

            alertController.addAction(cancelAction)
            alertController.addAction(cameraAction)
            alertController.addAction(photoLibraryAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
        func sharePhoto() {
            HUD.show(.progress)
                        
            let postObject = NCMBObject(className: "Post")
            postObject?.setObject(NCMBUser.current(), forKey: "user")
            postObject?.setObject(self.dateTextField.text, forKey: "recorddate")
            postObject?.setObject(self.titleTextField.text, forKey: "title")
            postObject?.setObject(self.postTextView.text!, forKey: "text")
            
            if switchLabel.text == "共有する" {
                postObject?.setObject(true, forKey: "share")
            } else {
                postObject?.setObject(false, forKey: "share")
            }
            postObject?.setObject(self.selectedImage.count, forKey: "howmanyimages")
            for i in 1...3 {
                postObject?.setObject("noimage", forKey: "imageUrl" + String(i))
            }
            
            if selectedImage.count != 0 {
                let num = selectedImage.count
                for i in 1...num {
                    saveImage(imageNumber: i)
                }
            }
            
            postObject?.saveInBackground({ (error) in
                if error != nil {
                    HUD.flash(.error, delay: 2)
                } else {
                    //HUD.show(.progress)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0){
                        HUD.hide()
                        HUD.flash(.labeledSuccess(title: "編集完了", subtitle: "送信しました"), delay: 2)
                    }
                }
            })
            
        }
        func confirmContent() {
            if (dateTextField.text!.count > 0) && (titleTextField.text!.count > 0) {
                postButton.isEnabled = true
            } else {
                postButton.isEnabled = false
            }
        }

        @IBAction func cancel() {
            if postTextView.isFirstResponder == true {
                postTextView.resignFirstResponder()
            }

            let alert = UIAlertController(title: "編集は完了していません", message: "入力中の変更内容を破棄しますか？", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.navigationController?.popToRootViewController(animated: true)
                self.dismiss(animated: true, completion: nil)
                alert.dismiss(animated: true, completion: nil)
            })
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
                
            })
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        @IBAction func showAlert() {
                let alert = UIAlertController(title: "編集", message: "完了しましたか？", preferredStyle: .alert)
                //alertは真ん中にポンと出てくる
                //actionSheetはアプリの下からにゅっと出てくる
                
                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in

                    self.delete()
                    self.sharePhoto()
                    self.navigationController?.popToRootViewController(animated: true)
//                    self.dismiss(animated: true, completion: nil)
                    alert.dismiss(animated: true, completion: nil)
                }
                
                let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                    alert.dismiss(animated: true, completion: nil)
                    //キャンセルボタンを押した時のアクション
                }
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                //alertにactionを加える
                self.present(alert, animated: true, completion: nil)
            }
        
        func saveImage(imageNumber:Int) {
            var image = selectedImage[imageNumber-1]

            // 撮影した画像をデータ化したときに右に90度回転してしまう問題の解消
            UIGraphicsBeginImageContext(image.size)
            let rect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            image.draw(in: rect)
            image = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            let data = image.pngData()
            let fileName = UUID().uuidString + String(arc4random_uniform(100000000))
            let file = NCMBFile.file(withName: fileName, data: data) as! NCMBFile
            file.saveInBackground({ (error) in
                if error != nil {
                    HUD.hide()
                    let alert = UIAlertController(title: "画像アップロードエラー", message: error!.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    // 画像アップロードが成功
                    let query = NCMBQuery(className: "Post")
                    query?.whereKey("text", equalTo: self.postTextView.text)
                    query?.whereKey("user", equalTo: NCMBUser.current())
                    query?.whereKey("howmanyimages", equalTo: self.selectedImage.count)
                    query?.findObjectsInBackground({ (result, error) in
                        if error != nil {
                            HUD.flash(.error, delay: 2)
                        } else {
                            let Tweets = result as! [NCMBObject]
                            let tweetObject = Tweets.first
                            let url = "https://mbaas.api.nifcloud.com/2013-09-01/applications/U6JMTv054XyGhBEa/publicFiles/" + fileName
                            self.imageUrl = "imageUrl" + String(imageNumber)
    //                        print(self.imageUrl)
                            tweetObject?.setObject(url, forKey: self.imageUrl)
                            tweetObject?.saveInBackground({ (error) in
                                if error != nil {
                                    HUD.flash(.error, delay: 2)
                                } else {
                                }
                            })
                        }
                    })
                }
            })
            { (progress) in
                print(progress)
            }
            
        }
        
        func saveNoimage(imageNumber:Int) {
             // 画像アップロードが成功
                            let query = NCMBQuery(className: "Post")
                            query?.whereKey("text", equalTo: self.postTextView.text)
                            query?.whereKey("user", equalTo: NCMBUser.current())
                            query?.whereKey("howmanyimages", equalTo: self.selectedImage.count)
                            query?.findObjectsInBackground({ (result, error) in
                                if error != nil {
                                    HUD.flash(.error, delay: 2)
                                } else {
                                    let Tweets = result as! [NCMBObject]
                                    let tweetObject = Tweets.first
                                    
                                    self.imageUrl = "imageUrl" + String(imageNumber)
                                    print(self.imageUrl)
                                    tweetObject?.setObject("noimage", forKey: self.imageUrl)
                                    tweetObject?.saveInBackground({ (error) in
                                        if error != nil {
                                            HUD.flash(.error, delay: 2)
                                        } else {
                                        }
                                    })
                                }
                            })
            
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

