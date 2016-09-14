//
//  PrivacyPolicyViewController.swift
//  Ignus
//
//  Created by Anant Jain on 8/4/15.
//  Copyright (c) 2015 Anant Jain. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.sharedApplication().statusBarStyle = .Default
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 18)!]
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 0.0, green: 122/255.0, blue: 1.0, alpha: 1.0), NSFontAttributeName: UIFont(name: "Gotham-Medium", size: 17)!], forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
