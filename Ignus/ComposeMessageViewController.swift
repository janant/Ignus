//
//  ComposeMessageViewController.swift
//  
//
//  Created by Anant Jain on 7/27/15.
//
//

import UIKit

protocol ComposeMessageViewControllerDelegate {
    func canceledNewMessage()
    func sentNewMessage()
}

class ComposeMessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChooseFriendViewControllerDelegate, UITextViewDelegate {
    
    @IBOutlet weak var selectRecipientTable: UITableView!
    
    @IBOutlet weak var sendButton: UIBarButtonItem!
    
    let currentUser = PFUser.currentUser()
    
    // The dark transparent UIView that displays under this view controller
    var shadowView: UIView?
    
    // The message text view
    var messageTextView: UITextView?
    
    var delegate: ComposeMessageViewControllerDelegate?
    
    var recipient: PFObject?
    var recipientLabel: UILabel?
    
    var isReply = false
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        // Deselects the currently selected table view cell
        if let selectedIndexPath = selectRecipientTable.indexPathForSelectedRow() {
            selectRecipientTable.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Disables send button
        sendButton.enabled = false
        
        // Adds blur separator effect
        selectRecipientTable.separatorEffect = UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark))
        
        if isReply {
            self.navigationItem.leftBarButtonItem = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelMessage(sender: AnyObject) {
        self.delegate?.canceledNewMessage()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendMessage(sender: AnyObject) {
        // Creates, configures, and saves message object
        let newMessageObject = PFObject(className: "Messages")
        newMessageObject["Sender"] = currentUser.username
        newMessageObject["Receiver"] = recipient!["username"]
        newMessageObject["Unread"] = true
        newMessageObject["Message"] = messageTextView?.text
        newMessageObject.saveInBackgroundWithBlock { (completed, error) -> Void in
            if error != nil {
                let errorAlert = UIAlertController(title: "Message failed to send", message: error.localizedDescription, preferredStyle: .Alert)
                errorAlert.addAction(UIAlertAction(title: "Done", style: .Default, handler: nil))
                self.presentViewController(errorAlert, animated: true, completion: nil)
            }
        }
        
        self.delegate?.sentNewMessage()
        
        if !isReply {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: - Table view data source methods

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("Select Recipient Cell", forIndexPath: indexPath) as! UITableViewCell
            
            if recipient != nil {
                cell.detailTextLabel?.text = recipient!["username"] as? String
                cell.userInteractionEnabled = false
                cell.accessoryType = .None
            }
            
            // Configures selection highlight color
            let selectedView = UIView()
            selectedView.backgroundColor = UIColor.grayColor()
            cell.selectedBackgroundView = selectedView
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Write Message Cell", forIndexPath: indexPath) as! UITableViewCell
            
            messageTextView = cell.viewWithTag(1) as? UITextView
            
            messageTextView?.becomeFirstResponder()
            
            // Sets text inset
            messageTextView?.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            
            return cell
        }
        
    }
    
    // MARK: - Table view delegate methods
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 44
        }
        else {
            return 157
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            performSegueWithIdentifier("Select Recipient", sender: nil)
        }
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Select Recipient" {
            let chooseFriendVC = segue.destinationViewController as! ChooseFriendViewController
            chooseFriendVC.delegate = self
        }
    }
    
    // MARK: - ChooseFriendViewControllerDelegate methods
    
    func choseFriend(friend: PFObject) {
        recipient = friend
        selectRecipientTable.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!.detailTextLabel?.text = friend["username"] as? String
        
        // Enables text field if conditions are met
        sendButton.enabled = count(messageTextView!.text) != 0 && recipient != nil
    }
    
    // MARK: - Text view delegate methods
    
    func textViewDidChange(textView: UITextView) {
        // Enables and disables send button depending on conditions
        sendButton.enabled = count(messageTextView!.text) != 0 && recipient != nil
    }
}
