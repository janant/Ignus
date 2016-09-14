//
//  ProfileViewController.swift
//  Ignus
//
//  Created by Anant Jain on 2/7/15.
//  Copyright (c) 2015 Anant Jain. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, XYPieChartDataSource, XYPieChartDelegate, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate, FriendOptionsViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ComposeMessageViewControllerDelegate, WriteReviewTableViewControllerDelegate, AddPaymentTableViewControllerDelegate {
    
    var user: PFObject?
    
    @IBOutlet weak var profileInfoView: UIView!
    @IBOutlet weak var profilePictureView: UIImageView!
    @IBOutlet weak var coverPictureView: UIImageView!
    @IBOutlet weak var nameTextView: UILabel!
    @IBOutlet weak var usernameTextView: UILabel!
    
    @IBOutlet weak var numFriendsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    // Ratings view
    @IBOutlet weak var ratingsView: UIView!
    @IBOutlet weak var loadingRatingsIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var noRatingsLabel: UILabel!
    @IBOutlet weak var pieChart: XYPieChart!
    @IBOutlet weak var chartPercentageView: UIVisualEffectView!
    @IBOutlet weak var chartPercentageLabel: UILabel!
    @IBOutlet weak var chartPercentageDescription: UILabel!
    
    
    @IBOutlet weak var userSegmentedControl: UISegmentedControl!
    
    // Payments view
    @IBOutlet weak var paymentsView: UIView!
    @IBOutlet weak var paymentsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var noPaymentsLabel: UILabel!
    @IBOutlet weak var paymentsTable: UITableView!
    @IBOutlet weak var loadingPaymentsIndicatorView: UIActivityIndicatorView!
    
    var myPayments = [PFObject]()
    var incomingPayments = [PFObject]()
    
    // Reviews view
    @IBOutlet weak var reviewsView: UIView!
    @IBOutlet weak var reviewsTable: UITableView!
    @IBOutlet weak var loadingReviewsIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var reviewsSegmentedControl: UISegmentedControl!
    
    var reviewsOfThemReviews = [PFObject]()
    var reviewsOfThemUsers = [PFObject]()
    
    var theirReviewsReviews = [PFObject]()
    var theirReviewsUsers = [PFObject]()
    
    @IBOutlet weak var friendOptionsButton: UIButton!

    let currentUser = PFUser.currentUser()
    
    var dismissComposeTransition: UIViewControllerAnimatedTransitioning?
    
    var darkView: UIView?
    
    var profileType = "User"
    
    var ratings = (green: 0, yellow: 0, red: 0)
    
    var profilePickerVC: UIImagePickerController?
    var coverPickerVC: UIImagePickerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = user!["FirstName"] as? String
        self.nameTextView.text = user!["FullName"] as? String
        self.usernameTextView.text = user!["username"] as? String
        
        let profileFile = user!["Profile"] as! PFFile
        profileFile.getDataInBackgroundWithBlock { (data, error) -> Void in
            if error == nil {
                UIView.transitionWithView(self.profilePictureView, duration: 0.3, options: .TransitionCrossDissolve, animations: { () -> Void in
                    self.profilePictureView.image = UIImage(data: data)
                    }, completion: nil)
            }
        }
        
        let coverFile = user!["Cover"] as! PFFile
        coverFile.getDataInBackgroundWithBlock { (data, error) -> Void in
            if error == nil {
                UIView.transitionWithView(self.coverPictureView, duration: 0.3, options: .TransitionCrossDissolve, animations: { () -> Void in
                    self.coverPictureView.image = UIImage(data: data)
                    }, completion: nil)
            }
        }
        
        self.profilePictureView.image = UIImage(named: "DefaultProfile.png")
        self.coverPictureView.image = UIImage(named: "DefaultCover.jpg")
        
        pieChart.dataSource = self
        pieChart.delegate = self
        
        pieChart.animationSpeed = 1.0
        pieChart.showLabel = false
        
        chartPercentageView.transform = CGAffineTransformMakeScale(0, 0)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshProfile:", name: "Reload Profile", object: nil)
        
        var friendsLabelText = "0";
        var ratingsLabelText = "0"
        
        paymentsSegmentedControl.setTitle((user!["FirstName"] as! String) + "'s Requests", forSegmentAtIndex: 1)
        
        reviewsSegmentedControl.setTitle("Reviews of " + (self.user!["FirstName"] as! String), forSegmentAtIndex: 0)
        reviewsSegmentedControl.setTitle((self.user!["FirstName"] as! String) + "'s Reviews", forSegmentAtIndex: 1)
        
        profilePictureView.contentMode = .ScaleAspectFill
        coverPictureView.contentMode = .ScaleAspectFill
        
        paymentsTable.separatorEffect = UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark))
        reviewsTable.separatorEffect = UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Dark))
        reviewsTable.rowHeight = UITableViewAutomaticDimension
        reviewsTable.estimatedRowHeight = 100
        
        // Gets number of friends
        let friendsQuery = PFQuery(className: "Friends")
        friendsQuery.whereKey("User", equalTo: self.user!["username"] as! String)
        friendsQuery.getFirstObjectInBackgroundWithBlock({ (data, error) -> Void in
            if error == nil {
                let friends = data["Friends"] as! [String]
                friendsLabelText = "\(friends.count)"
            }
            
            UIView.transitionWithView(self.numFriendsLabel, duration: 0.5, options: .TransitionCrossDissolve, animations: { () -> Void in
                self.numFriendsLabel.text = friendsLabelText
                }, completion: nil)
            }
        )
        
        // Loads ratings tab
        let ratingsQuery = PFQuery(className: "Payments")
        ratingsQuery.whereKey("Sender", equalTo: self.user!["username"] as! String)
        ratingsQuery.whereKey("Rating", notEqualTo: "Undecided")
        ratingsQuery.findObjectsInBackgroundWithBlock { (data, error) -> Void in
            if error == nil {
                ratingsLabelText = "\(data.count)"
                
                for payment in data {
                    let rating = payment["Rating"] as! String
                    if rating == "Green" {
                        self.ratings.green++
                    }
                    else if rating == "Yellow" {
                        self.ratings.yellow++
                    }
                    else if rating == "Red" {
                        self.ratings.red++
                    }
                }
                
                let total = self.ratings.green + self.ratings.yellow + self.ratings.red
                
                // No ratings
                if total == 0 {
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.loadingRatingsIndicatorView.alpha = 0.0
                        self.noRatingsLabel.alpha = 1.0
                    }, completion: { (completed) -> Void in
                        self.loadingRatingsIndicatorView.stopAnimating()
                    })
                }
                else {
                    // Only one type of rating
                    if total == self.ratings.green || total == self.ratings.yellow || total == self.ratings.red {
                        // Prevent user from tapping pie chart piece
                        self.pieChart.userInteractionEnabled = false
                    }
                    
                    self.pieChart.pieRadius = min(self.pieChart.frame.size.height * 0.4, 120)
                    self.pieChart.pieCenter = self.chartPercentageView.center
                    self.pieChart.reloadData()
                    
                    self.chartPercentageLabel.text = String(format: "%.1lf%%", Double(self.ratings.green) / Double(self.ratings.green + self.ratings.yellow + self.ratings.red) * 100.0)
                    
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.loadingRatingsIndicatorView.alpha = 0.0
                    }, completion: { (completed) -> Void in
                            self.loadingRatingsIndicatorView.stopAnimating()
                    })
                    
                    UIView.animateWithDuration(1.0, animations: { () -> Void in
                        self.chartPercentageView.transform =  self.view.frame.size.height < 500 ? CGAffineTransformMakeScale(0.8, 0.8) : CGAffineTransformIdentity
                    })
                }
            }
            
            UIView.transitionWithView(self.ratingLabel, duration: 0.5, options: .TransitionCrossDissolve, animations: { () -> Void in
                self.ratingLabel.text = ratingsLabelText
            }, completion: nil)
        }
        
        // Loads Payments tab
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            // Loads all payments in which I ask for money
            var paymentsQuery = PFQuery(className: "Payments")
            paymentsQuery.whereKey("Receiver", equalTo: self.currentUser.username)
            paymentsQuery.whereKey("Sender", equalTo: self.user!["username"] as! String)
            if let data = paymentsQuery.findObjects() {
                
                self.myPayments = data as! [PFObject]
                
                // Loads all payments in which the user asks money from me
                paymentsQuery = PFQuery(className: "Payments")
                paymentsQuery.whereKey("Sender", equalTo: self.currentUser.username)
                paymentsQuery.whereKey("Receiver", equalTo: self.user!["username"] as! String)
                if let data2 = paymentsQuery.findObjects() {
                    self.incomingPayments = data2 as! [PFObject]
                }
                
                // Sorts payments by time
                self.myPayments.sort({ $0.createdAt.timeIntervalSinceDate($1.createdAt) > 0 })
                self.incomingPayments.sort({ $0.createdAt.timeIntervalSinceDate($1.createdAt) > 0 })
                
                // Hides or shows the table view and other related views if the user has any payments.
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.paymentsTable.reloadData()
                    
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.loadingPaymentsIndicatorView.alpha = 0.0
                        
                        switch self.paymentsSegmentedControl.selectedSegmentIndex {
                        case 0:
                            self.noPaymentsLabel.alpha = self.myPayments.count == 0 ? 1.0 : 0.0
                            self.paymentsTable.alpha = self.myPayments.count == 0 ? 0.0 : 1.0
                        case 1:
                            self.noPaymentsLabel.alpha = self.incomingPayments.count == 0 ? 1.0 : 0.0
                            self.paymentsTable.alpha = self.incomingPayments.count == 0 ? 0.0 : 1.0
                        default:
                            break
                        }
                        }, completion: { (completed) -> Void in
                            self.loadingPaymentsIndicatorView.stopAnimating()
                            self.loadingPaymentsIndicatorView.hidden = true
                            
                            self.paymentsSegmentedControlChanged(self.paymentsSegmentedControl)
                    })
                })
            }
        })
        
        // Loads reviews tab
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            // Loads all reviews of them
            var reviewsQuery = PFQuery(className: "Reviews")
            reviewsQuery.whereKey("ReviewOf", equalTo: self.user!["username"] as! String)
            if let data = reviewsQuery.findObjects() {
                // Loads the users that reviewed them
                for reviewObject in data as! [PFObject] {
                    let userQuery = PFUser.query()
                    userQuery.whereKey("username", equalTo: reviewObject["Writer"] as! String)
                    
                    self.reviewsOfThemUsers.append(userQuery.getFirstObject())
                    self.reviewsOfThemReviews.append(reviewObject)
                }
                
                // Loads all reviews that they wrote
                reviewsQuery = PFQuery(className: "Reviews")
                reviewsQuery.whereKey("Writer", equalTo: self.user!["username"] as! String)
                
                // Loads the users that they wrote reviews for
                if let data2 = reviewsQuery.findObjects() {
                    for reviewObject in data2 as! [PFObject] {
                        let userQuery = PFUser.query()
                        userQuery.whereKey("username", equalTo: reviewObject["ReviewOf"] as! String)
                        
                        self.theirReviewsUsers.append(userQuery.getFirstObject())
                        self.theirReviewsReviews.append(reviewObject)
                    }
                }
                
                // Sorts reviews based on the time they were written
                self.sortReviewsAndUsers(reviews: &self.reviewsOfThemReviews, users: &self.reviewsOfThemUsers)
                self.sortReviewsAndUsers(reviews: &self.theirReviewsReviews, users: &self.theirReviewsUsers)
                
                
                // Hides or shows the table view and other related views if the user has any reviews.
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.reviewsTable.reloadData()
                    
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.loadingReviewsIndicatorView.alpha = 0.0
                        self.reviewsTable.alpha = 1.0
                    }, completion: { (completed) -> Void in
                        self.loadingReviewsIndicatorView.stopAnimating()
                        self.loadingReviewsIndicatorView.hidden = true
                        
                        self.reviewsTable.userInteractionEnabled = true
                        
                        self.paymentsSegmentedControlChanged(self.paymentsSegmentedControl)
                    })
                })
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sortReviewsAndUsers(inout #reviews: [PFObject], inout users: [PFObject]) {
        var groupedArray = [(PFObject, PFObject)]()
        
        for i in 0..<reviews.count {
            groupedArray.append((reviews[i], users[i]))
        }
        
        let sortedArray = sorted(groupedArray, { $0.0.createdAt.timeIntervalSinceDate($1.0.createdAt) > 0 })
        
        var newReviews = [PFObject]()
        var newUsers = [PFObject]()
        
        for review in sortedArray {
            newReviews.append(review.0)
            newUsers.append(review.1)
        }
        
        reviews = newReviews
        users = newUsers
    }
    
    func refreshProfile(notification: NSNotification) {
        if profileType == "Current User" {
            let userInfo = notification.userInfo as! [String: UIImage]
            profilePictureView.image = userInfo["Profile"]
            coverPictureView.image = userInfo["Cover"]
        }
    }
    
    @IBAction func userSegmentedControlChanged(sender: AnyObject) {
        ratingsView.hidden = userSegmentedControl.selectedSegmentIndex != 0
        paymentsView.hidden = userSegmentedControl.selectedSegmentIndex != 1
        reviewsView.hidden = userSegmentedControl.selectedSegmentIndex != 2
    }
    
    @IBAction func paymentsSegmentedControlChanged(sender: AnyObject) {
        
        paymentsTable.contentOffset = CGPoint(x: 0, y: 0)
        
        if sender.selectedSegmentIndex == 0 {
            self.noPaymentsLabel.text = "No Requests"
            
            if !loadingPaymentsIndicatorView.isAnimating() {
                paymentsTable.alpha = myPayments.count == 0 ? 0.0 : 1.0
                paymentsTable.hidden = myPayments.count == 0
                paymentsTable.userInteractionEnabled = myPayments.count != 0
                noPaymentsLabel.alpha = myPayments.count == 0 ? 1.0 : 0.0
                noPaymentsLabel.hidden = myPayments.count != 0
            }
        }
        else if sender.selectedSegmentIndex == 1 {
            self.noPaymentsLabel.text = "No Incoming Payments"
            
            if !loadingPaymentsIndicatorView.isAnimating() {
                paymentsTable.alpha = incomingPayments.count == 0 ? 0.0 : 1.0
                paymentsTable.hidden = incomingPayments.count == 0
                paymentsTable.userInteractionEnabled = incomingPayments.count != 0
                noPaymentsLabel.alpha = incomingPayments.count == 0 ? 1.0 : 0.0
                noPaymentsLabel.hidden = incomingPayments.count != 0
            }
        }
        
        paymentsTable.reloadData()
    }
    
    @IBAction func reviewsSegmentedControlChanged(sender: AnyObject) {
        reviewsTable.contentOffset = CGPoint(x: 0, y: 0)
        reviewsTable.reloadData()
    }
    
    @IBAction func shareUser(sender: AnyObject) {
        let shareData = "Check out " + (self.user!["FullName"] as! String) + " (" + (self.user!["username"] as! String) + ") on Ignus!"
        let shareSheet = UIActivityViewController(activityItems: [shareData], applicationActivities: nil)
        shareSheet.excludedActivityTypes = [UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll]
        
        presentViewController(shareSheet, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source methods
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if tableView === paymentsTable {
            return 1
        }
        else {
            return 2
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === paymentsTable {
            return paymentsSegmentedControl.selectedSegmentIndex == 0 ? myPayments.count : incomingPayments.count
        }
        else {
            if section == 0 {
                return 2
            }
            else {
                return reviewsSegmentedControl.selectedSegmentIndex == 0 ? reviewsOfThemReviews.count : theirReviewsReviews.count
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if tableView === paymentsTable {
            let cell = tableView.dequeueReusableCellWithIdentifier((paymentsSegmentedControl.selectedSegmentIndex == 0) ? "My Payments Cell" : "Incoming Cell", forIndexPath: indexPath) as! UITableViewCell
            
            let titleLabel = cell.viewWithTag(1) as! UILabel
            let descriptionLabel = cell.viewWithTag(2) as! UILabel
            let dateLabel = cell.viewWithTag(3) as! UILabel
            
            let paymentObject = paymentsSegmentedControl.selectedSegmentIndex == 0 ? myPayments[indexPath.row] : incomingPayments[indexPath.row]
            
            // Title label stuff
            let paymentRating = paymentObject["Rating"] as! String
            if paymentRating == "Undecided" {
                titleLabel.text = "Active"
            }
            else {
                titleLabel.text = "Completed"
                if paymentRating == "Green" {
                    titleLabel.textColor = UIColor(red: 85/255.0, green: 205/255.0, blue: 41/255.0, alpha: 1.0)
                }
                else if paymentRating == "Yellow" {
                    titleLabel.textColor = UIColor.yellowColor()
                }
                else if paymentRating == "Red" {
                    titleLabel.textColor = UIColor.redColor()
                }
            }
            
            // Description label stuff
            var descriptionText = "$" + (paymentObject["MoneyOwed"] as! String)
            if count(paymentObject["Memo"] as! String) > 0 {
                descriptionText += (" — " + (paymentObject["Memo"] as! String))
            }
            descriptionLabel.text = descriptionText
            
            // Unread indicator
            if paymentsSegmentedControl.selectedSegmentIndex == 1 {
                let unreadIndicator = cell.viewWithTag(4)!
                unreadIndicator.hidden = !(paymentObject["Unread"] as! Bool)
            }
            
            // Date label
            let messageDate = paymentObject.createdAt
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = (NSCalendar.currentCalendar().isDateInToday(messageDate)) ? "h:mm a" : "MM/dd/yy"
            dateLabel.text = dateFormatter.stringFromDate(messageDate)
            
            cell.backgroundColor = UIColor.clearColor()
            cell.backgroundView = UIView()
            
            return cell
        }
        else {
            let reviews = reviewsSegmentedControl.selectedSegmentIndex == 0 ? reviewsOfThemReviews : theirReviewsReviews
            let users = reviewsSegmentedControl.selectedSegmentIndex == 0 ? reviewsOfThemUsers : theirReviewsUsers
            
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("Overview Cell", forIndexPath: indexPath) as! UITableViewCell
                    
                    let starRatingView = cell.viewWithTag(1) as! HCSStarRatingView
                    let descriptionLabel = cell.viewWithTag(2) as! UILabel
                    
                    if reviews.count == 0 {
                        starRatingView.value = 0
                        starRatingView.tintColor = UIColor.lightGrayColor()
                        descriptionLabel.text = "No Reviews"
                    }
                    else {
                        var rating = 0.0
                        for review in reviews {
                            rating += review["Rating"] as! Double
                        }
                        
                        rating /= Double(reviews.count)
                        
                        let starRating = round(rating * 2) / 2
                        
                        starRatingView.value = CGFloat(starRating)
                        starRatingView.tintColor = UIColor.whiteColor()
                        
                        let descriptionText = String(format: "%.2f out of 5 — %d Review", rating, reviews.count) + (reviews.count == 1 ? "" : "s")

                        descriptionLabel.text = descriptionText
                    }
                    
                    cell.backgroundColor = UIColor.clearColor()
                    cell.backgroundView = nil
                    
                    return cell
                }
                else if indexPath.row == 1 {
                    let cell = tableView.dequeueReusableCellWithIdentifier("Write Review Cell", forIndexPath: indexPath) as! UITableViewCell
                    
                    cell.backgroundColor = UIColor.clearColor()
                    cell.backgroundView = nil
                    
                    let selectedView = UIView()
                    selectedView.backgroundColor = UIColor.grayColor()
                    cell.selectedBackgroundView = selectedView
                    
                    return cell
                }
            }
            let cell = tableView.dequeueReusableCellWithIdentifier("Review Cell", forIndexPath: indexPath) as! UITableViewCell
            
            let reviewObject = reviews[indexPath.row]
            let userObject = users[indexPath.row]
            
            let personImageView = cell.viewWithTag(1) as! UIImageView
            let usernameLabel = cell.viewWithTag(2) as! UILabel
            let starRatingView = cell.viewWithTag(3) as! HCSStarRatingView
            let titleLabel = cell.viewWithTag(4) as! UILabel
            let descriptionLabel = cell.viewWithTag(5) as! UILabel
            let dateLabel = cell.viewWithTag(6) as! UILabel
            
            starRatingView.userInteractionEnabled = false
            
            let profileFile = userObject["Profile"] as! PFFile
            profileFile.getDataInBackgroundWithBlock { (data, error) -> Void in
                if error == nil {
                    UIView.transitionWithView(personImageView, duration: 0.3, options: .TransitionCrossDissolve, animations: { () -> Void in
                        personImageView.image = UIImage(data: data)
                        }, completion: nil)
                }
            }
            
            usernameLabel.text = userObject["username"] as? String
            starRatingView.value = CGFloat(reviewObject["Rating"] as! Int)
            titleLabel.text = reviewObject["Title"] as? String
            descriptionLabel.text = reviewObject["Description"] as? String
            
            let reviewDate = reviewObject.createdAt
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy"
            dateLabel.text = dateFormatter.stringFromDate(reviewDate)
            
            cell.backgroundColor = UIColor.clearColor()
            cell.backgroundView = nil
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView == reviewsTable {
            if section == 0 {
                return "Overall Rating"
            }
            else {
                return "Reviews"
            }
        }
        else {
            return nil
        }
    }
    
    // MARK: - Table view delegate methods
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel.font = UIFont(name: "Gotham-Book", size: 13)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if tableView == reviewsTable {
            if indexPath.section == 0 {
                if indexPath.row == 0 {
                    return 73
                }
                else {
                    return 44
                }
            }
            else {
                return 95
            }
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == reviewsTable {
            if indexPath.section == 0 {
                cell.separatorInset = UIEdgeInsetsZero
                cell.preservesSuperviewLayoutMargins = false
                cell.layoutMargins = UIEdgeInsetsZero
            }
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView == reviewsTable {
            if indexPath.section == 0 && indexPath.row == 1 {
                writeReview()
            }
            else {
                
            }
        }
    }
    
    // MARK: - Pie chart data source methods
    
    func pieChart(pieChart: XYPieChart!, valueForSliceAtIndex index: UInt) -> CGFloat {
        var number = 0
        if index == 0 {
            number = ratings.green
        }
        else if index == 1 {
            number = ratings.yellow
        }
        else if index == 2 {
            number = ratings.red
        }
        
        return CGFloat(number)
    }
    
    func pieChart(pieChart: XYPieChart!, colorForSliceAtIndex index: UInt) -> UIColor! {
        switch index {
        case 0:
            return UIColor(red: 85/255.0, green: 205/255.0, blue: 41/255.0, alpha: 1.0)
        case 1:
            return UIColor.yellowColor()
        case 2:
            return UIColor.redColor()
        default:
            return UIColor.whiteColor()
        }
    }
    
    func numberOfSlicesInPieChart(pieChart: XYPieChart!) -> UInt {
        return 3
    }
    
    // MARK: - Pie chart delegate methods
    
    func pieChart(pieChart: XYPieChart!, didSelectSliceAtIndex index: UInt) {
        var number = 0
        if index == 0 {
            number = ratings.green
        }
        else if index == 1 {
            number = ratings.yellow
        }
        else if index == 2 {
            number = ratings.red
        }
        
        // Determines description text
        var text = ""
        if index == 0 {
            text = "positive"
        }
        else if index == 1 {
            text = "neutral"
        }
        else if index == 2 {
            text = "negative"
        }
        
        UIView.transitionWithView(chartPercentageLabel, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.chartPercentageLabel.text = String(format: "%.1lf%%", Double(number) / Double(self.ratings.green + self.ratings.yellow + self.ratings.red) * 100.0)
        }, completion: nil)
        
        UIView.transitionWithView(chartPercentageDescription, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.chartPercentageDescription.text = text
        }, completion: nil)
    }
    
    func pieChart(pieChart: XYPieChart!, didDeselectSliceAtIndex index: UInt) {
        UIView.transitionWithView(chartPercentageLabel, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.chartPercentageLabel.text = String(format: "%.1lf%%", Double(self.ratings.green) / Double(self.ratings.green + self.ratings.yellow + self.ratings.red) * 100.0)
        }, completion: nil)
        UIView.transitionWithView(chartPercentageDescription, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.chartPercentageDescription.text = "positive"
        }, completion: nil)
    }
    
    // MARK: - FriendOptionsViewControllerDelegate methods
    
    func changeProfilePicture() {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.allowsEditing = true
        imagePickerVC.sourceType = .PhotoLibrary
        imagePickerVC.delegate = self
        
        profilePickerVC = imagePickerVC
        
        UIBarButtonItem.appearance().setTitleTextAttributes(nil, forState: .Normal)
        UINavigationBar.appearance().titleTextAttributes = nil
        
        presentViewController(imagePickerVC, animated: true) { () -> Void in
            UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        }
    }
    
    func changeCoverPhoto() {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.allowsEditing = true
        imagePickerVC.sourceType = .PhotoLibrary
        imagePickerVC.delegate = self
        
        coverPickerVC = imagePickerVC
        
        UIBarButtonItem.appearance().setTitleTextAttributes(nil, forState: .Normal)
        UINavigationBar.appearance().titleTextAttributes = nil
        
        presentViewController(imagePickerVC, animated: true) { () -> Void in
            UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        }
    }
    
    func sentFriendRequest() {
        profileType = "Pending Friend"
    }
    
    func respondedToFriendRequest(response: String) {
        profileType = response == "Accepted" ? "Friend" : "User"
    }
    
    func canceledFriendRequest() {
        profileType = "User"
    }
    
    func unfriended() {
        profileType = "User"
    }
    
    func writeReview() {
        if profileType == "Friend" {
            performSegueWithIdentifier("Write Review", sender: nil)
        }
        else {
            if profileType == "Current User" {
                let errorAlert = UIAlertController(title: "Error", message: "You can't write a review for yourself. Nice try!", preferredStyle: .Alert)
                errorAlert.addAction(UIAlertAction(title: "Done", style: .Default, handler: { (action) -> Void in
                    if let selectedIndex = self.reviewsTable.indexPathForSelectedRow() {
                        self.reviewsTable.deselectRowAtIndexPath(selectedIndex, animated: true)
                    }
                }))
                presentViewController(errorAlert, animated: true, completion: nil)
            }
            else {
                let errorAlert = UIAlertController(title: "Error", message: "You must be friends with this person to write a review.", preferredStyle: .Alert)
                errorAlert.addAction(UIAlertAction(title: "Done", style: .Default, handler: { (action) -> Void in
                    if let selectedIndex = self.reviewsTable.indexPathForSelectedRow() {
                        self.reviewsTable.deselectRowAtIndexPath(selectedIndex, animated: true)
                    }
                }))
                presentViewController(errorAlert, animated: true, completion: nil)
            }
        }
    }
    
    func requestPayment() {
        if profileType == "Friend" {
            performSegueWithIdentifier("Request Payment", sender: nil)
        }
        else {
            let errorAlert = UIAlertController(title: "Error", message: "You must be friends with this person to request a payment.", preferredStyle: .Alert)
            errorAlert.addAction(UIAlertAction(title: "Done", style: .Default, handler: nil))
            presentViewController(errorAlert, animated: true, completion: nil)
        }
    }
    
    func message() {
        performSegueWithIdentifier("Send Message", sender: nil)
    }
    
    func report() {
        
    }
    
    // MARK: - UIImagePickerControllerDelegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 17)!], forState: .Normal)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 18)!]
        
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        })
        
        if picker === profilePickerVC {
            let loadingAlert = UIAlertController(title: "Changing profile picture...", message: "\n\n", preferredStyle: .Alert)
            let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            loadingIndicatorView.color = UIColor.grayColor()
            loadingIndicatorView.startAnimating()
            loadingIndicatorView.center = CGPointMake(135, 65.5)
            loadingAlert.view.addSubview(loadingIndicatorView)
            presentViewController(loadingAlert, animated: true, completion: nil)
            
            let newProfileFile = PFFile(name: "Profile.png", data: UIImagePNGRepresentation(image))
            newProfileFile.saveInBackgroundWithBlock({ (completed, error) -> Void in
                if error == nil {
                    self.currentUser["Profile"] = newProfileFile
                    self.currentUser.saveInBackgroundWithBlock({ (completed, error) -> Void in
                        if error == nil {
                            self.profilePictureView.image = image
                            loadingAlert.dismissViewControllerAnimated(true, completion: nil)
                            
                            var userInfo = [String: UIImage]()
                            userInfo["Profile"] = image
                            userInfo["Cover"] = self.coverPictureView.image
                            
                            NSNotificationCenter.defaultCenter().postNotificationName("Reload Settings Profile", object: nil, userInfo: userInfo)
                        }
                    })
                }
            })
        }
        else if picker == coverPickerVC {
            let loadingAlert = UIAlertController(title: "Changing cover photo...", message: "\n\n", preferredStyle: .Alert)
            let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
            loadingIndicatorView.color = UIColor.grayColor()
            loadingIndicatorView.startAnimating()
            loadingIndicatorView.center = CGPointMake(135, 65.5)
            loadingAlert.view.addSubview(loadingIndicatorView)
            presentViewController(loadingAlert, animated: true, completion: nil)
            
            let newCoverFile = PFFile(name: "Cover.png", data: UIImagePNGRepresentation(image))
            newCoverFile.saveInBackgroundWithBlock({ (completed, error) -> Void in
                if error == nil {
                    self.currentUser["Cover"] = newCoverFile
                    self.currentUser.saveInBackgroundWithBlock({ (completed, error) -> Void in
                        if error == nil {
                            self.coverPictureView.image = image
                            loadingAlert.dismissViewControllerAnimated(true, completion: nil)
                            
                            var userInfo = [String: UIImage]()
                            userInfo["Profile"] = self.profilePictureView.image
                            userInfo["Cover"] = image
                            
                            NSNotificationCenter.defaultCenter().postNotificationName("Reload Settings Profile", object: nil, userInfo: userInfo)
                        }
                    })
                }
            })
        }
        
        profilePickerVC = nil
        coverPickerVC = nil
    }
    
