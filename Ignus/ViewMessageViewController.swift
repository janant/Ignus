//
//  ViewMessageViewController.swift
//  
//
//  Created by Anant Jain on 7/28/15.
//
//

import UIKit

protocol ViewMessageViewControllerDelegate {
    func canceledReply()
    func sentReply()
}

class ViewMessageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ComposeMessageViewControllerDelegate {
    
    @IBOutlet weak var viewMessageTable: UITableView!
    
    // Sender and message objects
    var messageObject: PFObject?
    var senderObject: PFObject?
    
    var delegate: ViewMessageViewControllerDelegate?
    
    // The dark transparent UIView that displays under this view controller
    var shadowView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Adds blur separator effect
        viewMessageTable.separatorEffect = UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark))
        
        // Sets navigation bar title to the first name of the sender
        self.navigationItem.title = senderObject?["FirstName"] as? String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeReply(sender: AnyObject) {
        self.delegate?.canceledReply()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - ComposeMessageViewControllerDelegate methods
    func canceledNewMessage() {
    }
    
    func sentNewMessage() {
        self.delegate?.sentReply()
        dismissViewControllerAnimated(true, completion: nil)
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
            let cell = tableView.dequeueReusableCellWithIdentifier("Sender Cell", forIndexPath: indexPath) as! UITableViewCell
            
            cell.textLabel?.text = "From: " + (senderObject?["username"] as! String)
            
            let messageDate = messageObject!.createdAt
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy h:mm a"
            cell.detailTextLabel?.text = dateFormatter.stringFromDate(messageDate)
            
            // Configures selection highlight color
            let selectedView = UIView()
            selectedView.backgroundColor = UIColor.grayColor()
            cell.selectedBackgroundView = selectedView
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier("Message Cell", forIndexPath: indexPath) as! UITableViewCell
            
            let messageTextView = cell.viewWithTag(1) as? UITextView
            messageTextView?.text = messageObject?["Message"] as? String
            
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
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Reply" {
            let composeMessageVC = segue.destinationViewController as! ComposeMessageViewController
            composeMessageVC.recipient = senderObject
            composeMessageVC.delegate = self
            composeMessageVC.isReply = true
        }
    }

}
