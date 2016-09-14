//
//  PaymentInfoTableViewController.swift
//  Ignus
//
//  Created by Anant Jain on 2/8/15.
//  Copyright (c) 2015 Anant Jain. All rights reserved.
//

import UIKit

protocol PaymentInfoTableViewControllerDelegate {
    func deletePayment()
    func completePayment()
    func closePaymentInfo()
}

class PaymentInfoTableViewController: UITableViewController, RatePaymentTableViewControllerDelegate {
    
    var payment: PFObject!
    var user: PFObject!
    
    enum RequestStyle {
        case MyRequest, Incoming
    }
    
    var paymentType: RequestStyle!
    
    var memoExists = true
    
    var shadowView: UIView?
    
    var delegate: PaymentInfoTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        if (payment["Memo"] as! String) == "" {
            memoExists = false
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closePaymentInfo(sender: AnyObject) {
        delegate?.closePaymentInfo()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismiss() {
        closePaymentInfo(self.shadowView!)
    }
    
    // MARK: - Table view data source methods
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        switch paymentType! {
        case .MyRequest:
            return memoExists ? 3 : 2
        case .Incoming:
            return memoExists ? 2 : 1
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch paymentType! {
        case .MyRequest:
            switch section {
            case 0:
                return 3
            case 1:
                return memoExists ? 1 : 2
            case 2:
                return 2
            default:
                return 0
            }
        case .Incoming:
            switch section {
            case 0:
                return 3
            case 1:
                return memoExists ? 1 : 0
            default:
                return 0
            }
        default:
            return 0
        }
    }
        
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCellWithIdentifier("Friend Cell", forIndexPath: indexPath) as! UITableViewCell
                
                let personImageView = cell.viewWithTag(1) as! UIImageView!
                let personNameView = cell.viewWithTag(2) as! UILabel!
                let personUsernameView = cell.viewWithTag(3) as! UILabel!
                
                let profileFile = user["Profile"] as! PFFile
                profileFile.getDataInBackgroundWithBlock { (data, error) -> Void in
                    if error == nil {
                        UIView.transitionWithView(personImageView, duration: 0.3, options: .TransitionCrossDissolve, animations: { () -> Void in
                            personImageView.image = UIImage(data: data)
                            }, completion: nil)
                    }
                }
                
                personNameView.text = user["FullName"] as? String
                personUsernameView.text = user["username"] as? String
                
                let backgroundView = UIView()
                backgroundView.backgroundColor = UIColor.grayColor()
                cell.selectedBackgroundView = backgroundView
            }
            else if indexPath.row == 1 {
                cell = tableView.dequeueReusableCellWithIdentifier("Info Cell", forIndexPath: indexPath) as! UITableViewCell
                
                if paymentType == .MyRequest {
                    cell.textLabel?.text = "Owes me:"
                }
                else if paymentType == .Incoming {
                    cell.textLabel?.text = "Needs:"
                }
                
                cell.detailTextLabel?.text = "$" + (payment["MoneyOwed"] as! String)
            }
            else if indexPath.row == 2 {
                cell = tableView.dequeueReusableCellWithIdentifier("Info Cell", forIndexPath: indexPath) as! UITableViewCell
                
                cell.textLabel?.text = "Requested on:"
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy h:mm a"
                cell.detailTextLabel?.text = dateFormatter.stringFromDate(payment.createdAt)
            }
        }
        else if indexPath.section == 1 {
            if memoExists {
                cell = tableView.dequeueReusableCellWithIdentifier("Memo Cell", forIndexPath: indexPath) as! UITableViewCell
                
                let memoTextView = cell.viewWithTag(1) as! UITextView
                memoTextView.text = payment["Memo"] as? String
                
                memoTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            }
            else {
                cell = tableView.dequeueReusableCellWithIdentifier("Button Cell", forIndexPath: indexPath) as! UITableViewCell
                
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Complete Request"
                    cell.textLabel?.textColor = UIColor.whiteColor()
                }
                else if indexPath.row == 1 {
                    cell.textLabel?.text = "Delete Request"
                    cell.textLabel?.textColor = UIColor(red: 1.0, green: 82 / 255.0, blue: 72 / 255.0, alpha: 1.0)
                }
                
                let backgroundView = UIView()
                backgroundView.backgroundColor = UIColor.grayColor()
                cell.selectedBackgroundView = backgroundView
            }
        }
        else if indexPath.section == 2 {
            cell = tableView.dequeueReusableCellWithIdentifier("Button Cell", forIndexPath: indexPath) as! UITableViewCell
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Complete Request"
                cell.textLabel?.textColor = UIColor.whiteColor()
            }
            else if indexPath.row == 1 {
                cell.textLabel?.text = "Delete Request"
                cell.textLabel?.textColor = UIColor(red: 1.0, green: 82 / 255.0, blue: 72 / 255.0, alpha: 1.0)
            }
            
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor.grayColor()
            cell.selectedBackgroundView = backgroundView
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Payment Info"
        case 1:
            return memoExists ? "Memo" : nil
        default:
            return nil
        }
    }
    
    // MARK: - Table view delegate methods
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel.font = UIFont(name: "Gotham-Book", size: 13)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if indexPath.row == 0 {
                return 64
            }
            else {
                return 44
            }
        case 1:
            if memoExists {
                return 74
            }
            else {
                return 44
            }
        case 2:
            return 44
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 1:
            if !memoExists {
                switch indexPath.row {
                case 0:
                    performSegueWithIdentifier("Rate Payment", sender: nil)
                    break
                case 1:
                    let confirmationActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
                    confirmationActionSheet.addAction(UIAlertAction(title: "Delete Request", style: .Destructive, handler: { (alertAction) -> Void in
                        self.delegate?.deletePayment()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }))
                    confirmationActionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (alertAction) -> Void in
                        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                    }))
                    presentViewController(confirmationActionSheet, animated: true, completion: nil)
                default:
                    break
                }
            }
        case 2:
            switch indexPath.row {
            case 0:
                performSegueWithIdentifier("Rate Payment", sender: nil)
                break
            case 1:
                let confirmationActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
                confirmationActionSheet.addAction(UIAlertAction(title: "Delete Request", style: .Destructive, handler: { (alertAction) -> Void in
                    self.delegate?.deletePayment()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }))
                confirmationActionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (alertAction) -> Void in
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }))
                presentViewController(confirmationActionSheet, animated: true, completion: nil)
            default:
                break
            }
        default:
            break
        }
    }
    
    // MARK: - RatePaymentTableViewControllerDelegate methods
    
    func finishedRating(#rating: String) {
        payment["Rating"] = rating
        payment["Unread"] = false
        payment.saveInBackground()
        
        self.delegate?.completePayment()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Rate Payment" {
            let ratePaymentTVC = segue.destinationViewController as! RatePaymentTableViewController
            ratePaymentTVC.delegate = self
        }
        else if segue.identifier == "Show Friend" {
            let profileVC = segue.destinationViewController as! ProfileViewController
            profileVC.profileType = "Friend"
            profileVC.user = self.user
        }
    }
}
