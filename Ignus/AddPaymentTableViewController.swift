//
//  AddPaymentTableViewController.swift
//  Ignus
//
//  Created by Anant Jain on 2/8/15.
//  Copyright (c) 2015 Anant Jain. All rights reserved.
//

import UIKit

protocol AddPaymentTableViewControllerDelegate {
    func addedPayment(payment: PFObject, user: PFObject)
    func canceledPayment()
}

class AddPaymentTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, ChooseFriendViewControllerDelegate {
    
    @IBOutlet weak var selectedFriendIndicator: UILabel!
    @IBOutlet weak var moneyPickerView: UIPickerView!
    @IBOutlet weak var memoTextView: UITextView!
    
    
    @IBOutlet weak var selectFriendCell: UITableViewCell!
    @IBOutlet weak var amountOwedCell: UITableViewCell!
    @IBOutlet weak var memoCell: UITableViewCell!
    
    var shadowView: UIView?
    
    var delegate: AddPaymentTableViewControllerDelegate?
    
    var friend: PFObject?
    let currentUser = PFUser.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.grayColor()
        selectFriendCell.selectedBackgroundView = selectedView
        
        if friend != nil {
            selectFriendCell.userInteractionEnabled = false
            selectFriendCell.accessoryType = .None
            self.choseFriend(friend!)
        }
        
        amountOwedCell.backgroundView = nil
        
        memoCell.backgroundView = nil
        
        memoTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
    
    // MARK: - Picker view data source methods
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 100
    }
    
    // MARK: - Picker view delegate methods
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var title = String()
        
        switch component {
        case 0:
            title = "$\(row)."
        case 1:
            title = row < 10 ? "0\(row)" : String(row)
        default:
            break
        }
        return NSAttributedString(string: title, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Gotham-Book", size: 16)!])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view delegate methods
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel.font = UIFont(name: "Gotham-Book", size: 13)
    }
    
    @IBAction func cancelAddPayment(sender: AnyObject) {
        self.delegate?.canceledPayment()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addPayment(sender: AnyObject) {
        let doneButton = self.navigationItem.rightBarButtonItem
        let addingPaymentIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        addingPaymentIndicator.startAnimating()
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(customView: addingPaymentIndicator), animated: true)
        
        var errorAlert: UIAlertController?
        
        if friend == nil {
            errorAlert = UIAlertController(title: "Error", message: "Please select a friend who owes you money.", preferredStyle: .Alert)
            errorAlert!.addAction(UIAlertAction(title: "Done", style: .Default, handler: nil))
        }
        else if moneyPickerView.selectedRowInComponent(0) == 0 && moneyPickerView.selectedRowInComponent(1) == 0 {
            errorAlert = UIAlertController(title: "Error", message: "Please enter a valid amount owed.", preferredStyle: .Alert)
            errorAlert!.addAction(UIAlertAction(title: "Done", style: .Default, handler: nil))
        }
        
        if errorAlert != nil {
            self.navigationItem.setRightBarButtonItem(doneButton, animated: true)
            presentViewController(errorAlert!, animated: true, completion: nil)
        }
        else {
            // Creates, configures, and saves new Payments object
            let newPayment = PFObject(className: "Payments")
            newPayment["Receiver"] = currentUser.username
            newPayment["Sender"] = friend!["username"] as! String
            newPayment["Currency"] = "USD"
            newPayment["Paid"] = false
            newPayment["Unread"] = true
            newPayment["Memo"] = memoTextView.text
            newPayment["Rating"] = "Undecided"
            
            let choice = moneyPickerView.selectedRowInComponent(1)
            let decimal = choice >= 10 ? "\(choice)" : ("0" + "\(choice)")
            newPayment["MoneyOwed"] = "\(moneyPickerView.selectedRowInComponent(0))" + "." + decimal
            
            newPayment.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                if error == nil {
                    self.delegate?.addedPayment(newPayment, user: self.friend!)
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
                else {
                    self.navigationItem.setRightBarButtonItem(doneButton, animated: true)
                    let errorAlert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
                    errorAlert.addAction(UIAlertAction(title: "Done", style: .Default, handler: nil))
                    self.presentViewController(errorAlert, animated: true, completion: nil)
                }
            })
        }
    }
    
    // MARK: - ChooseFriendViewControllerDelegate methods
    
    func choseFriend(friend: PFObject) {
        self.friend = friend
        self.selectedFriendIndicator.text = friend["username"] as? String
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Choose Friend" {
            let chooseFriendVC = segue.destinationViewController as! ChooseFriendViewController
            chooseFriendVC.delegate = self
            chooseFriendVC.navigationItem.title = "Friends"
        }
    }
}
