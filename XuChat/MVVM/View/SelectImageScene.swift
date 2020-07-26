//
//  SelectImageScene.swift
//  XuChat
//
//  Created by Ercan on 3.07.2020.
//  Copyright © 2020 Ercan. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import JGProgressHUD

class SelectImageScene: UIViewController {

    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var selectedImage: UIImageView!
    
    let hud = JGProgressHUD(style: .dark)
    
    var isSelectedImage : Bool!
    var nickName : String?
    var mail : String?
    var userID : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isSelectedImage = false
        
    }

    @IBAction func selectImage(_ sender: Any) {
        
        if isSelectedImage {
            guard let name = nickName, let mail = mail, let userID = userID else {return}
            saveToFireStore(userID: userID, name: name, mail: mail)
        }else{
            selectButton.setTitle("Upload", for: .normal)
            showImagePickerView()
        }
    }
    
    fileprivate func showProgress(){
        hud.textLabel.text = "Loading"
        hud.show(in: view)
    }
}

extension SelectImageScene {
    
    fileprivate func saveToFireStore(userID:String, name: String, mail: String){
        
        selectButton.isEnabled = false
        showProgress()
        
        guard let imageData = selectedImage.image?.pngData() else { return}
        
        let reference = Storage.storage().reference().child("ProfilePhoto").child("\(mail).png")
        
        reference.putData(imageData, metadata: nil) { (metaData, error) in
            if let error = error {
                print("Hata : \(error.localizedDescription)")
                return
            }
            reference.downloadURL { [weak self] (url, error) in
                if let error = error {
                    print("URL Hatası : \(error.localizedDescription)")
                    return
                }
                if let url = url?.absoluteString {
                    let app = UIApplication.shared.delegate as! AppDelegate
                    
                    let db = Firestore.firestore()
                    db.collection("Users").document(userID).setData([
                    "id" : userID,
                    "name" : name,
                    "mail" : mail,
                    "token" : app.token!,
                    "imageURL" : url,
                    "isPremium" : false
                    ]) { (error) in
                        if error == nil {
                            self?.hud.dismiss()
                            self?.dismiss(animated: true, completion: nil)
                            print("Kullanıcı kaydedildi")
                        }
                    }
                }
            }
        }
        
    }
}

extension SelectImageScene : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    fileprivate func showImagePickerView(){
        let pickerVC = UIImagePickerController()
        pickerVC.delegate = self
        pickerVC.sourceType = .photoLibrary
        pickerVC.allowsEditing = true
        present(pickerVC, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage.image = editedImage
            isSelectedImage = true
        }else{
            print("Resim seçilmedi")
        }
        dismiss(animated: true, completion: nil)
    }
}
