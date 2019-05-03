//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var messageArray : [Message] = [Message]()
    
    // Default keyboard animation values (iPhone 8 Plus)
    var keyboardHeight : CGFloat = 271.0
    var animationDuration : Double = 0.25
    var animationCurve : UInt = 7
    var initialHeightConstraintConstant: CGFloat = 50.0
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTextfield.delegate = self
        
        let tapGesture = UITapGestureRecognizer (target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retrieveMessages()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        initialHeightConstraintConstant = heightConstraint.constant
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        let message : Message = messageArray[indexPath.row]
        
        cell.messageBody.text = message.messageBody
        cell.senderUsername.text = message.sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if message.sender == Auth.auth().currentUser?.email {
            cell.avatarImageView.backgroundColor = UIColor.flatBlue()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
            
        } else {
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatGreen()
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    // MARK: -
    
    
    @objc func tableViewTapped () {
        messageTextfield.endEditing(true)
    }
    
    // MARK: - Keyboard Notifications
    @objc func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }
        
        if let animationDurationNumber: NSNumber = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber {
            animationDuration = animationDurationNumber.doubleValue
        }
        
        if let animationCurveNumber: NSNumber = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber {
            animationCurve = animationCurveNumber.uintValue
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions(rawValue: animationCurve), animations: {
            
            self.heightConstraint.constant = self.keyboardHeight + self.initialHeightConstraintConstant
            self.view.layoutIfNeeded()
            
        }, completion: nil)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions(rawValue: animationCurve), animations: {
            
            self.heightConstraint.constant = self.initialHeightConstraintConstant
            self.view.layoutIfNeeded()
            
        }, completion: nil)
        
    }
    // MARK : -
    
    func configureTableView () {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 100.0
    }
    
    // MARK: - TextField Delegate Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    //MARK: - Send & Receive from Firebase
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        messageTextfield.endEditing(true)
        
        let messagesDB = Database.database().reference().child("Messages")
        let message = ["Sender" : Auth.auth().currentUser?.email, "MessageBody" : messageTextfield.text!]
        messagesDB.childByAutoId().setValue(message) { (error, _) in

            if error != nil {
                print("ERROR SENDING MESSAGE: ", error!)

            } else {
                self.messageTextfield.text = ""
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true

            }
        }
    }
    
    func retrieveMessages () {
        
        let messagesDB = Database.database().reference().child("Messages")
        messagesDB.observe(.childAdded) { (snapshot) in
            
            let messageDict = snapshot.value as! Dictionary<String,String>
            
            let message = Message()
            message.sender = messageDict["Sender"]!
            message.messageBody = messageDict["MessageBody"]!

            self.messageArray.append(message)
            
            self.configureTableView()
            self.messageTableView.reloadData()
        }
    }
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        do {
            try Auth.auth().signOut()
        }
        catch {
            print("=X=X=X=X=X=X=X=X=X=  ERROR LOGGING OUT =X=X=X=X=X=X=X=X=X=X=")
        }
        
        guard (navigationController?.popToRootViewController(animated: true)) != nil
            else {
                print("=X=X=X=X=X=X=X=X=X=  No view controllers to pop off =X=X=X=X=X=X=X=X=X=X=")
                return
        }
    }

    
}
