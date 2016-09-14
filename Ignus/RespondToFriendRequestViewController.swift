//
//  RespondToFriendRequestViewController.swift
//  Ignus
//
//  Created by Anant Jain on 3/20/15.
//  Copyright (c) 2015 Anant Jain. All rights reserved.
//

import UIKit

protocol RespondToFriendRequestViewControllerDelegate {
    func respondedToFriendRequest(response: String)
}

class RespondToFriendRequestViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var responseTable: UITableView!
    var darkView = UIView()
    
    var delegate: RespondToFriendRequestViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        responseTable.separatorEffect = UIVibrancyEffect(forBlurEffect: UIBlurEffect(style: .Light))
        responseTable.scrollEnabled = false
        //responseTable.separatorColor = UIColor.blackColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Response Cell") as! UITableViewCell
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Accept"
            cell.textLabel?.textColor = UIColor.greenColor()
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Decline"
            cell.textLabel?.textColor = UIColor(red: 1.0, green: 82 / 255.0, blue: 72 / 255.0, alpha: 1.0)
        }
        
        cell.backgroundColor = UIColor.clearColor()
        cell.backgroundView = nil
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        cell.selectedBackgroundView = selectedView
        
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if self.delegate != nil {
            dismissViewControllerAnimated(true, completion: { () -> Void in
                if indexPath.row == 0 {
                    self.delegate!.respondedToFriendRequest("Accepted")
                }
                else if indexPath.row == 1 {
                    self.delegate!.respondedToFriendRequest("Declined")
                }
            })
        }
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
