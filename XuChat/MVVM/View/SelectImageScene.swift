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

class SelectImageScene: UIViewController {

    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var selectedImage: UIImageView!
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
}

extension SelectImageScene {
    
    fileprivate func saveToFireStore(userID:String, name: String, mail: String){
        
        guard let imageData = selectedImage.image?.pngData() else { return}
        
        let reference = Storage.storage().reference().child("ProfilePhoto").child("\(mail).png")
        
        reference.putData(imageData, metadata: nil) { (metaData, error) in
            if let error = error {
                print("Hata : \(error.localizedDescription)")
                return
            }
            reference.downloadURL { (url, error) in
                if let error = error {
                    print("URL Hatası : \(error.localizedDescription)")
                    return
                }
                if let url = url?.absoluteString {
                    let db = Firestore.firestore()
                    db.collection("Users").document(userID).setData([
                    "id" : userID,
                    "name" : name,
                    "mail" : mail,
                    "imageURL" : url,
                    "isPremium" : false
                    ]) { (error) in
                        if error == nil {
                            self.dismiss(animated: true, completion: nil)
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
