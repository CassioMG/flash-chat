//
//  RegisterViewController.swift
//  Flash Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func registerPressed(_ sender: AnyObject) {
        
        SVProgressHUD.show(withStatus: "Registering...")
        
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (_ , error) in
            
            SVProgressHUD.dismiss()
            
            if error != nil {
                print("AUTH ERROR: ", error!)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                    self.emailTextfield.text = ""
                    self.passwordTextfield.text = ""
                }
                
                let alertController = UIAlertController(title: "Error creating new account", message: error?.localizedDescription, preferredStyle: .alert)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
    } 
    
    
}
