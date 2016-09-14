//
//  PaymentsViewController.swift
//  Ignus
//
//  Created by Anant Jain on 2/8/15.
//  Copyright (c) 2015 Anant Jain. All rights reserved.
//

import UIKit

class PaymentsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIViewControllerTransitioningDelegate, AddPaymentTableViewControllerDelegate, PaymentInfoTableViewControllerDelegate {
    
    @IBOutlet weak var paymentsTable: UITableView!
    @IBOutlet weak var noPaymentsView: UIView!
    @IBOutlet weak var paymentsFilterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var paymentsLoadingIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var noPaymentsTitleLabel: UILabel!
    @IBOutlet weak var noPaymentsDescriptionLabel: UILabel!
    
    let currentUser = PFUser.currentUser()
    
    let refreshControl = UIRefreshControl()
    
    var myPaymentsPayments = [PFObject]()
    var myPaymentsUsers = [PFObject]()
    
    var incomingPaymentsPayments = [PFObject]()
    var incomingPaymentsUsers = [PFObject]()
    
    var unreadIncomingPayments = 0
    
    var dismissTransition: UIViewControllerAnimatedTransitioning?
    
    var sourceCellFrame: CGRect?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let selectedIndexPath = paymentsTable.indexPathForSelectedRow() {
            paymentsTable.deselectRowAtIndexPath(selectedIndexPath, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        paymentsTable.separatorEffect = UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark))
        refreshControl.addTarget(self, action: "reloadData:isInitialLoad:", forControlEvents: .ValueChanged)
        refreshControl.tintColor = UIColor.whiteColor()
        paymentsTable.addSubview(refreshControl)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshPayments:", name: "Reload Payments", object: nil)
        
        reloadData(nil, isInitialLoad: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refreshPayments(notification: NSNotification) {
        reloadData(notification)
    }
    
    func reloadData(sender: AnyObject?, isInitialLoad: Bool = false) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            // Loads all active payments in which I ask for money
            var paymentsQuery = PFQuery(className: "Payments")
            paymentsQuery.whereKey("Receiver", equalTo: self.currentUser.username)
            paymentsQuery.whereKey("Rating", equalTo: "Undecided")
            if let data = paymentsQuery.findObjects() {
                var newLoadedPaymentsPayments = [PFObject]()
                var newLoadedPaymentsUsers = [PFObject]()
                var newLoadedIncomingPayments = [PFObject]()
                var newLoadedIncomingUsers = [PFObject]()
                
                // Loads the users I ask money from
                for paymentObject in data as! [PFObject] {
                    let userQuery = PFUser.query()
                    userQuery.whereKey("username", equalTo: paymentObject["Sender"] as! String)
                    
                    newLoadedPaymentsUsers.append(userQuery.getFirstObject())
                    newLoadedPaymentsPayments.append(paymentObject)
                }
                
                // Loads all active payments in which people ask money from me
                paymentsQuery = PFQuery(className: "Payments")
                paymentsQuery.whereKey("Sender", equalTo: self.currentUser.username)
                paymentsQuery.whereKey("Rating", equalTo: "Undecided")
                
                
                // Loads the users that asked me for money
                if let data2 = paymentsQuery.findObjects() {
                    for paymentObject in data2 as! [PFObject] {
                        let userQuery = PFUser.query()
                        userQuery.whereKey("username", equalTo: paymentObject["Receiver"] as! String)
                        
                        newLoadedIncomingUsers.append(userQuery.getFirstObject())
                        newLoadedIncomingPayments.append(paymentObject)
                    }
                }
                
                // Reassigns the new data to the array
                self.myPaymentsPayments = newLoadedPaymentsPayments
                self.myPaymentsUsers = newLoadedPaymentsUsers
                self.incomingPaymentsPayments = newLoadedIncomingPayments
                self.incomingPaymentsUsers = newLoadedIncomingUsers
                
                self.sortPaymentsAndUsers(payments: &self.myPaymentsPayments, users: &self.myPaymentsUsers)
                self.sortPaymentsAndUsers(payments: &self.incomingPaymentsPayments, users: &self.incomingPaymentsUsers)
                
                
                // Hides or shows the table view and other related views if the user has any payments.
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if (self.refreshControl.refreshing) {
                        self.refreshControl.endRefreshing()
                    }
                    
                    self.paymentsTable.hidden = false
                    self.noPaymentsView.hidden = false
                    
                    if isInitialLoad {
                        self.paymentsTable.reloadData()
                    }
                    
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.updateUnreadIncomingPayments()
                        self.paymentsLoadingIndicatorView.alpha = 0.0
                        
                        switch self.paymentsFilterSegmentedControl.selectedSegmentIndex {
                        case 0:
                            self.noPaymentsView.alpha = self.myPaymentsPayments.count == 0 ? 1.0 : 0.0
                            self.paymentsTable.alpha = self.myPaymentsPayments.count == 0 ? 0.0 : 1.0
                        case 1:
                            self.noPaymentsView.alpha = self.incomingPaymentsPayments.count == 0 ? 1.0 : 0.0
                            self.paymentsTable.alpha = self.incomingPaymentsPayments.count == 0 ? 0.0 : 1.0
                        default:
                            break
                        }
                        }, completion: { (completed) -> Void in
                            self.paymentsLoadingIndicatorView.stopAnimating()
                            self.paymentsLoadingIndicatorView.hidden = true
                            
                            self.changedFilter(self.paymentsFilterSegmentedControl)
                    })
                    
