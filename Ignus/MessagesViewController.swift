//
//  MessagesViewController.swift
//  Ignus
//
//  Created by Anant Jain on 3/20/15.
//  Copyright (c) 2015 Anant Jain. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController, UIViewControllerTransitioningDelegate, ComposeMessageViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, ViewMessageViewControllerDelegate {
    
    
    @IBOutlet weak var messagesTable: UITableView!
    
    @IBOutlet weak var noMessagesView: UIView!
    @IBOutlet weak var loadingMessagesActivityIndicator: UIActivityIndicatorView!
    
    var unreadMessages = 0
    
    let refreshControl = UIRefreshControl()
    
    var dismissComposeTransition: UIViewControllerAnimatedTransitioning?
    
    var currentUser = PFUser.currentUser()
    
    var messages = [PFObject]()
    var senders = [PFObject]()
    
    var sourceCellFrame = CGRect()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Deselects selected index
        if let selectedIndex = messagesTable.indexPathForSelectedRow() {
            messagesTable.deselectRowAtIndexPath(selectedIndex, animated: true)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        loadingMessagesActivityIndicator.startAnimating();
        
        messagesTable.separatorEffect = UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark))
        refreshControl.addTarget(self, action: "reloadData", forControlEvents: .ValueChanged)
        refreshControl.tintColor = UIColor.whiteColor()
        messagesTable.addSubview(refreshControl)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            let messagesQuery = PFQuery(className: "Messages")
            messagesQuery.whereKey("Receiver", equalTo: self.currentUser.username)
            if let loadedMessages = messagesQuery.findObjects() as? [PFObject] {
                self.messages = loadedMessages
            }
            
            for message in self.messages {
                let senderQuery = PFUser.query()
                senderQuery.whereKey("username", equalTo: message["Sender"])
                self.senders.append(senderQuery.getFirstObject())
            }
            
            self.sortMessagesAndSenders(messages: &self.messages, senders: &self.senders)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.updateUnreadMessages()
                self.messagesTable.reloadData()
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.loadingMessagesActivityIndicator.alpha = 0.0
                    if self.messages.count == 0 {
                        self.noMessagesView.alpha = 1.0
                        self.messagesTable.hidden = true
                    }
                    else {
                        self.messagesTable.alpha = 1.0
                        self.noMessagesView.hidden = true
                    }
                    }, completion: { (completed) -> Void in
                        self.loadingMessagesActivityIndicator.stopAnimating()
                        self.loadingMessagesActivityIndicator.hidden = true
                    }
                )
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sortMessagesAndSenders(inout #messages: [PFObject], inout senders: [PFObject]) {
        var groupedArray = [(PFObject, PFObject)]()
        
        for i in 0..<messages.count {
            groupedArray.append((messages[i], senders[i]))
        }
        
        let sortedArray = sorted(groupedArray, { $0.0.createdAt.timeIntervalSinceDate($1.0.createdAt) > 0 })
        
        var newMessages = [PFObject]()
        var newSenders = [PFObject]()
        
        for message in sortedArray {
            newMessages.append(message.0)
            newSenders.append(message.1)
        }
        
        messages = newMessages
        senders = newSenders
    }
    
    func updateUnreadMessages() {
        // Counts unread messages and badges tab and navigation bar title
        unreadMessages = 0
        for message in self.messages {
            if message["Unread"] as! Bool {
                unreadMessages++
            }
        }
        
        var badgeValue: String? = (unreadMessages > 0) ? "\(unreadMessages)" : nil
        self.navigationController?.tabBarItem.badgeValue = badgeValue
        self.navigationItem.title = (unreadMessages > 0) ? "Messages (\(unreadMessages))" : "Messages"
    }
    
    func reloadData() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            
            let messagesQuery = PFQuery(className: "Messages")
            messagesQuery.whereKey("Receiver", equalTo: self.currentUser.username)
            if let loadedMessages = messagesQuery.findObjects() as? [PFObject] {
                self.messages = loadedMessages
                
                self.senders = [PFObject]()
                
                for message in self.messages {
                    let senderQuery = PFUser.query()
                    senderQuery.whereKey("username", equalTo: message["Sender"])
                    self.senders.append(senderQuery.getFirstObject())
                }
                
                self.sortMessagesAndSenders(messages: &self.messages, senders: &self.senders)
                
                // Hides or shows the table view and other related views if the user has any friends/requests.
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.updateUnreadMessages()
                    if (self.refreshControl.refreshing) {
                        self.refreshControl.endRefreshing()
                    }
                    
                    self.messagesTable.hidden = false
                    self.noMessagesView.hidden = false
                    
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.loadingMessagesActivityIndicator.alpha = 0.0
                        if self.messages.count == 0 {
                            self.noMessagesView.alpha = 1.0
                            self.messagesTable.hidden = true
                        }
                        else {
                            self.messagesTable.alpha = 1.0
                            self.noMessagesView.hidden = true
                        }
                        }, completion: { (completed) -> Void in
                            self.loadingMessagesActivityIndicator.stopAnimating()
                            self.loadingMessagesActivityIndicator.hidden = true
                            
                            if self.messages.count == 0 {
                                self.messagesTable.hidden = true
                            }
                            else {
                                self.noMessagesView.hidden = true
                            }
                        }
                    )

                    self.messagesTable.reloadData()
                })
            }
        })
    }
    
    // MARK: - Transition delegate methods
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let navVC = presented as? UINavigationController {
            if navVC.topViewController is ComposeMessageViewController {
                return ComposeTransition(presenting: true)
            }
            else if navVC.topViewController is ViewMessageViewController {
                return ViewMessageTransition(presenting: true, sourceCellFrame: sourceCellFrame)
            }
        }
        
        return nil
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return dismissComposeTransition
    }
    
    // MARK: - ComposeMessageViewControllerDelegate methods
    
    func canceledNewMessage() {
        dismissComposeTransition = ComposeTransition(presenting: false, messageSent: false)
    }
    
    func sentNewMessage() {
        dismissComposeTransition = ComposeTransition(presenting: false, messageSent: true)
    }
    
    // MARK: - ViewMessageViewControllerDelegate methods
    
    func canceledReply() {
        dismissComposeTransition = ViewMessageTransition(presenting: false, sourceCellFrame: sourceCellFrame, messageSent: false)
        
        self.viewDidAppear(true)
    }
    
    func sentReply() {
        dismissComposeTransition = ViewMessageTransition(presenting: false, sourceCellFrame: sourceCellFrame, messageSent: true)
        
        self.viewDidAppear(true)
    }
    
    // MARK: - Table view data source methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Message Cell", forIndexPath: indexPath) as! UITableViewCell
        
        let messageObject = messages[indexPath.row]
        let senderObject = senders[indexPath.row]
        
        let profileImageView = cell.viewWithTag(1) as! UIImageView
        let nameLabel = cell.viewWithTag(2) as! UILabel
        let messageLabel = cell.viewWithTag(3) as! UILabel
        let unreadIndicator = cell.viewWithTag(4)!
        let dateLabel = cell.viewWithTag(5) as! UILabel
                
        let profileFile = senderObject["Profile"] as! PFFile
        profileFile.getDataInBackgroundWithBlock { (data, error) -> Void in
            if error == nil {
                UIView.transitionWithView(profileImageView, duration: 0.3, options: .TransitionCrossDissolve, animations: { () -> Void in
                    profileImageView.image = UIImage(data: data)
                }, completion: nil)
            }
        }
        
        nameLabel.text = senderObject["FullName"] as? String
        messageLabel.text = messageObject["Message"] as? String
        unreadIndicator.hidden = !(messageObject["Unread"] as! Bool)
        
        let messageDate = messageObject.createdAt
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = (NSCalendar.currentCalendar().isDateInToday(messageDate)) ? "h:mm a" : "MM/dd/yy"
        dateLabel.text = dateFormatter.stringFromDate(messageDate)
        
        cell.backgroundColor = UIColor.clearColor()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.grayColor()
        cell.selectedBackgroundView = backgroundView
        
        return cell
    }
    
    // MARK: - Table view delegate methods
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cellFrame = tableView.rectForRowAtIndexPath(indexPath)
        cellFrame.origin.y -= tableView.contentOffset.y
        sourceCellFrame = cellFrame
        
        // Hides the new message indicator
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        selectedCell?.viewWithTag(4)?.hidden = true
        
        // Saves to the server that the message was read
        let selectedMessage = messages[indexPath.row]
        if selectedMessage["Unread"] as! Bool {
            selectedMessage["Unread"] = false
            selectedMessage.saveInBackground()
            
            updateUnreadMessages()
        }
        
        
        performSegueWithIdentifier("View Message", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Removes and deletes the message
            let messageToDelete = messages.removeAtIndex(indexPath.row)
            messageToDelete.deleteInBackground()
            
            // Removes the sender from the user list
            senders.removeAtIndex(indexPath.row)
            
            // Removes the table cell from the table with animation
            messagesTable.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
            updateUnreadMessages()
            
            // Shows that there are no messages if the last message is deleted
            if messages.count == 0 {
                // Configures views for animation
                noMessagesView.alpha = 0.0
                noMessagesView.hidden = false
                
                // Animates
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.noMessagesView.alpha = 1.0
                    self.messagesTable.alpha = 0.0
                }, completion: { (completed) -> Void in
                    self.messagesTable.hidden = true
                })
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Compose" {
            let navVC = segue.destinationViewController as! UINavigationController
            navVC.modalPresentationStyle = .Custom
            navVC.transitioningDelegate = self
            
            let composeMessageVC = navVC.topViewController as! ComposeMessageViewController
            composeMessageVC.delegate = self
        }
        else if segue.identifier == "View Message" {
            let navVC = segue.destinationViewController as! UINavigationController
            navVC.modalPresentationStyle = .Custom
            navVC.transitioningDelegate = self
            
            let selectedIndex = sender as! NSIndexPath
            
            let viewMessageVC = navVC.topViewController as! ViewMessageViewController
            viewMessageVC.messageObject = messages[selectedIndex.row]
            viewMessageVC.senderObject = senders[selectedIndex.row]
            viewMessageVC.delegate = self
        }
    }

}
