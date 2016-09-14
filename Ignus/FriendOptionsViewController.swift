//
//  FriendOptionsViewController.swift
//  Ignus
//
//  Created by Anant Jain on 3/26/15.
//  Copyright (c) 2015 Anant Jain. All rights reserved.
//

import UIKit

@objc protocol FriendOptionsViewControllerDelegate {
    func changeProfilePicture()
    func changeCoverPhoto()
    optional func sentFriendRequest()
    optional func respondedToFriendRequest(response: String)
    optional func canceledFriendRequest()
    optional func requestPayment()
    optional func message()
    optional func writeReview()
    optional func unfriended()
    optional func report()
}

class FriendOptionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var responseTable: UITableView!
    
    var delegate: FriendOptionsViewControllerDelegate?

    var darkView = UIView()
    
    var profileType: String?
    
    var user: PFObject?
    let currentUser = PFUser.currentUser()
    
    var scrollEnabled = false {
        didSet {
            responseTable.scrollEnabled = scrollEnabled
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        responseTable.separatorEffect = UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Light))
        responseTable.scrollEnabled = scrollEnabled
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch profileType! {
        case "Current User":
            return 2
        case "Friend":
            return 4
        case "User":
            return 1
        case "Pending Friend":
            return 1
        case "Requested Friend":
            return 2
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Response Cell") as! UITableViewCell
        
        cell.textLabel?.textColor = UIColor.whiteColor()
        
        switch profileType! {
        case "Current User":
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Change Profile\nPicture"
            case 1:
                cell.textLabel?.text = "Change Cover\nPhoto"
            default:
                break
            }
        case "Friend":
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Message"
            case 1:
                cell.textLabel?.text = "Request Payment"
            case 2:
                cell.textLabel?.text = "Write Review"
            case 3:
                cell.textLabel?.text = "Unfriend"
            default:
                break
            }
        case "User":
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Send Friend\nRequest"
            default:
                break
            }
        case "Pending Friend":
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Cancel Friend\nRequest"
            default:
                break
            }
        case "Requested Friend":
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Accept Friend\nRequest"
                cell.textLabel?.textColor = UIColor.greenColor()
            case 1:
                cell.textLabel?.text = "Decline Friend\nRequest"
                cell.textLabel?.textColor = UIColor.redColor()
            default:
                break
            }
        default:
            break
        }
        
        cell.backgroundColor = UIColor.clearColor()
        cell.backgroundView = nil
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 0.7)
        cell.selectedBackgroundView = selectedView
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.userInteractionEnabled = false
        
        if profileType == "Current User" {
            if indexPath.row == 0 {
                self.dismissViewControllerAnimated(true, completion: {(completed) -> Void in
                    if let delegate = self.delegate {
                        delegate.changeProfilePicture()
                    }
                })
            }
            else if indexPath.row == 1 {
                self.dismissViewControllerAnimated(true, completion: {(completed) -> Void in
                    if let delegate = self.delegate {
                        delegate.changeCoverPhoto()
                    }
                })
            }

        }
        else if profileType == "Friend" {
            if indexPath.row == 0 { // Message
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.delegate?.message!()
                })
            }
            else if indexPath.row == 1 { // Request payment
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.delegate?.requestPayment!()
                })
            }
            else if indexPath.row == 2 { // Write review
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.delegate?.writeReview!()
                })
            }
            else if indexPath.row == 3 { // Unfriend
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                    self.unfriend()
                    NSNotificationCenter.defaultCenter().postNotificationName("Reload Friends", object: nil)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.dismissViewControllerAnimated(true, completion: {(completed) -> Void in
                            if let delegate = self.delegate {
                                delegate.unfriended!()
                            }
                        })
                    })
                })
            }
        }
        else if profileType == "User" {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                self.sendFriendRequest()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.dismissViewControllerAnimated(true, completion: {(completed) -> Void in
                        if let delegate = self.delegate {
                            delegate.sentFriendRequest!()
                        }
                    })
                })
            })
        }
        else if profileType == "Pending Friend" {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                self.cancelFriendRequest()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.dismissViewControllerAnimated(true, completion: {(completed) -> Void in
                        if let delegate = self.delegate {
                            delegate.canceledFriendRequest!()
                        }
                    })
                })
            })
        }
        else if profileType == "Requested Friend" {
            if indexPath.row == 0 {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                    self.respondToFriendRequest("Accepted")
                    NSNotificationCenter.defaultCenter().postNotificationName("Reload Friends", object: nil)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.dismissViewControllerAnimated(true, completion: {(completed) -> Void in
                            if let delegate = self.delegate {
                                delegate.respondedToFriendRequest!("Accepted")
                            }
                        })
                    })
                })
            }
            else if indexPath.row == 1 {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
                    self.respondToFriendRequest("Declined")
                    NSNotificationCenter.defaultCenter().postNotificationName("Reload Friends", object: nil)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.dismissViewControllerAnimated(true, completion: {(completed) -> Void in
                            if let delegate = self.delegate {
                                delegate.respondedToFriendRequest!("Declined")
                            }
                        })
                    })
                })
            }
        }
    }
    
    func sendFriendRequest() {
        var currentUserFriendQuery = PFQuery(className: "Friends")
        currentUserFriendQuery.whereKey("User", equalTo: self.currentUser.username)
        let currentUserFriendObject = currentUserFriendQuery.getFirstObject()
        
        currentUserFriendQuery = PFQuery(className: "Friends")
        currentUserFriendQuery.whereKey("User", equalTo: self.user!["username"])
        let otherUserFriendObject = currentUserFriendQuery.getFirstObject()
        
        var currentUserSentRequests = currentUserFriendObject["Sent"] as! [String]
        currentUserSentRequests.insert(otherUserFriendObject["User"] as! String, atIndex: 0)
        currentUserFriendObject["Sent"] = currentUserSentRequests
        
        var otherUserReceivedRequests = otherUserFriendObject["Received"] as! [String]
        otherUserReceivedRequests.insert(currentUserFriendObject["User"] as! String, atIndex: 0)
        otherUserFriendObject["Received"] = otherUserReceivedRequests
        
        currentUserFriendObject.save()
        otherUserFriendObject.save()
    }
    
    func unfriend() {
        var friendsQuery = PFQuery(className: "Friends")
        friendsQuery.whereKey("User", equalTo: user!["username"] as! String)
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
            if currentUserFriends[i] == user!["username"] as! String {
                currentUserFriends.removeAtIndex(i)
                break
            }
        }
        
        toDeleteFriendObject["Friends"] = toDeleteFriends
        currentUserFriendObject["Friends"] = currentUserFriends
        
        toDeleteFriendObject.save()
        currentUserFriendObject.save()
    }
    
    func respondToFriendRequest(response: String) {
        var friendsQuery = PFQuery(className: "Friends")
        friendsQuery.whereKey("User", equalTo: user!["username"] as! String)
        let friendsRequestedUserObject = friendsQuery.getFirstObject()
        
        friendsQuery = PFQuery(className: "Friends")
        friendsQuery.whereKey("User", equalTo: self.currentUser.username)
        let friendsCurrentUserObject = friendsQuery.getFirstObject()
        
        var friendRequests = friendsCurrentUserObject["Received"] as! [String]
        friendRequests.removeAtIndex({ () -> Int in
            var i = -1
            for request in friendRequests {
                i++
                if request == self.user!["username"] as! String {
                    break
                }
            }
            return i
            }())

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
        }
        
        friendsCurrentUserObject.save()
        friendsRequestedUserObject.save()
    }
    
    func cancelFriendRequest() {
        var friendsQuery = PFQuery(className: "Friends")
        friendsQuery.whereKey("User", equalTo: user!["username"] as! String)
        let friendsRequestedUserObject = friendsQuery.getFirstObject()
        
        friendsQuery = PFQuery(className: "Friends")
        friendsQuery.whereKey("User", equalTo: self.currentUser.username)
        let friendsCurrentUserObject = friendsQuery.getFirstObject()
        
        var friendRequests = friendsCurrentUserObject["Sent"] as! [String]
        friendRequests.removeAtIndex({ () -> Int in
            var i = -1
            for request in friendRequests {
                i++
                if request == self.user!["username"] as! String {
                    break
                }
            }
            return i
            }())
        
        friendsCurrentUserObject["Sent"] = friendRequests
        
        var requestsSent = friendsRequestedUserObject["Received"] as! [String]
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
        friendsRequestedUserObject["Received"] = requestsSent
        
        friendsCurrentUserObject.save()
        friendsRequestedUserObject.save()
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }

}
