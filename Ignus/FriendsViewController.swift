//
//  FriendsViewController.swift
//  Ignus
//
//  Created by Anant Jain on 2/7/15.
//  Copyright (c) 2015 Anant Jain. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, RespondToFriendRequestViewControllerDelegate {
    
    @IBOutlet weak var friendsTable: UITableView!
    @IBOutlet weak var noFriendsView: UIView!
    @IBOutlet weak var friendsFilterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var friendsLoadingIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var noFriendsTitle: UILabel!
    @IBOutlet weak var noFriendsDescription: UILabel!
    
    var respondSender: UIButton?
    
    var currentFriends = [PFObject]()
    var requestedFriends = [PFObject]()
    var currentUser = PFUser.currentUser()
    
    var sourceButtonFrame = CGRect()
    var sourceCellFrame = CGRect()
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let selectedIndexPath = friendsTable.indexPathForSelectedRow() {
            friendsTable.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        friendsLoadingIndicatorView.startAnimating();
        
        friendsTable.separatorEffect = UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark))
        refreshControl.addTarget(self, action: "reloadData:isInitialLoad:", forControlEvents: .ValueChanged)
        refreshControl.tintColor = UIColor.whiteColor()
        friendsTable.addSubview(refreshControl)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshFriends:", name: "Reload Friends", object: nil)
        
        reloadData(nil, isInitialLoad: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshFriends(notification: NSNotification) {
        reloadData(notification)
    }
    
    func reloadData(sender: AnyObject?, isInitialLoad: Bool = false) {
        let addFriendsButton = self.navigationItem.rightBarButtonItem
        if isInitialLoad {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            let friendsQuery = PFQuery(className: "Friends")
            friendsQuery.whereKey("User", equalTo: self.currentUser.username)
            if let friendsCurrentUserObject = friendsQuery.getFirstObject() {
                self.currentFriends = [PFObject]()
                self.requestedFriends = [PFObject]()
                
                // Load current friends.
                for friendUsername in friendsCurrentUserObject["Friends"] as! [String] {
                    let friendsQuery = PFUser.query()
                    friendsQuery.whereKey("username", equalTo: friendUsername)
                    self.currentFriends.append(friendsQuery.getFirstObject())
                }
                
                // Load friend requests.
                for friendRequestUsername in friendsCurrentUserObject["Received"] as! [String] {
                    let friendRequestQuery = PFUser.query()
                    friendRequestQuery.whereKey("username", equalTo: friendRequestUsername)
                    self.requestedFriends.append(friendRequestQuery.getFirstObject())
                }
                
                // Hides or shows the table view and other related views if the user has any friends/requests.
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if (self.refreshControl.refreshing) {
                        self.refreshControl.endRefreshing()
                    }
                    
                    self.friendsTable.hidden = false
                    self.noFriendsView.hidden = false
                    
                    if isInitialLoad {
                        self.friendsTable.reloadData()
                        self.navigationItem.setRightBarButtonItem(addFriendsButton, animated: true)
                    }
                    
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.updateRequests()
                        self.friendsLoadingIndicatorView.alpha = 0.0
                        
                        switch self.friendsFilterSegmentedControl.selectedSegmentIndex {
                        case 0:
                            self.noFriendsView.alpha = self.currentFriends.count == 0 ? 1.0 : 0.0
                            self.friendsTable.alpha = self.currentFriends.count == 0 ? 0.0 : 1.0
                        case 1:
                            self.noFriendsView.alpha = self.requestedFriends.count == 0 ? 1.0 : 0.0
                            self.friendsTable.alpha = self.requestedFriends.count == 0 ? 0.0 : 1.0
                        default:
                            break
                        }
                    }, completion: { (completed) -> Void in
                        self.friendsLoadingIndicatorView.stopAnimating()
                        self.friendsLoadingIndicatorView.hidden = true
                        
                        self.changeFilterMode(self.friendsFilterSegmentedControl)
                    })
                    
                    if !isInitialLoad {
                        self.friendsTable.reloadData()
                    }
                })
            }
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch friendsFilterSegmentedControl.selectedSegmentIndex {
        case 0:
            return currentFriends.count
        case 1:
            return requestedFriends.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return friendsFilterSegmentedControl.selectedSegmentIndex == 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (friendsFilterSegmentedControl.selectedSegmentIndex == 0) {
            let cell = tableView.dequeueReusableCellWithIdentifier("Friend Cell") as! UITableViewCell
            
            let personImageView = cell.viewWithTag(1) as! UIImageView!
            let personNameView = cell.viewWithTag(2) as! UILabel!
            let personUsernameView = cell.viewWithTag(3) as! UILabel!
            
            let friend = self.currentFriends[indexPath.row]
            
            let profileFile = friend["Profile"] as! PFFile
            profileFile.getDataInBackgroundWithBlock { (data, error) -> Void in
                if error == nil {
                    UIView.transitionWithView(personImageView, duration: 0.3, options: .TransitionCrossDissolve, animations: { () -> Void in
                        personImageView.image = UIImage(data: data)
                        }, completion: nil)
                }
            }
            
            personNameView.text = friend["FullName"] as? String
            personUsernameView.text = friend["username"] as? String
            
            cell.backgroundColor = UIColor.clearColor()
            cell.backgroundView = UIView()
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.grayColor()
            cell.selectedBackgroundView = backgroundView
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Friend Request") as! UITableViewCell
            
            let personImageView = cell.viewWithTag(1) as! UIImageView!
            let personNameView = cell.viewWithTag(2) as! UILabel!
            let personUsernameView = cell.viewWithTag(3) as! UILabel!
            let respondToRequestButton = cell.viewWithTag(4) as! UIButton!
            
            respondToRequestButton.addTarget(self, action: "respondToRequest:", forControlEvents: .TouchUpInside)
            
            let request = self.requestedFriends[indexPath.row]
            
            let profileFile = request["Profile"] as! PFFile
            profileFile.getDataInBackgroundWithBlock { (data, error) -> Void in
                if error == nil {
                    UIView.transitionWithView(personImageView, duration: 0.3, options: .TransitionCrossDissolve, animations: { () -> Void in
                        personImageView.image = UIImage(data: data)
                        }, completion: nil)
                }
            }
            
            personNameView.text = request["FullName"] as? String
            personUsernameView.text = request["username"] as? String
            
            cell.backgroundColor = UIColor.clearColor()
            cell.backgroundView = UIView()
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.grayColor()
            cell.selectedBackgroundView = backgroundView
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Unfriend"
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                let friendToDelete = self.currentFriends[indexPath.row]
                
                var friendsQuery = PFQuery(className: "Friends")
                friendsQuery.whereKey("User", equalTo: friendToDelete["username"] as! String)
                let toDeleteFriendObject = friendsQuery.getFirstObject()
                
                friendsQuery = PFQuery(className: "Friends")
                friendsQuery.whereKey("User", equalTo: self.currentUser.username)
                let currentUserFriendObject = friendsQuery.getFirstObject()
                
                var toDeleteFriends = toDeleteFriendObject["Friends"] as! [String]
                var currentUserFriends = currentUserFriendObject["Friends"] as! [String]
                
                for i in 0..<toDeleteFriends.count {
                    if toDeleteFriends[i] == self.currentUser.username {
                        toDeleteFriends.removeAtIndex(i)
                        break
                    }
                }
                
                for i in 0..<currentUserFriends.count {
                    if currentUserFriends[i] == friendToDelete["username"] as! String {
                        currentUserFriends.removeAtIndex(i)
                        break
                    }
                }
                
                toDeleteFriendObject["Friends"] = toDeleteFriends
                currentUserFriendObject["Friends"] = currentUserFriends
                
                toDeleteFriendObject.saveInBackground()
                currentUserFriendObject.saveInBackground()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.currentFriends.removeAtIndex(indexPath.row)
                    self.friendsTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    
                    if self.currentFriends.count == 0 {
                        self.noFriendsView.hidden = false
                        UIView.animateWithDuration(0.25, animations: { () -> Void in
                            self.friendsTable.alpha = 0.0
                            self.noFriendsView.alpha = 1.0
                            }, completion: { (completed) -> Void in
                                self.friendsTable.userInteractionEnabled = false
                                self.friendsTable.hidden = true
                        })
                    }
                })
            })
        }
    }
    
    func updateRequests() {
        // Counts unread incoming payments and badges tab and navigation bar title
        var badgeValue: String? = (requestedFriends.count > 0) ? "\(requestedFriends.count)" : nil
        self.navigationController?.tabBarItem.badgeValue = badgeValue
        self.friendsFilterSegmentedControl.setTitle((requestedFriends.count > 0) ? "Requests (\(requestedFriends.count))" : "Requests", forSegmentAtIndex: 1)
    }
    
    func respondToRequest(sender: UIButton) {
        if let buttonFrameInView = sender.superview?.superview?.convertRect(sender.frame, toView: self.view) {
            sourceButtonFrame = buttonFrameInView
            respondSender = sender
            performSegueWithIdentifier("Respond to Friend Request", sender: sender)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cellFrame = tableView.rectForRowAtIndexPath(indexPath)
        cellFrame.origin.y -= tableView.contentOffset.y
        sourceCellFrame = cellFrame
        performSegueWithIdentifier("Show Friend", sender: indexPath)
    }

    @IBAction func changeFilterMode(sender: AnyObject) {
        switch friendsFilterSegmentedControl.selectedSegmentIndex {
        case 0:
            noFriendsTitle.text = "No Friends"
            noFriendsDescription.text = "Add some by pressing +."
            
            if !friendsLoadingIndicatorView.isAnimating() {
                friendsTable.alpha = currentFriends.count == 0 ? 0.0 : 1.0
                friendsTable.hidden = currentFriends.count == 0
                friendsTable.userInteractionEnabled = currentFriends.count != 0
                noFriendsView.alpha = currentFriends.count == 0 ? 1.0 : 0.0
                noFriendsView.hidden = currentFriends.count != 0
            }
        case 1:
            noFriendsTitle.text = "No Friend Requests"
            noFriendsDescription.text = "Incoming friend requests will appear here."
            
            if !friendsLoadingIndicatorView.isAnimating() {
                friendsTable.alpha = requestedFriends.count == 0 ? 0.0 : 1.0
                friendsTable.hidden = requestedFriends.count == 0
                friendsTable.userInteractionEnabled = requestedFriends.count != 0
                noFriendsView.alpha = requestedFriends.count == 0 ? 1.0 : 0.0
                self.noFriendsView.hidden = requestedFriends.count != 0
            }
        default:
            break
        }
        
        self.friendsTable.reloadData()
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Add Friends" {
            let addFriendsVC = (segue.destinationViewController as! UINavigationController).topViewController as! AddFriendsViewController
            
            addFriendsVC.currentFriends = currentFriends
            addFriendsVC.requestedFriends = requestedFriends
        }
        else if segue.identifier == "Respond to Friend Request" {
            let respondToFriendRequestVC = segue.destinationViewController as! RespondToFriendRequestViewController
            respondToFriendRequestVC.modalPresentationStyle = UIModalPresentationStyle.Custom
            respondToFriendRequestVC.transitioningDelegate = self
            respondToFriendRequestVC.delegate = self
        }
        else if segue.identifier == "Show Friend" {
            let profileVC = segue.destinationViewController as! ProfileViewController
            let indexPath = sender as! NSIndexPath
            
            if friendsFilterSegmentedControl.selectedSegmentIndex == 0 {
                profileVC.user = currentFriends[indexPath.row]
                profileVC.profileType = "Friend"
            }
            else if friendsFilterSegmentedControl.selectedSegmentIndex == 1 {
                profileVC.user = requestedFriends[indexPath.row]
                profileVC.profileType = "Requested Friend"
            }
            
            profileVC.modalPresentationStyle = .Custom
            profileVC.transitioningDelegate = self
        }
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let _ = presented as? ProfileViewController {
            return ExpandCellTransition(presenting: true, sourceCellFrame: sourceCellFrame)
        }
        else if let _ = presented as? RespondToFriendRequestViewController {
            return ExpandButtonTransition(presenting: true, sourceButtonFrame: sourceButtonFrame)
        }
        else {
            return nil
        }
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let _ = dismissed as? ProfileViewController {
            return ExpandCellTransition(presenting: false, sourceCellFrame: sourceCellFrame)
        }
        else if let _ = dismissed as? RespondToFriendRequestViewController {
            return ExpandButtonTransition(presenting: false, sourceButtonFrame: sourceButtonFrame)
        }
        else {
            return nil
        }
    }
    
    func respondedToFriendRequest(response: String) {
        let respondIndicator = respondSender?.superview?.superview?.viewWithTag(5) as! UIActivityIndicatorView
        respondIndicator.startAnimating()
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            respondIndicator.alpha = 1.0
            self.respondSender?.alpha = 0.0
        }) { (completed) -> Void in
            self.respondSender = nil
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            let index = self.friendsTable.indexPathForCell(self.respondSender!.superview?.superview as! UITableViewCell)!.row
            
            var friendsQuery = PFQuery(className: "Friends")
            friendsQuery.whereKey("User", equalTo: self.currentUser.username)
            
            if let friendsCurrentUserObject = friendsQuery.getFirstObject() {
                friendsQuery = PFQuery(className: "Friends")
                friendsQuery.whereKey("User", equalTo: self.requestedFriends[index]["username"] as! String)
                
                if let friendsRequestedUserObject = friendsQuery.getFirstObject() {
                    var friendRequests = friendsCurrentUserObject["Received"] as! [String]
                    friendRequests.removeAtIndex(index)
                    friendsCurrentUserObject["Received"] = friendRequests
                    
                    var requestsSent = friendsRequestedUserObject["Sent"] as! [String]
                    requestsSent.removeAtIndex({ () -> Int in
                        var i = -1
                        for request in requestsSent {
                            i++
                            if request == self.currentUser.username {
                                break
                            }
                        }
                        return i
                    }())
                    friendsRequestedUserObject["Sent"] = requestsSent
                    
                    if (response == "Accepted") {
                        var currentUserFriends = friendsCurrentUserObject["Friends"] as! [String]
                        currentUserFriends.insert(friendsRequestedUserObject["User"] as! String, atIndex: 0)
                        friendsCurrentUserObject["Friends"] = currentUserFriends
                        
                        var requestUserFriends = friendsRequestedUserObject["Friends"] as! [String]
                        requestUserFriends.insert(friendsCurrentUserObject["User"] as! String, atIndex: 0)
                        friendsRequestedUserObject["Friends"] = requestUserFriends
                        
                        self.currentFriends.insert(self.requestedFriends[index], atIndex: 0)
                    }
                    
                    friendsCurrentUserObject.save()
                    friendsRequestedUserObject.save()
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.requestedFriends.removeAtIndex(index)
                        
                        if self.requestedFriends.count == 0 {
                            self.noFriendsView.hidden = false
                            UIView.animateWithDuration(0.25, animations: { () -> Void in
                                self.friendsTable.alpha = 0.0
                                self.noFriendsView.alpha = 1.0
                                }, completion: { (completed) -> Void in
                                    self.friendsTable.userInteractionEnabled = false
                                    self.friendsTable.hidden = true
                            })
                        }
                        
                        self.friendsTable.deleteRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: .Automatic)
                        
                        self.updateRequests()
                    })
                }
            }
        })
    }

}
