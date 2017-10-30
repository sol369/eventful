//
//  AlterProfileViewController.swift
//  Eventful
//
//  Created by Shawn Miller on 7/31/17.
//  Copyright © 2017 Make School. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import  Alamofire
import AlamofireImage
import SVProgressHUD

//let updateProfileTab : ProfileeViewController = ProfileeViewController()

class AlterProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//temporary holder for profile pic
    var profileImageTemp: UIImage? = UIImage()
    var uid = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        view?.backgroundColor = UIColor.white
        navigationItem.title = "Profile Settings"
//        self.navigationItem.hidesBackButton = true
//        let backButton = UIBarButtonItem(image: UIImage(named: "icons8-Back-64"), style: .plain, target: self, action: #selector(GoBack))
//        self.navigationItem.leftBarButtonItem = backButton
        //Will add the subviews to the screen
        view.addSubview(selectProfileImage)
        view.addSubview(changeProfilePicture)
        view.addSubview(changeUsername)
        view.addSubview(changeQuote)
        view.addSubview(saveProfileEdits)
        view.addSubview(backButton)

        
        ///Constraints for all views will go here
        
        //Constraints for the profile image
        _ = selectProfileImage.anchor(top: view.centerYAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: -275, paddingLeft: 135, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        //Constraints for the change profile picture button
         _ = changeProfilePicture.anchor(top: selectProfileImage.bottomAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 30, paddingLeft: 85, paddingBottom: 0, paddingRight: 0, width: 200, height: 35)
        //Constraints for the text field that corresponds to the user name
         _ = changeUsername.anchor(top: changeProfilePicture.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 35)
        //Constraints for the text field that corresponds to the label
        _ = changeQuote.anchor(top: changeUsername.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 15, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 35)
        _ = saveProfileEdits.anchor(top: changeQuote.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 200, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 200, height: 35)
         _ = backButton.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 10, paddingLeft: 4, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        ///////////////////////////////////////////////
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AlterProfileViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        
    }
    
    lazy var backButton: UIButton = {
        let backButton = UIButton(type: .system)
        backButton.setImage(#imageLiteral(resourceName: "icons8-Expand Arrow-48").withRenderingMode(.alwaysOriginal), for: .normal)
        backButton.addTarget(self, action: #selector(handleSettingsDismiss), for: .touchUpInside)
        return backButton
    }()
    
    func handleSettingsDismiss(){
        print("Button pressed")
        dismiss(animated: true, completion: nil)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

//    func GoBack(){
//        _ = self.navigationController?.popViewController(animated: true)
//    }
//    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        selectProfileImage.layer.cornerRadius = selectProfileImage.frame.size.width / 2;
        selectProfileImage.layer.masksToBounds = true
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Where all buttons and labels will be added
    
    lazy var selectProfileImage: UIImageView = {
        let selectPicture = UIImageView()
        //will set the default pic
       // self.selectProfileImage.layer.cornerRadius = self.selectProfileImage.frame.size.width / 2;
        let imageUrl = URL(string: User.current.profilePic!)
        print(imageUrl as Any)
        if User.current.profilePic != ""{
            print("Tried to load default pic")
            selectPicture.af_setImage(withURL: imageUrl!)
        }else{
            print("Set image Url")
            selectPicture.image = UIImage(named: "no-profile-pic")
        }
        
        selectPicture.layer.borderWidth = 1.0
        selectPicture.layer.borderColor = UIColor.black.cgColor
        // selectPicture.layer.cornerRadius = selectPicture.frame.size.width / 2;
        selectPicture.clipsToBounds = true
        selectPicture.translatesAutoresizingMaskIntoConstraints = false
        //selectPicture.layer.cornerRadius = selectPicture.frame.size.width/2
        selectPicture.contentMode = .scaleAspectFill
        selectPicture.isUserInteractionEnabled = true
        selectPicture.layer.shouldRasterize = true
        // will allow you to add a target to an image click
        selectPicture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        selectPicture.layer.masksToBounds = true
        return selectPicture
    }()

    //The button to trigger the image picker and change the image
    let changeProfilePicture: UIButton = {
        let changePicture = UIButton(type: .system)
        changePicture.backgroundColor = .black
        changePicture.setTitle("Choose Another Image", for: .normal)
        changePicture.setTitleColor(.white, for: .normal)
        changePicture.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        changePicture.addTarget(self, action: #selector(handleSelectProfileImageView), for: .touchUpInside)
        return changePicture
    }()
    
    
    //The text field that corresponds to changng the username
    
    let changeUsername: UITextField = {
      let changeName = UITextField()
        if User.current.username != ""{
            changeName.text = User.current.username
            print(changeName.text ?? "")
        }else{
            changeName.placeholder = "Username"
        }
        changeName.layer.borderColor = UIColor.lightGray.cgColor
        changeName.layer.borderWidth = 1
        changeName.textAlignment = .center
        return changeName
    }()
    
    //The text view that will correspond to the quote
    let changeQuote: UITextView = {
       let quoteAlter = UITextView()
        quoteAlter.textAlignment = .center
        if User.current.bio == ""{
            quoteAlter.textColor = UIColor.lightGray
            quoteAlter.text = "Bio..."
        }else{
            quoteAlter.textColor = UIColor.lightGray
            quoteAlter.text = User.current.bio
        }
        quoteAlter.autocorrectionType = UITextAutocorrectionType.no
        quoteAlter.returnKeyType = UIReturnKeyType.done
        quoteAlter.layer.borderColor = UIColor.lightGray.cgColor
        quoteAlter.layer.borderWidth = 1
        quoteAlter.isEditable = true
        quoteAlter.textContainer.maximumNumberOfLines = 1
        return quoteAlter
    }()
    //need to change to make sure user can not enter a million characters
    
    //will create the save edits button
    let saveProfileEdits: UIButton = {
        let saveEdits = UIButton(type: .system)
        saveEdits.backgroundColor = .black
        saveEdits.setTitle("End Edits", for: .normal)
        saveEdits.setTitleColor(.white, for: .normal)
        saveEdits.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        saveEdits.addTarget(self, action: #selector(saveCurrentEdits), for: .touchUpInside)
        return saveEdits
    }()
    
    // will save the edits made in edit profile view controller
    func saveCurrentEdits(){
        print("End edits pressed")
        var profilePic: String = ""
        // will set the username and bio and make sure that they are not empty
        guard let username = changeUsername.text,
            let bio = changeQuote.text,!username.isEmpty,
        !bio.isEmpty
            else { return }
        //will check for the change in value of username and bio
        
        //creates a unique id for storing images in firebase storage
        let imageName = NSUUID().uuidString
        //create a reference to the sotrage database in firebase
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).PNG")
        //following function does the work of putting it into firebase
            //notice I also set the value of profilepic oo it can be saved in the updated user instance in the database
        if let userImage = profileImageTemp,let uploadData = UIImageJPEGRepresentation(userImage, 0.1){
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error ?? "")
                    return
                }
                print(metadata ?? "")
                print(metadata?.downloadURL()!.absoluteString ?? "")
                profilePic = (metadata?.downloadURL()!.absoluteString)!
                print(profilePic)
                //need to change this so I edit based off whether a value is actually added or whether a username or bio is actually changed
                UserService.editProfileImage(url: profilePic, completion: { (user) in
                    if let user = user {
                        User.setCurrent(user, writeToUserDefaults: true)
                    }
                })
                UserService.edit(username: username, bio: bio ) { (user) in
                    guard let user = user else {
                        return
                    }
                    User.setCurrent(user, writeToUserDefaults: true)
                    //SCLAlertView().showSuccess("Success!", subTitle: "Your changes have been saved.")
                    
                }
                    print("User defaults reset")
                    
                }
            )
           // print("Image added to storage")
        }
        //   SCLAlertView().showNotice("Success!", subTitle: "Your changes have been saved.")
        
        _ = self.navigationController?.popViewController(animated: true)
    
        print("Image pushed off of stack")
    
        }
    ////////////////////////////////////////////////////////////////////////////
    //Will handle image selection
    
    func handleSelectProfileImageView(tapGestureRecognizer: UITapGestureRecognizer)  {
        print("123")
        //creates the image picker controller
        let picker = UIImagePickerController()
        //sets the delegate to self
        picker.delegate = self
        // this is set to true so that it can be zoomed in and out
        picker.allowsEditing = true
        show(picker, sender: self)
        
    }
    
    // will dispaly info of image selected
    //this picture will also set the current image so that depdning on whether or not the user edits the picture it will be saved into the selectedImageFromPicker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("info")
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage{
            print(editedImage.size)
            selectedImageFromPicker = editedImage
            profileImageTemp = selectedImageFromPicker!
            //added completion handler to grab image once it is seleted
            self.selectProfileImage.image = selectedImageFromPicker
            picker.dismiss(animated: true, completion: nil)

        }else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            print(originalImage.size)
            selectedImageFromPicker = originalImage
            //added completion handler to grab image once it is seleted
            self.selectProfileImage.image = selectedImageFromPicker
            profileImageTemp = selectedImageFromPicker!
            picker.dismiss(animated: true, completion: nil)
        
        }
        

    }
    // will handle the picker being closed/canceled
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("picker canceled")
        dismiss(animated: true, completion: nil)
    }
    
    
    
    /////
    

}
