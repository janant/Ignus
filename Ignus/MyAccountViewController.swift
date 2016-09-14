//
//  MyAccountViewController.swift
//  Ignus
//
//  Created by Anant Jain on 2/7/15.
//  Copyright (c) 2015 Anant Jain. All rights reserved.
//

import UIKit

class MyAccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, FriendOptionsViewControllerDelegate {
    
    @IBOutlet weak var myProfileView: UIView!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var profileView: UIImageView!
    @IBOutlet weak var coverView: UIImageView!
    
    @IBOutlet weak var friendOptionsButton: UIButton!
    
    
    @IBOutlet weak var settingsTable: UITableView!
    
    var profilePickerVC: UIImagePickerController?
    var coverPickerVC: UIImagePickerController?
    
    var currentUser = PFUser.currentUser()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let selectedIndex = settingsTable.indexPathForSelectedRow() {
            settingsTable.deselectRowAtIndexPath(selectedIndex, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let user = currentUser
        self.nameLabel.text = user["FullName"] as? String
        self.usernameLabel.text = user["username"] as? String
        
        let profile = currentUser["Profile"] as! PFFile
        profile.getDataInBackgroundWithBlock { (data, error) -> Void in
            if error == nil {
                UIView.transitionWithView(self.profileView, duration: 0.3, options: .TransitionCrossDissolve, animations: { () -> Void in
                    self.profileView.image = UIImage(data: data)
                    }, completion: nil)
            }
        }
        
        let cover = currentUser["Cover"] as! PFFile
        cover.getDataInBackgroundWithBlock { (data, error) -> Void in
            if error == nil {
                UIView.transitionWithView(self.coverView, duration: 0.3, options: .TransitionCrossDissolve, animations: { () -> Void in
                    self.coverView.image = UIImage(data: data)
                    }, completion: nil)
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshProfile:", name: "Reload Settings Profile", object: nil)
        
        settingsTable.separatorEffect = UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark))
        settingsTable.backgroundView = nil
        
        profileView.contentMode = .ScaleAspectFill
        coverView.contentMode = .ScaleAspectFill
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Image picker controller delegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 17)!], forState: .Normal)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 18)!]
        
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        })
        
        if picker === profilePickerVC {
            let loadingAlert = UIAlertController(title: "Changing profile picture...", message: "\n\n", preferredStyle: .Alert)
            let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            loadingIndicatorView.color = UIColor.grayColor()
            loadingIndicatorView.startAnimating()
            loadingIndicatorView.center = CGPointMake(135, 65.5)
            loadingAlert.view.addSubview(loadingIndicatorView)
            presentViewController(loadingAlert, animated: true, completion: nil)
            
            let newProfileFile = PFFile(name: "Profile.png", data: UIImagePNGRepresentation(image))
            newProfileFile.saveInBackgroundWithBlock({ (completed, error) -> Void in
                if error == nil {
                    self.currentUser["Profile"] = newProfileFile
                    self.currentUser.saveInBackgroundWithBlock({ (completed, error) -> Void in
                        if error == nil {
                            self.profileView.image = image
                            loadingAlert.dismissViewControllerAnimated(true, completion: nil)
                            
                            var userInfo = [String: UIImage]()
                            userInfo["Profile"] = image
                            userInfo["Cover"] = self.coverView.image
                            
                            NSNotificationCenter.defaultCenter().postNotificationName("Refresh Profile", object: nil, userInfo: userInfo)
                        }
                    })
                }
            })
        }
        else if picker == coverPickerVC {
            let loadingAlert = UIAlertController(title: "Changing cover photo...", message: "\n\n", preferredStyle: .Alert)
            let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            loadingIndicatorView.color = UIColor.grayColor()
            loadingIndicatorView.startAnimating()
            loadingIndicatorView.center = CGPointMake(135, 65.5)
            loadingAlert.view.addSubview(loadingIndicatorView)
            presentViewController(loadingAlert, animated: true, completion: nil)
            
            let newCoverFile = PFFile(name: "Cover.png", data: UIImagePNGRepresentation(image))
            newCoverFile.saveInBackgroundWithBlock({ (completed, error) -> Void in
                if error == nil {
                    self.currentUser["Cover"] = newCoverFile
                    self.currentUser.saveInBackgroundWithBlock({ (completed, error) -> Void in
                        if error == nil {
                            self.coverView.image = image
                            loadingAlert.dismissViewControllerAnimated(true, completion: nil)
                            
                            var userInfo = [String: UIImage]()
                            userInfo["Profile"] = self.profileView.image
                            userInfo["Cover"] = image
                            
                            NSNotificationCenter.defaultCenter().postNotificationName("Refresh Profile", object: nil, userInfo: userInfo)
                        }
                    })
                }
            })
        }
        
        profilePickerVC = nil
        coverPickerVC = nil

    }
    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
