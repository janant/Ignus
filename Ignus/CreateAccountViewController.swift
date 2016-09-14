//
//  CreateAccountViewController.swift
//  Usef
//
//  Created by Anant Jain on 12/26/14.
//  Copyright (c) 2014 Anant Jain. All rights reserved.
//

import UIKit

protocol CreateAccountViewControllerDelegate {
    func createdAccountWithUsername(username: String, password: String)
}

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var creatingAccountView: UIVisualEffectView!
    
    @IBOutlet weak var firstNameTextFieldBox: UIView!
    @IBOutlet weak var lastNameTextFieldBox: UIView!
    @IBOutlet weak var emailTextFieldBox: UIView!
    @IBOutlet weak var usernameTextFieldBox: UIView!
    @IBOutlet weak var passwordTextFieldBox: UIView!
    @IBOutlet weak var confirmPasswordTextFieldBox: UIView!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var creatingAccountIndicatorView: UIActivityIndicatorView!
    
    
    var delegate: CreateAccountViewControllerDelegate?
    
    var toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.size.width, height: 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, 300)
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
        
        toolbar.barStyle = .Black
        toolbar.tintColor = UIColor.whiteColor()
        toolbar.items = [UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil), UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "resignTextBoxFirstResponder")]
        
        firstNameTextField.inputAccessoryView = toolbar
        lastNameTextField.inputAccessoryView = toolbar
        emailTextField.inputAccessoryView = toolbar
        usernameTextField.inputAccessoryView = toolbar
        passwordTextField.inputAccessoryView = toolbar
        confirmPasswordTextField.inputAccessoryView = toolbar
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().height {
                self.scrollView.contentInset.bottom = keyboardHeight
            }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.scrollView.contentInset.bottom = 0
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    func resignTextBoxFirstResponder() {
        if firstNameTextField.isFirstResponder() {
            firstNameTextField.resignFirstResponder()
        }
        else if lastNameTextField.isFirstResponder() {
            lastNameTextField.resignFirstResponder()
        }
        else if emailTextField.isFirstResponder() {
            emailTextField.resignFirstResponder()
        }
        else if usernameTextField.isFirstResponder() {
            usernameTextField.resignFirstResponder()
        }
        else if passwordTextField.isFirstResponder() {
            passwordTextField.resignFirstResponder()
        }
        else if confirmPasswordTextField.isFirstResponder() {
            confirmPasswordTextField.resignFirstResponder()
        }
    }
    
    @IBAction func selectFirstNameTextField(sender: AnyObject) {
        firstNameTextField.becomeFirstResponder()
    }
    
    @IBAction func selectLastNameTextField(sender: AnyObject) {
        lastNameTextField.becomeFirstResponder()
    }
    
    @IBAction func selectEmailTextField(sender: AnyObject) {
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func selectUsernameTextField(sender: AnyObject) {
        usernameTextFieldBox.becomeFirstResponder()
    }
    
    @IBAction func selectPasswordTextField(sender: AnyObject) {
        passwordTextField.becomeFirstResponder()
    }
    
    @IBAction func selectConfirmPasswordTextField(sender: AnyObject) {
        confirmPasswordTextField.becomeFirstResponder()
    }
    
    @IBAction func cancelAccountCreation(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signUp(sender: AnyObject) {
        creatingAccountIndicatorView.startAnimating()
        self.scrollView.userInteractionEnabled = false
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.scrollView.alpha = 0.0
        }) { (completed) -> Void in
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.creatingAccountView.alpha = 1.0
            })
        }
        
        var alert: UIAlertController?
        
        if count(firstNameTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)) == 0 {
            alert = UIAlertController(title: "Error", message: "Please enter a valid first name.", preferredStyle: .Alert)
        }
        else if count(lastNameTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)) == 0 {
            alert = UIAlertController(title: "Error", message: "Please enter a valid last name.", preferredStyle: .Alert)
        }
        else if count(emailTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)) == 0 {
            alert = UIAlertController(title: "Error", message: "Please enter a valid email address.", preferredStyle: .Alert)
        }
        else if count(usernameTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)) == 0 {
            alert = UIAlertController(title: "Error", message: "Please enter a valid username.", preferredStyle: .Alert)
        }
        else if count(passwordTextField.text!) == 0 {
            alert = UIAlertController(title: "Error", message: "Please enter a valid password.", preferredStyle: .Alert)
        }
        else if count(confirmPasswordTextField.text!) == 0 {
            alert = UIAlertController(title: "Error", message: "Please confirm your password.", preferredStyle: .Alert)
        }
        else if (passwordTextField.text != confirmPasswordTextField.text) {
            alert = UIAlertController(title: "Error", message: "The password and the confirmation password are not the same.", preferredStyle: .Alert)
        }
        
        if let errorAlert = alert {
            errorAlert.addAction(UIAlertAction(title: "Done", style: .Default, handler: nil))
            presentViewController(errorAlert, animated: true, completion: nil)
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.creatingAccountView.alpha = 0.0
            }) { (completed) -> Void in
                self.creatingAccountIndicatorView.startAnimating();
                self.scrollView.userInteractionEnabled = true
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.scrollView.alpha = 1.0
                })
            }
        }
        else {
            let newUser = PFUser()
            newUser.username = usernameTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            newUser.password = passwordTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            newUser.email = emailTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            let firstName = firstNameTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let lastName = lastNameTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
            
            newUser["FirstName"] = firstName
            newUser["LastName"] = lastName
            newUser["FullName"] = firstName + " " + lastName
            
            let profileFile = PFFile(name: "Profile.png", data: UIImagePNGRepresentation(UIImage(named: "DefaultProfile.png")!))
            let coverFile = PFFile(name: "Cover.png", data: UIImagePNGRepresentation(UIImage(named: "DefaultCover.png")!))
            
            profileFile.saveInBackgroundWithBlock({ (completed: Bool, error: NSError!) -> Void in
                if error == nil {
                    newUser["Profile"] = profileFile
                    
                    coverFile.saveInBackgroundWithBlock({ (completed: Bool, error: NSError!) -> Void in
                        if error == nil {
                            newUser["Cover"] = coverFile
                            
                            newUser.signUpInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                                if error == nil {
                                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                                        let friendsObject = PFObject(className: "Friends")
                                        friendsObject["User"] = newUser.username
                                        friendsObject["Friends"] = [String]()
                                        friendsObject["Sent"] = [String]()
                                        friendsObject["Received"] = [String]()
                                        friendsObject.saveInBackground()
                                        
                                        self.delegate?.createdAccountWithUsername(self.usernameTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil), password: self.passwordTextField.text!.stringByReplacingOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil))
                                    })
                                }
                                else {
                                    println(error.code)
                                    var errorMessage = error.localizedDescription
                                    if error.code == 125 {
                                        errorMessage = "Invalid email address."
                                    }
                                    else if error.code == 202 {
                                        errorMessage = "The username is already in use. Please choose a different one."
                                    }
                                    else if error.code == 203 {
                                        errorMessage = "The email address is already being used by a different account. Please choose a different one."
                                    }
                                    let errorAlert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .Alert)
                                    errorAlert.addAction(UIAlertAction(title: "Done", style: .Default, handler: nil))
                                    self.presentViewController(errorAlert, animated: true, completion: nil)
                                    
                                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                                        self.creatingAccountView.alpha = 0.0
                                        }) { (completed) -> Void in
                                            self.creatingAccountIndicatorView.startAnimating();
                                            self.scrollView.userInteractionEnabled = true
                                            UIView.animateWithDuration(0.2, animations: { () -> Void in
                                                self.scrollView.alpha = 1.0
                                            })
                                    }
                                }
                            })
                        }
                        else {
                            let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
                            errorAlert.addAction(UIAlertAction(title: "Done", style: .Default, handler: nil))
                            self.presentViewController(errorAlert, animated: true, completion: nil)
                            
                            UIView.animateWithDuration(0.2, animations: { () -> Void in
                                self.creatingAccountView.alpha = 0.0
                                }) { (completed) -> Void in
                                    self.creatingAccountIndicatorView.startAnimating();
                                    self.scrollView.userInteractionEnabled = true
                                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                                        self.scrollView.alpha = 1.0
                                    })
                            }
                        }
                    })
                }
                else {
                    let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
                    errorAlert.addAction(UIAlertAction(title: "Done", style: .Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                    
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        self.creatingAccountView.alpha = 0.0
                        }) { (completed) -> Void in
                            self.creatingAccountIndicatorView.startAnimating();
                            self.scrollView.userInteractionEnabled = true
                            UIView.animateWithDuration(0.2, animations: { () -> Void in
                                self.scrollView.alpha = 1.0
                            })
                    }
                }
            })
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        var offset = textField.superview!.frame.origin
        offset.x = 0
        offset.y -= 60
        
        scrollView.setContentOffset(offset, animated: true)
        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case firstNameTextField:
            lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            usernameTextField.becomeFirstResponder()
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            confirmPasswordTextField.becomeFirstResponder()
        case confirmPasswordTextField:
            confirmPasswordTextField.resignFirstResponder()
        default:
            break
        }
        return true
    }
    
    // MARK: - Navigation
    @IBAction func returnToCreateAccountVC(segue: UIStoryboardSegue) {
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 17)!], forState: .Normal)
    }
}
