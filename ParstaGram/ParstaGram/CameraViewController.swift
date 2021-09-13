//
//  CameraViewController.swift
//  ParstaGram
//
//  Created by Grace Brill on 9/12/21.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var commentField: UITextField!
    
    @IBAction func onCameraButton(_ sender: Any) {
        //configure the camera
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        //check if the camera is available
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            picker.sourceType = .camera
        }
        
        //use photo library
        else{
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //cast the image
        let image = info[.editedImage] as! UIImage
        
        //resize the image using AlamofireImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageAspectScaled(toFill: size)
        
        //place scaled image in imageView
        imageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {
        //interfacing with Parse
        let post = PFObject(className: "Posts")
        
        post["caption"] = commentField.text!
        post["author"] = PFUser.current()!
        
        //save image as a png
        let imageData =  imageView.image!.pngData()
        
        //create a new parse file: binary object
        let file = PFFileObject(name: "image.png", data: imageData!)
        
        
        post["image"] = file
        
        //save the image
        post.saveInBackground{(success, error) in
            if success{
                print("successfully saved")
                
                //dismiss the view
                self.dismiss(animated: true, completion: nil)
            }
            
            else{
                print("error saving")
            }
        }
        }
}
