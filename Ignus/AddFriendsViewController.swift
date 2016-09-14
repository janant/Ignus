//
//  AddFriendsViewController.swift
//  Ignus
//
//  Created by Anant Jain on 2/7/15.
//  Copyright (c) 2015 Anant Jain. All rights reserved.
//

import UIKit

class AddFriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var addFriendsList: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var noResultsText: UILabel!
    
    var currentFriends: [PFObject]?
    var requestedFriends: [PFObject]?
    
    var friendsQuery = PFQuery()
    var searchedFriends = [PFObject]()
    
    let currentUser = PFUser.currentUser()

    override func viewWillAppear(animated: Bool) {
        addFriendsList.userInteractionEnabled = true
        if let selectedIndex = addFriendsList.indexPathForSelectedRow() {
            addFriendsList.deselectRowAtIndexPath(selectedIndex, animated: true)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if searchedFriends.count == 0 {
            searchBar.becomeFirstResponder()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        addFriendsList.contentInset = UIEdgeInsets(top: self.navigationController!.navigationBar.frame.size.height + UIApplication.sharedApplication().statusBarFrame.size.height, left: 0, bottom: 0, right: 0)
        
        addFriendsList.setContentOffset(CGPoint(x: 0, y: -64), animated: false)
        
        searchBar.keyboardAppearance = .Dark
        self.addFriendsList.separatorStyle = .None
        self.addFriendsList.separatorEffect = UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark))
        
        addFriendsList.scrollEnabled = false
        
        for subview in searchBar.subviews[0].subviews {
            if let textField = subview as? UITextField {
                textField.font = UIFont(name: "Gotham-Medium", size: 14)
                textField.textColor = UIColor.whiteColor()
                textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 14)!])
                break
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Keyboard appearance notifications
    
    func keyboardWillShow(sender: NSNotification) {
        if let userInfo = sender.userInfo {
            if let keyboardHeight = userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().height {
                self.addFriendsList.contentInset.bottom = keyboardHeight
            }
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        self.addFriendsList.contentInset.bottom = 0
        self.addFriendsList.contentOffset = CGPoint(x: 0, y: 0)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        switch selectedScope {
        case 0:
            searchBar.placeholder = "Search by name"
        case 1:
            searchBar.placeholder = "Search by username"
        default:
            break
        }
        
        self.searchBar(self.searchBar, textDidChange: self.searchBar.text!)
        
        for subview in searchBar.subviews[0].subviews {
            if let textField = subview as? UITextField {
                textField.attributedPlaceholder = NSAttributedString(string: textField.placeholder!, attributes: [NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 14)!])
                break
            }
        }
    }

    @IBAction func dismissAddFriends(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        addFriendsList.setContentOffset(CGPoint(x: 0, y: -64), animated: true)
        
        
        if count(searchText) != 0 {
            friendsQuery = PFUser.query()
            friendsQuery.whereKey(searchBar.selectedScopeButtonIndex == 1 ? "username" : "FullName", containsString: searchText)
            friendsQuery.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    self.searchedFriends = objects as! [PFObject]
                    self.addFriendsList.reloadData()
                    
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.addFriendsList.separatorStyle = self.searchedFriends.count == 0 ? .None : .SingleLine
                        self.noResultsText.alpha = self.searchedFriends.count == 0 ? 1.0 : 0.0
                        self.addFriendsList.scrollEnabled = self.searchedFriends.count != 0
                    })
                } else {
                    print(error.localizedDescription)
                }
            })
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.addFriendsList.alpha = 1.0
                self.addFriendsList.userInteractionEnabled = true
            })
            self.addFriendsList.separatorStyle = .SingleLine
        }
        else {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.noResultsText.alpha = 0.0
                self.addFriendsList.separatorStyle = .None
            })
            
            addFriendsList.scrollEnabled = false
            
            searchedFriends = [PFObject]()
            self.addFriendsList.reloadData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedFriends.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Friend Cell") as! UITableViewCell
        
        let user = searchedFriends[indexPath.row]
        
        let friendImageView = cell.viewWithTag(1) as! UIImageView
        let friendNameView = cell.viewWithTag(2) as! UILabel
        let friendUsernameView = cell.viewWithTag(3) as! UILabel
        
        if let profileFile = user["Profile"] as? PFFile {
            profileFile.getDataInBackgroundWithBlock { (data, error) -> Void in
                if error == nil {
                    UIView.transitionWithView(friendImageView, duration: 0.3, options: .TransitionCrossDissolve, animations: { () -> Void in
                        friendImageView.image = UIImage(data: data)
                        }, completion: nil)
                }
            }
        }
        else {
            UIView.transitionWithView(friendImageView, duration: 0.3, options: .TransitionCrossDissolve, animations: { () -> Void in
                friendImageView.image = UIImage(named: "DefaultProfile.png")
                }, completion: nil)
        }
        
        friendNameView.text = (user["FirstName"] as! String) + " " + (user["LastName"] as! String)
        friendUsernameView.text = user["username"] as? String
        
        cell.backgroundColor = UIColor.clearColor()
        cell.backgroundView = UIView()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.grayColor()
        backgroundView.alpha = 0.5
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let searchedFriend = searchedFriends[indexPath.row]
        tableView.userInteractionEnabled = false
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            let userType = self.userType(searchedFriend)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.performSegueWithIdentifier("Show Profile", sender: [searchedFriend, userType])
            })
        })
        
        
    }
    
    func userType(searchedFriend: PFObject) -> String {
        if searchedFriend["username"] as! String == currentUser.username {
            return "Current User"
        }
        
        for currentFriend in currentFriends! {
            if (currentFriend["username"] as! String) == (searchedFriend["username"] as! String) {
                return "Friend"
            }
        }
        
        for requestedFriend in requestedFriends! {
            if (requestedFriend["username"] as! String) == (searchedFriend["username"] as! String) {
                return "Requested Friend"
            }
        }
        
        let friendObjectQuery = PFQuery(className: "Friends")
        friendObjectQuery.whereKey("User", equalTo: searchedFriend["username"] as! String)
        let searchedFriendFriendObject = friendObjectQuery.getFirstObject()
        
        for friendReceivedRequest in searchedFriendFriendObject["Received"] as! [String] {
            if friendReceivedRequest == currentUser.username {
                return "Pending Friend"
            }
        }
        
        return "User"
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Profile" {
            let senderData = sender as! [AnyObject]
            let profileVC = segue.destinationViewController as! ProfileViewController
            
            profileVC.user = senderData[0] as? PFObject
            profileVC.profileType = senderData[1] as! String
            
        }
    }

}
