//
//  RatePaymentTableViewController.swift
//  Ignus
//
//  Created by Anant Jain on 2/8/15.
//  Copyright (c) 2015 Anant Jain. All rights reserved.
//

import UIKit

protocol RatePaymentTableViewControllerDelegate {
    func finishedRating(#rating: String)
}

class RatePaymentTableViewController: UITableViewController {
    
    @IBOutlet weak var greenCell: UITableViewCell!
    @IBOutlet weak var yellowCell: UITableViewCell!
    @IBOutlet weak var redCell: UITableViewCell!
    
    enum Rating {
        case Green, Yellow, Red, None
        
        init(indexPath: NSIndexPath) {
            switch indexPath.row {
            case 0:
                self = .Green
            case 1:
                self = .Yellow
            case 2:
                self = .Red
            default:
                self = .None
            }
        }
    }
    
    var rating = Rating.None
    
    var delegate: RatePaymentTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.3)
        greenCell.selectedBackgroundView = backgroundView
        yellowCell.selectedBackgroundView = backgroundView
        redCell.selectedBackgroundView = backgroundView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneRating(sender: AnyObject) {
        var ratingString = "Undecided"
        
        if rating == .Green {
            ratingString = "Green"
        }
        else if rating == .Yellow {
            ratingString = "Yellow"
        }
        else if rating == .Red {
            ratingString = "Red"
        }
        
        self.delegate?.finishedRating(rating: ratingString)
    }
    
    // MARK: - Table view delegate methods
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        rating = Rating(indexPath: indexPath)
        
        greenCell.accessoryType = rating == .Green ? .Checkmark : .None
        yellowCell.accessoryType = rating == .Yellow ? .Checkmark : .None
        redCell.accessoryType = rating == .Red ? .Checkmark : .None
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        self.navigationItem.rightBarButtonItem!.enabled = true
    }
    
    override func tableView(tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let footer = view as! UITableViewHeaderFooterView
        footer.textLabel.font = UIFont(name: "Gotham-Book", size: 13)
    }
    
}
