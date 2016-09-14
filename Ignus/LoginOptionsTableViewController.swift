//
//  LoginOptionsTableViewController.swift
//  Ignus
//
//  Created by Anant Jain on 8/4/15.
//  Copyright (c) 2015 Anant Jain. All rights reserved.
//

import UIKit

class LoginOptionsTableViewController: UITableViewController {
    
    var automaticLoginEnabled = NSUserDefaults.standardUserDefaults().boolForKey("AutomaticLoginEnabled") {
        didSet {
            NSUserDefaults.standardUserDefaults().setBool(automaticLoginEnabled, forKey: "AutomaticLoginEnabled")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    let automaticLoginSwitch = UISwitch()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        automaticLoginSwitch.on = automaticLoginEnabled
        
        automaticLoginSwitch.addTarget(self, action: "toggleAutomaticLogin:", forControlEvents: .ValueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func toggleAutomaticLogin(sender: UISwitch) {
        automaticLoginEnabled = sender.on
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Setting Cell", forIndexPath: indexPath) as! UITableViewCell

        cell.textLabel?.text = "Automatic Login"
        cell.accessoryView = automaticLoginSwitch

        return cell
    }
}