//    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
//        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
//            UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
//        })
//        
//        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
//            if picker === profilePickerVC {
//                let loadingAlert = UIAlertController(title: "Changing profile picture...", message: "\n\n", preferredStyle: .Alert)
//                let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
//                loadingIndicatorView.color = UIColor.grayColor()
//                loadingIndicatorView.startAnimating()
//                loadingIndicatorView.center = CGPointMake(135, 65.5)
//                loadingAlert.view.addSubview(loadingIndicatorView)
//                presentViewController(loadingAlert, animated: true, completion: nil)
//                
//                let newProfileFile = PFFile(name: "Profile.png", data: UIImagePNGRepresentation(image))
//                newProfileFile.saveInBackgroundWithBlock({ (completed, error) -> Void in
//                    if error == nil {
//                        self.currentUser["Profile"] = newProfileFile
//                        self.currentUser.saveInBackgroundWithBlock({ (completed, error) -> Void in
//                            if error == nil {
//                                self.profilePictureView.image = image
//                                loadingAlert.dismissViewControllerAnimated(true, completion: nil)
//                                
//                                var userInfo = [String: UIImage]()
//                                userInfo["Profile"] = image
//                                userInfo["Cover"] = self.coverPictureView.image
//                                
//                                NSNotificationCenter.defaultCenter().postNotificationName("Reload Settings Profile", object: nil, userInfo: userInfo)
//                            }
//                        })
//                    }
//                })
//            }
//            else if picker == coverPickerVC {
//                let loadingAlert = UIAlertController(title: "Changing cover photo...", message: "\n\n", preferredStyle: .Alert)
//                let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
//                loadingIndicatorView.color = UIColor.grayColor()
//                loadingIndicatorView.startAnimating()
//                loadingIndicatorView.center = CGPointMake(135, 65.5)
//                loadingAlert.view.addSubview(loadingIndicatorView)
//                presentViewController(loadingAlert, animated: true, completion: nil)
//                
//                let newCoverFile = PFFile(name: "Cover.png", data: UIImagePNGRepresentation(image))
//                newCoverFile.saveInBackgroundWithBlock({ (completed, error) -> Void in
//                    if error == nil {
//                        self.currentUser["Cover"] = newCoverFile
//                        self.currentUser.saveInBackgroundWithBlock({ (completed, error) -> Void in
//                            if error == nil {
//                                self.coverPictureView.image = image
//                                loadingAlert.dismissViewControllerAnimated(true, completion: nil)
//                                
//                                var userInfo = [String: UIImage]()
//                                userInfo["Profile"] = self.profilePictureView.image
//                                userInfo["Cover"] = image
//                                
//                                NSNotificationCenter.defaultCenter().postNotificationName("Reload Settings Profile", object: nil, userInfo: userInfo)
//                            }
//                        })
//                    }
//                })
//            }
//            
//            profilePickerVC = nil
//            coverPickerVC = nil
//        }
//    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 17)!], forState: .Normal)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 18)!]
        
        picker.dismissViewControllerAnimated(true, completion: { () -> Void in
            UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        })
        profilePickerVC = nil
        coverPickerVC = nil
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - ComposeMessageViewControllerDelegate methods
    
    func canceledNewMessage() {
        dismissComposeTransition = ComposeTransition(presenting: false, messageSent: false)
    }
    
    func sentNewMessage() {
        dismissComposeTransition = ComposeTransition(presenting: false, messageSent: true)
    }
    
    // MARK: - WriteReviewTableViewControllerDelegate methods
    
    func wroteReview(#review: PFObject, writer: PFObject) {
        // Creates dismiss transition
        dismissComposeTransition = WriteReviewTransition(presenting: false, reviewWritten: true)
        
        reviewsSegmentedControl.selectedSegmentIndex = 0
        reviewsSegmentedControlChanged(reviewsSegmentedControl)
        
        var reviewAlreadyExists = false
        for i in 0..<reviewsOfThemReviews.count {
            let existingReview = reviewsOfThemReviews[i]
            if existingReview["Writer"] as! String == self.currentUser.username {
                reviewsOfThemReviews[i] = review
                reviewAlreadyExists = true
                reviewsTable.reloadData()
                break
            }
        }
        
        if !reviewAlreadyExists {
            reviewsOfThemReviews.insert(review, atIndex: 0)
            reviewsOfThemUsers.insert(writer, atIndex: 0)
            
            // Inserts first table cell
            reviewsTable.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 1)], withRowAnimation: .Automatic)
        }
        
        if let selectedIndex = reviewsTable.indexPathForSelectedRow() {
            reviewsTable.deselectRowAtIndexPath(selectedIndex, animated: true)
        }
    }
    
    func canceledWriteReview() {
        dismissComposeTransition = WriteReviewTransition(presenting: false, reviewWritten: false)
        
        if let selectedIndex = reviewsTable.indexPathForSelectedRow() {
            reviewsTable.deselectRowAtIndexPath(selectedIndex, animated: true)
        }
    }
    
    // MARK: - AddPaymentTableViewController methods
    
    func addedPayment(payment: PFObject, user: PFObject) {
        dismissComposeTransition = AddPaymentTransition(presenting: false, paymentAdded: true)
        
        paymentsSegmentedControl.selectedSegmentIndex = 0
        
        self.noPaymentsLabel.text = "No Requests"
        paymentsSegmentedControlChanged(self.paymentsSegmentedControl)
        
        if !loadingPaymentsIndicatorView.isAnimating() {
            paymentsTable.alpha = 1.0
            paymentsTable.hidden = false
            paymentsTable.userInteractionEnabled = true
            noPaymentsLabel.alpha = 0.0
            noPaymentsLabel.hidden = true
        }
        
        myPayments.insert(payment, atIndex: 0)
        
        paymentsTable.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Automatic)
        
        NSNotificationCenter.defaultCenter().postNotificationName("Reload Payments", object: nil)
    }
    
    func canceledPayment() {
        dismissComposeTransition = AddPaymentTransition(presenting: false, paymentAdded: false)
    }
    
    
    // MARK: - UIViewControllerTransitioningDelegate methods
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented is FriendOptionsViewController {
            return FriendOptionsTransition(presenting: true, sourceButtonFrame: self.view.convertRect(friendOptionsButton.frame, fromView: profileInfoView), profileType: profileType)
        }
        else if let composeMessageNavVC = presented as? UINavigationController {
            if composeMessageNavVC.topViewController is ComposeMessageViewController {
                return ComposeTransition(presenting: true)
            }
            else if composeMessageNavVC.topViewController is WriteReviewTableViewController {
                return WriteReviewTransition(presenting: true)
            }
            else if composeMessageNavVC.topViewController is AddPaymentTableViewController {
                return AddPaymentTransition(presenting: true)
            }
        }
        
        return nil
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if dismissed is FriendOptionsViewController {
            return FriendOptionsTransition(presenting: false, sourceButtonFrame: self.view.convertRect(friendOptionsButton.frame, fromView: profileInfoView), profileType: profileType)
        }
        else {
            return dismissComposeTransition
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Show Friend Options" {
            let friendOptionsVC = segue.destinationViewController as! FriendOptionsViewController
            friendOptionsVC.modalPresentationStyle = .Custom
            friendOptionsVC.transitioningDelegate = self
            friendOptionsVC.user = user
            friendOptionsVC.profileType = self.profileType
            friendOptionsVC.delegate = self
        }
        else if segue.identifier == "Send Message" {
            let navVC = segue.destinationViewController as! UINavigationController
            navVC.transitioningDelegate = self
            navVC.modalPresentationStyle = .Custom
            
            let composeMessageVC = navVC.topViewController as! ComposeMessageViewController
            composeMessageVC.recipient = user
            composeMessageVC.delegate = self
        }
        else if segue.identifier == "Write Review" {
            let navVC = segue.destinationViewController as! UINavigationController
            navVC.transitioningDelegate = self
            navVC.modalPresentationStyle = .Custom
            
            let writeReviewVC = navVC.topViewController as! WriteReviewTableViewController
            writeReviewVC.user = user!
            writeReviewVC.delegate = self
            
            for review in reviewsOfThemReviews {
                if review["Writer"] as! String == self.currentUser.username {
                    writeReviewVC.review = review
                    break
                }
            }
        }
        else if segue.identifier == "Request Payment" {
            let navVC = segue.destinationViewController as! UINavigationController
            navVC.transitioningDelegate = self
            navVC.modalPresentationStyle = .Custom
            
            let addPaymentVC = navVC.topViewController as! AddPaymentTableViewController
            addPaymentVC.friend = user!
            addPaymentVC.delegate = self
        }
    }
    
}
