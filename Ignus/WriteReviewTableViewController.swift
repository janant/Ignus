//
//  AddPaymentTableViewController.swift
//  Ignus
//
//  Created by Anant Jain on 2/8/15.
//  Copyright (c) 2015 Anant Jain. All rights reserved.
//

import UIKit

protocol WriteReviewTableViewControllerDelegate {
    func canceledWriteReview()
    func wroteReview(#review: PFObject, writer: PFObject)
}

class WriteReviewTableViewController: UITableViewController, UITextViewDelegate {
    
    @IBOutlet weak var starRatingView: HCSStarRatingView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var delegate: WriteReviewTableViewControllerDelegate?
    
    var shadowView: UIView?
    
    var user: PFObject?
    let currentUser = PFUser.currentUser()
    var review: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        titleTextField.attributedPlaceholder = NSAttributedString(string: "Title (optional)", attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()])
        
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        descriptionTextView.delegate = self
        
        if review != nil {
            starRatingView.value = CGFloat(review!["Rating"] as! Int)
            titleTextField.text = review!["Title"] as! String
            descriptionTextView.text = review!["Description"] as! String
        }
        else {
            descriptionTextView.text = "Description"
            descriptionTextView.textColor = UIColor.lightGrayColor()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelWriteReview(sender: AnyObject) {
        self.delegate?.canceledWriteReview()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addPayment(sender: AnyObject) {
        let doneButton = self.navigationItem.rightBarButtonItem
        let addingPaymentIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        addingPaymentIndicator.startAnimating()
        self.navigationItem.setRightBarButtonItem(UIBarButtonItem(customView: addingPaymentIndicator), animated: true)
        
        var errorAlert: UIAlertController?
        
        if Int(starRatingView.value) == 0 {
            errorAlert = UIAlertController(title: "Error", message: "Please select a rating.", preferredStyle: .Alert)
            errorAlert!.addAction(UIAlertAction(title: "Done", style: .Default, handler: nil))
        }
        else if descriptionTextView.textColor == UIColor.lightGrayColor() || (descriptionTextView.textColor == UIColor.whiteColor() && descriptionTextView.text.isEmpty)  {
            errorAlert = UIAlertController(title: "Error", message: "Please enter a description for the review.", preferredStyle: .Alert)
            errorAlert!.addAction(UIAlertAction(title: "Done", style: .Default, handler: nil))
        }
        
        if errorAlert != nil {
            self.navigationItem.setRightBarButtonItem(doneButton, animated: true)
            presentViewController(errorAlert!, animated: true, completion: nil)
        }
        else {
            // Creates, configures, and saves new Review object
            let newReview = review == nil ? PFObject(className: "Reviews") : review!
            newReview["Writer"] = currentUser.username
            newReview["ReviewOf"] = user!["username"] as! String
            newReview["Unread"] = true
            newReview["Description"] = descriptionTextView.text
            newReview["Rating"] = starRatingView.value
            
            var title = titleTextField.text
            if title.isEmpty {
                switch Int(starRatingView.value) {
                case 1:
                    title = "One Star"
                case 2:
                    title = "Two Stars"
                case 3:
                    title = "Three Stars"
                case 4:
                    title = "Four Stars"
                case 5:
                    title = "Five Stars"
                default:
                    break
                }
            }
            newReview["Title"] = title
            
            newReview.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                if error == nil {
                    self.delegate?.wroteReview(review: newReview, writer: self.currentUser)
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
    
    // MARK: - Table view delegate methods 
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel.font = UIFont(name: "Gotham-Book", size: 13)
    }
    
    // MARK: - Text view delegate methods
    
    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = ""
            textView.textColor = UIColor.whiteColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.text = "Description"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
}
