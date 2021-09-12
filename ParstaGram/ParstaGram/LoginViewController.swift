//
//  LoginViewController.swift
//  ParstaGram
//
//  Created by Grace Brill on 9/11/21.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func onSignIn(_ sender: Any) {
        let username = usernameField.text!
        let password = passwordField.text!
        
        //either we have a user or the user is nil
        PFUser.logInWithUsername(inBackground: username, password: password) { (user, error) in
            
            //check that user is NOT nil
            //if so, perform segue
            if(user != nil){
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            
            //user is nil
            else{
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    @IBAction func onSignUp(_ sender: Any) {
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        
        user.signUpInBackground { (success, error) in
            
            //success signing up
            //move to next screen
            if success{
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            
            //error case
            else{
                print("Error: \(String(describing: error?.localizedDescription))")
            }
            
        }
    }

}