//            UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
//        })
//        
//        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
//            if picker === profilePickerVC {
//                let loadingAlert = UIAlertController(title: "Changing profile picture...", message: "\n\n", preferredStyle: .Alert)
//                let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
//                loadingIndicatorView.color = UIColor.grayColor()
//                loadingIndicatorView.startAnimating()
//                loadingIndicatorView.center = CGPointMake(135, 65.5)
//                loadingAlert.view.addSubview(loadingIndicatorView)
//                presentViewController(loadingAlert, animated: true, completion: nil)
//                
//                let newProfileFile = PFFile(name: "Profile.png", data: UIImagePNGRepresentation(image))
//                newProfileFile.saveInBackgroundWithBlock({ (completed, error) -> Void in
//                    if error == nil {
//                        self.currentUser["Profile"] = newProfileFile
//                        self.currentUser.saveInBackgroundWithBlock({ (completed, error) -> Void in
//                            if error == nil {
//                                self.profileView.image = image
//                                loadingAlert.dismissViewControllerAnimated(true, completion: nil)
//                                
//                                var userInfo = [String: UIImage]()
//                                userInfo["Profile"] = image
//                                userInfo["Cover"] = self.coverView.image
//                                
//                                NSNotificationCenter.defaultCenter().postNotificationName("Refresh Profile", object: nil, userInfo: userInfo)
//                            }
//                        })
//                    }
//                })
//            }
//            else if picker == coverPickerVC {
//                let loadingAlert = UIAlertController(title: "Changing cover photo...", message: "\n\n", preferredStyle: .Alert)
//                let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
//                loadingIndicatorView.color = UIColor.grayColor()
//                loadingIndicatorView.startAnimating()
//                loadingIndicatorView.center = CGPointMake(135, 65.5)
//                loadingAlert.view.addSubview(loadingIndicatorView)
//                presentViewController(loadingAlert, animated: true, completion: nil)
//                
//                let newCoverFile = PFFile(name: "Cover.png", data: UIImagePNGRepresentation(image))
//                newCoverFile.saveInBackgroundWithBlock({ (completed, error) -> Void in
//                    if error == nil {
//                        self.currentUser["Cover"] = newCoverFile
//                        self.currentUser.saveInBackgroundWithBlock({ (completed, error) -> Void in
//                            if error == nil {
//                                self.coverView.image = image
//                                loadingAlert.dismissViewControllerAnimated(true, completion: nil)
//                                
//                                var userInfo = [String: UIImage]()
//                                userInfo["Profile"] = self.profileView.image
//                                userInfo["Cover"] = image
//                                
//                                NSNotificationCenter.defaultCenter().postNotificationName("Refresh Profile", object: nil, userInfo: userInfo)
//                            }
//                        })
//                    }
//                })
//            }
//            
//            profilePickerVC = nil
//            coverPickerVC = nil
//        }
//    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 17)!], forState: .Normal)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 18)!]
        
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        })
        profilePickerVC = nil
        coverPickerVC = nil
    }
    
    func refreshProfile(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            let userInfo = notification.userInfo as! [String: UIImage]
            self.profileView.image = userInfo["Profile"]
            self.coverView.image = userInfo["Cover"]
        })
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("Setting Cell", forIndexPath: indexPath) as! UITableViewCell
            
            cell.textLabel?.text = "Login Options"
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.grayColor()
            cell.selectedBackgroundView = backgroundView
            
            return cell
        }
        else if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("Setting Cell", forIndexPath: indexPath) as! UITableViewCell
            
            cell.textLabel?.text = "Acknowledgements"
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.grayColor()
            cell.selectedBackgroundView = backgroundView
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Log Out Cell", forIndexPath: indexPath) as! UITableViewCell
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.grayColor()
            cell.selectedBackgroundView = backgroundView
            
            return cell
        }
    }
    
    // MARK: - Table view delegate methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            performSegueWithIdentifier("Show Login Options", sender: nil)
        }
        else if indexPath.section == 1 {
            performSegueWithIdentifier("Show Acknowledgements", sender: nil)
        }
        else if indexPath.section == 2 {
            // Creates and presents logout action sheet
            let logoutConfirmation = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            logoutConfirmation.addAction(UIAlertAction(title: "Log Out", style: .Destructive, handler: { (action) -> Void in
                // Logs out
                PFUser.logOut()
                
                NSUserDefaults.standardUserDefaults().setBool(false, forKey: "AutomaticLoginEnabled")
                NSUserDefaults.standardUserDefaults().synchronize()
                
                self.dismissViewControllerAnimated(true, completion: nil)
            }))
            logoutConfirmation.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
                self.settingsTable.deselectRowAtIndexPath(indexPath, animated: true)
            }))
            presentViewController(logoutConfirmation, animated: true, completion: nil)
        }
    }
    
    // MARK: - FriendOptionsViewControllerDelegate methods
    
    func changeProfilePicture() {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.allowsEditing = true
        imagePickerVC.sourceType = .PhotoLibrary
        imagePickerVC.delegate = self
        
        UIBarButtonItem.appearance().setTitleTextAttributes(nil, forState: .Normal)
        UINavigationBar.appearance().titleTextAttributes = nil
        
        profilePickerVC = imagePickerVC
        presentViewController(imagePickerVC, animated: true) { () -> Void in
            UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        }
    }
    
    func changeCoverPhoto() {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.allowsEditing = true
        imagePickerVC.sourceType = .PhotoLibrary
        imagePickerVC.delegate = self
        
        UIBarButtonItem.appearance().setTitleTextAttributes(nil, forState: .Normal)
        UINavigationBar.appearance().titleTextAttributes = nil
        
        coverPickerVC = imagePickerVC
        presentViewController(imagePickerVC, animated: true) { () -> Void in
            UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        }
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning methods
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FriendOptionsTransition(presenting: true, sourceButtonFrame: self.view.convertRect(friendOptionsButton.frame, fromView: myProfileView), profileType: "Current User")
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FriendOptionsTransition(presenting: false, sourceButtonFrame: self.view.convertRect(friendOptionsButton.frame, fromView: myProfileView), profileType: "Current User")
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show User Options" {
            let friendOptionsVC = segue.destinationViewController as! FriendOptionsViewController
            friendOptionsVC.profileType = "Current User"
            friendOptionsVC.delegate = self
            friendOptionsVC.modalPresentationStyle = .Custom
            friendOptionsVC.transitioningDelegate = self
        }
    }

}
