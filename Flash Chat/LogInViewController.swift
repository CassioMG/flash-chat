//
//  LogInViewController.swift
//  Flash Chat
//
//  This is the view controller where users login


import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
    @IBAction func logInPressed(_ sender: AnyObject) {

        SVProgressHUD.show(withStatus: "Logging in...")
        
        Auth.auth().signIn(withEmail: emailTextfield.text!, password: passwordTextfield.text!) { (_, error) in
            
            SVProgressHUD.dismiss()
            
            if error != nil {
                print("ERROR LOGGING IN: ", error!)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let alertController = UIAlertController(title: "Log In error", message: error?.localizedDescription, preferredStyle: .alert)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
    }

    
}  
