//
//  EditUserViewController.swift
//  labox
//
//  Created by 周依琳 on 2020/04/21.
//  Copyright © 2020 Yilin. All rights reserved.
//

import UIKit
import NCMB
import PKHUD

class EditUserViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var resizeduserImage: UIImage!
    var resizedbackImage: UIImage!
    var userimagecount: Bool = false
    var backimagecount: Bool = false
    var userimagedata: Data!
    var backimagedata: Data!
    var userurl: String!
    var backurl: String!
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var backImageView: UIImageView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var introduceTextView: UITextView!
    @IBOutlet var placeTextField: UITextField!
    @IBOutlet var labnameTextField: UITextField!
    @IBOutlet var majorTextField: UITextField!
    
    @IBOutlet var userimageButton: UIButton!
    @IBOutlet var backimageButton: UIButton!
    
    @IBOutlet var saveButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backImageView.image = UIImage(named: "back.png")
        userImageView.backgroundColor = UIColor.white
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.clipsToBounds = true

        nameTextField.delegate = self
        introduceTextView.delegate = self
        placeTextField.delegate = self
        labnameTextField.delegate = self
        majorTextField.delegate = self
        
        loadDate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //ユーザー情報の取得
        loadDate()
    }
    //入力画面ないしkeyboardの外を押したら、キーボードを閉じる処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (self.introduceTextView.isFirstResponder) {
            self.introduceTextView.resignFirstResponder()
        }
    }
    
    func loadDate() {
        if let user = NCMBUser.current() {
            nameTextField.text = NCMBUser.current().object(forKey: "userName") as? String
            introduceTextView.text = NCMBUser.current().object(forKey: "introduction") as? String
            placeTextField.text = NCMBUser.current()?.object(forKey: "place") as? String
            labnameTextField.text = NCMBUser.current()?.object(forKey: "labname") as? String
            majorTextField.text = NCMBUser.current()?.object(forKey: "major") as? String

            self.navigationItem.title = user.userName
            //let userId = NCMBUser.current().userName
            //画像を取得
            let userfile = NCMBFile.file(withName: user.objectId + "user", data: nil) as! NCMBFile
            userfile.getDataInBackground { (data, error) in
                if error != nil {
                    HUD.flash(.labeledError(title: "画像取得エラー", subtitle: ""), delay: 2.0)
                } else {
                    if data != nil {
                        //dataの中身があれば画像を表示
                        let image = UIImage(data: data!)
                        self.userImageView.image = image
                    }
                }
                let backfile = NCMBFile.file(withName: user.objectId + "back", data: nil) as! NCMBFile
                backfile.getDataInBackground { (data, error) in
                    if error != nil {
                        let alert = UIAlertController(title: "画像取得エラー", message: error!.localizedDescription, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            
                        })
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        if data != nil {
                            //dataの中身があれば画像を表示
                            let image = UIImage(data: data!)
                            self.backImageView.image = image
                        }
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
    
   //キーボードの完了が押されたときに呼ばれるデリケードメソッド
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        confirmContent()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    //imagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        if userimagecount == true {
            resizeduserImage = selectedImage.scale(byFactor: 0.1)
            //userImageView.image = resizeduserImage
            picker.dismiss(animated: true, completion: nil)
            
            let userdata = resizeduserImage!.pngData()
            let file = NCMBFile.file(withName: NCMBUser.current()!.objectId + "user", data: userdata) as! NCMBFile
            file.saveInBackground({ (error) in
                if error != nil {
                } else {
                    self.userImageView.image = self.resizeduserImage
                    self.userimagecount = false
                }
            }) { (progress) in
                print(progress)
            }
        }
        if backimagecount == true {
            resizedbackImage = selectedImage.scale(byFactor: 0.1)
//            backImageView.image = resizedbackImage
            picker.dismiss(animated: true, completion: nil)
            
            let backdata = resizeduserImage!.pngData()
            let file = NCMBFile.file(withName: NCMBUser.current()!.objectId + "back", data: backdata) as! NCMBFile
            file.saveInBackground({ (error) in
                if error != nil {
//                    let alert = UIAlertController(title: "画像アップロードエラー", message: error!.localizedDescription, preferredStyle: .alert)
//                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
//
//                    })
//                    alert.addAction(okAction)
//                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.backImageView.image = self.resizedbackImage
                    self.backimagecount = false
                }
            }) { (progress) in
                print(progress)
            }
        }
        
        //confirmContent()
    }
    
    func selectImage() {
        print(userimagecount)
        print(backimagecount)
        let alertController = UIAlertController(title: "画像選択", message: "画像を選択して下さい。", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "カメラで撮影", style: .default) { (action) in
            // カメラ起動
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではカメラが使用出来ません。")
            }
        }
        
        let photoLibraryAction = UIAlertAction(title: "フォトライブラリから選択", style: .default) { (action) in
            // アルバム起動
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではフォトライブラリが使用出来ません。")
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func selectuserImage() {
        userimagecount = true
        selectImage()
    }
    
    @IBAction func selectbackImage() {
        backimagecount = true
        selectImage()
    }
    
    
    func confirmContent() {
        if nameTextField.text!.count > 0 && introduceTextView.text.count > 0 {
            saveButton.isEnabled = true
        } else {
            saveButton.isEnabled = false
        }
    }
    
    @IBAction func saveUserInfo() {
        if resizedbackImage != nil {
            backimagedata = resizedbackImage!.pngData()
            let backfile = NCMBFile.file(withName: NCMBUser.current()!.objectId + "back", data: backimagedata) as! NCMBFile
            backfile.saveInBackground({ (error) in
                if error != nil {
                    let alert = UIAlertController(title: "画像アップロードエラー", message: error!.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.backurl = "https://mbaas.api.nifcloud.com/2013-09-01/applications/U6JMTv054XyGhBEa/publicFiles/" + backfile.name
                }
            }) { (progress) in
                print(progress)
            }
            
        }
        
        if resizeduserImage != nil {
            userimagedata = resizeduserImage!.pngData()
            let userfile = NCMBFile.file(withName: NCMBUser.current()!.objectId + "user", data: userimagedata) as! NCMBFile
            userfile.saveInBackground({ (error) in
                if error != nil {
                    let alert = UIAlertController(title: "画像アップロードエラー", message: error!.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.userurl = "https://mbaas.api.nifcloud.com/2013-09-01/applications/U6JMTv054XyGhBEa/publicFiles/" + userfile.name
                }
            }) { (progress) in
                print(progress)
            }
            
        }
        
        
        let user = NCMBUser.current()
        user?.setObject(nameTextField.text, forKey: "userName")
        user?.setObject(introduceTextView.text, forKey: "introduction")
        user?.setObject(placeTextField.text, forKey: "place")
        user?.setObject(labnameTextField.text, forKey: "labname")
        user?.setObject(majorTextField.text, forKey: "major")
       
        user?.setObject(userurl, forKey: "userURL")
        user?.setObject(backurl, forKey: "backURL")

        user?.saveInBackground({ (error) in
            if error != nil {
                let alert = UIAlertController(title: "送信エラー", message: error!.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alert.dismiss(animated: true, completion: nil)
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                self.dismiss(animated: true, completion: nil)
                self.navigationController?.popToRootViewController(animated: true)
            }
        })
    }
    
    @IBAction func back() {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }

}