                    if !isInitialLoad {
                        self.paymentsTable.reloadData()
                    }
                })
            }
        })
    }
    
    func updateUnreadIncomingPayments() {
        // Counts unread incoming payments and badges tab and navigation bar title
        unreadIncomingPayments = 0
        for incomingPayment in incomingPaymentsPayments {
            if incomingPayment["Unread"] as! Bool {
                unreadIncomingPayments++
            }
        }
        
        var badgeValue: String? = (unreadIncomingPayments > 0) ? "\(unreadIncomingPayments)" : nil
        self.navigationController?.tabBarItem.badgeValue = badgeValue
        self.paymentsFilterSegmentedControl.setTitle((unreadIncomingPayments > 0) ? "Incoming (\(unreadIncomingPayments))" : "Incoming", forSegmentAtIndex: 1)
    }

    @IBAction func changedFilter(sender: UISegmentedControl) {        
        if sender.selectedSegmentIndex == 0 {
            self.noPaymentsTitleLabel.text = "No Requests"
            self.noPaymentsDescriptionLabel.text = "Add some by pressing +."
            
            if !paymentsLoadingIndicatorView.isAnimating() {
                paymentsTable.alpha = myPaymentsPayments.count == 0 ? 0.0 : 1.0
                paymentsTable.hidden = myPaymentsPayments.count == 0
                paymentsTable.userInteractionEnabled = myPaymentsPayments.count != 0
                noPaymentsView.alpha = myPaymentsPayments.count == 0 ? 1.0 : 0.0
                noPaymentsView.hidden = myPaymentsPayments.count != 0
            }
        }
        else if sender.selectedSegmentIndex == 1 {
            self.noPaymentsTitleLabel.text = "No Incoming Payments"
            self.noPaymentsDescriptionLabel.text = "Payments requested from you will appear here."
            
            if !paymentsLoadingIndicatorView.isAnimating() {
                paymentsTable.alpha = incomingPaymentsPayments.count == 0 ? 0.0 : 1.0
                paymentsTable.hidden = incomingPaymentsPayments.count == 0
                paymentsTable.userInteractionEnabled = incomingPaymentsPayments.count != 0
                noPaymentsView.alpha = incomingPaymentsPayments.count == 0 ? 1.0 : 0.0
                self.noPaymentsView.hidden = incomingPaymentsPayments.count != 0
            }
        }
        
        paymentsTable.reloadData()
    }
    
    func sortPaymentsAndUsers(inout #payments: [PFObject], inout users: [PFObject]) {
        var groupedArray = [(PFObject, PFObject)]()
        
        for i in 0..<payments.count {
            groupedArray.append((payments[i], users[i]))
        }
        
        let sortedArray = sorted(groupedArray, { $0.0.createdAt.timeIntervalSinceDate($1.0.createdAt) > 0 })
        
        var newPayments = [PFObject]()
        var newUsers = [PFObject]()
        
        for payment in sortedArray {
            newPayments.append(payment.0)
            newUsers.append(payment.1)
        }
        
        payments = newPayments
        users = newUsers
    }
    
    // MARK: - AddPaymentTableViewControllerDelegate methods
    
    func addedPayment(payment: PFObject, user: PFObject) {
        // Creates dismiss transition
        dismissTransition = AddPaymentTransition(presenting: false, paymentAdded: true)
        
        // Resets payments filter and views
        paymentsFilterSegmentedControl.selectedSegmentIndex = 0
        self.noPaymentsTitleLabel.text = "No Requests"
        self.noPaymentsDescriptionLabel.text = "Add some by pressing +."
        paymentsTable.alpha = 1.0
        paymentsTable.hidden = false
        paymentsTable.userInteractionEnabled = true
        noPaymentsView.alpha = 0.0
        noPaymentsView.hidden = true
        paymentsTable.reloadData()
        
        // Adds new data
        myPaymentsPayments.insert(payment, atIndex: 0)
        myPaymentsUsers.insert(user, atIndex: 0)
        
        // Inserts first table cell
        paymentsTable.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
    }
    
    func canceledPayment() {
        // Creates dismiss transition
        dismissTransition = AddPaymentTransition(presenting: false, paymentAdded: false)
    }
    
    // MARK: - PaymentInfoTableViewControllerDelegate methods
    
    func deletePayment() {
        dismissTransition = PaymentInfoTransition(presenting: false, cellFrame: CGRect())
        if let selectedIndex = paymentsTable.indexPathForSelectedRow() {
            let paymentObject = myPaymentsPayments.removeAtIndex(selectedIndex.row)
            myPaymentsUsers.removeAtIndex(selectedIndex.row)
            
            paymentObject.deleteInBackground()
            
            paymentsTable.deleteRowsAtIndexPaths([selectedIndex], withRowAnimation: .Automatic)
        }
        
        // Hides table if there are no more payments
        if myPaymentsPayments.count == 0 {
            noPaymentsView.hidden = false
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.paymentsTable.alpha = 0.0
                self.noPaymentsView.alpha = 1.0
                }) { (completed) -> Void in
                    self.paymentsTable.hidden = true
                    self.paymentsTable.userInteractionEnabled = false
            }
        }
    }
    
    func completePayment() {
        dismissTransition = PaymentInfoTransition(presenting: false, cellFrame: CGRect())
        
        if let selectedIndex = paymentsTable.indexPathForSelectedRow() {
            myPaymentsPayments.removeAtIndex(selectedIndex.row)
            myPaymentsUsers.removeAtIndex(selectedIndex.row)
            
            paymentsTable.deleteRowsAtIndexPaths([selectedIndex], withRowAnimation: .Automatic)
        }
        
        // Hides table if there are no more payments
        if myPaymentsPayments.count == 0 {
            noPaymentsView.hidden = false
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.paymentsTable.alpha = 0.0
                self.noPaymentsView.alpha = 1.0
                }) { (completed) -> Void in
                    self.paymentsTable.hidden = true
                    self.paymentsTable.userInteractionEnabled = false
            }
        }
    }
    
    func closePaymentInfo() {
        dismissTransition = PaymentInfoTransition(presenting: false, cellFrame: sourceCellFrame!)
    }
    
    // MARK: - Table view data source methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (paymentsFilterSegmentedControl.selectedSegmentIndex) {
        case 0:
            return myPaymentsPayments.count
        case 1:
            return incomingPaymentsPayments.count
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier((paymentsFilterSegmentedControl.selectedSegmentIndex == 0) ? "My Payments Cell" : "Incoming Cell") as! UITableViewCell
        
        let profileView = cell.viewWithTag(1) as! UIImageView
        let nameView = cell.viewWithTag(2) as! UILabel
        let moneyView = cell.viewWithTag(3) as! UILabel
        let dateLabel = cell.viewWithTag(5) as! UILabel
        
        let paymentObject = paymentsFilterSegmentedControl.selectedSegmentIndex == 0 ? myPaymentsPayments[indexPath.row] : incomingPaymentsPayments[indexPath.row]
        let user = paymentsFilterSegmentedControl.selectedSegmentIndex == 0 ? myPaymentsUsers[indexPath.row] : incomingPaymentsUsers[indexPath.row]
        
        let profileFile = user["Profile"] as! PFFile
        profileFile.getDataInBackgroundWithBlock { (data, error) -> Void in
            if error == nil {
                UIView.transitionWithView(profileView, duration: 0.3, options: .TransitionCrossDissolve, animations: { () -> Void in
                    profileView.image = UIImage(data: data)
                }, completion: nil)
            }
        }
        
        nameView.text = user["FullName"] as? String
        
        // Money label stuff
        var descriptionText = "$" + (paymentObject["MoneyOwed"] as! String)
        if count(paymentObject["Memo"] as! String) > 0 {
            descriptionText += (" — " + (paymentObject["Memo"] as! String))
        }
        moneyView.text = descriptionText
        
        if paymentsFilterSegmentedControl.selectedSegmentIndex == 1 {
            let unreadIndicator = cell.viewWithTag(4)!
            unreadIndicator.hidden = !(paymentObject["Unread"] as! Bool)
        }
        
        let messageDate = paymentObject.createdAt
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = (NSCalendar.currentCalendar().isDateInToday(messageDate)) ? "h:mm a" : "MM/dd/yy"
        dateLabel.text = dateFormatter.stringFromDate(messageDate)
        
        cell.backgroundColor = UIColor.clearColor()
        cell.backgroundView = UIView()
        
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

        
        if paymentsFilterSegmentedControl.selectedSegmentIndex == 1 {
            let selectedCell = tableView.cellForRowAtIndexPath(indexPath)!
            let unreadIndicator = selectedCell.viewWithTag(4)!
            if unreadIndicator.hidden == false {
                unreadIndicator.hidden = true
                
                let newlyReadIncomingObject = incomingPaymentsPayments[indexPath.row]
                newlyReadIncomingObject["Unread"] = false
                newlyReadIncomingObject.saveInBackground()
                
                updateUnreadIncomingPayments()
            }
        }
        performSegueWithIdentifier("Show Payment Info", sender: indexPath)
    }
    
    // MARK: - UIViewControllerTransitioningDelegate methods
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if let navVC = presented as? UINavigationController {
            if navVC.topViewController is AddPaymentTableViewController {
                return AddPaymentTransition(presenting: true)
            }
            else if navVC.topViewController is PaymentInfoTableViewController {
                return PaymentInfoTransition(presenting: true, cellFrame: sourceCellFrame!)
            }
        }
        return nil
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Payment Info" {
            let paymentInfoNavVC = segue.destinationViewController as! UINavigationController
            paymentInfoNavVC.modalPresentationStyle = .Custom
            paymentInfoNavVC.transitioningDelegate = self
            
            let paymentInfoVC = paymentInfoNavVC.topViewController as! PaymentInfoTableViewController
            paymentInfoVC.delegate = self
            
            let selectedIndex = sender as! NSIndexPath
            
            if paymentsFilterSegmentedControl.selectedSegmentIndex == 0 {
                paymentInfoVC.payment = myPaymentsPayments[selectedIndex.row]
                paymentInfoVC.user = myPaymentsUsers[selectedIndex.row]
                paymentInfoVC.paymentType = .MyRequest
            }
            else if paymentsFilterSegmentedControl.selectedSegmentIndex == 1 {
                paymentInfoVC.payment = incomingPaymentsPayments[selectedIndex.row]
                paymentInfoVC.user = incomingPaymentsUsers[selectedIndex.row]
                paymentInfoVC.paymentType = .Incoming
            }
        }
        else if segue.identifier == "Add Payment" {
            let addPaymentNavVC = segue.destinationViewController as! UINavigationController
            addPaymentNavVC.modalPresentationStyle = .Custom
            addPaymentNavVC.transitioningDelegate = self
            
            let addPaymentVC = addPaymentNavVC.topViewController as! AddPaymentTableViewController
            addPaymentVC.delegate = self
        }
    }
    
    @IBAction func returnToPaymentsViewController(segue: UIStoryboardSegue) {
        if let selectedIndex = paymentsTable.indexPathForSelectedRow() {
            paymentsTable.deselectRowAtIndexPath(selectedIndex, animated: true)
        }
    }
}
