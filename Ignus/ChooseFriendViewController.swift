//
//  ChooseFriendViewController.swift
//  
//
//  Created by Anant Jain on 7/28/15.
//
//

import UIKit

protocol ChooseFriendViewControllerDelegate {
    func choseFriend(friend: PFObject)
}

class ChooseFriendViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var friendsCollectionView: UICollectionView!
    @IBOutlet weak var loadingFriendsIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noFriendsLabel: UILabel!
    
    let currentUser = PFUser.currentUser()
    
    var friendsList = [PFObject]()
    
    var cells = [UICollectionViewCell]()
    
    var delegate: ChooseFriendViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Loads friends
        self.loadingFriendsIndicator.startAnimating()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), { () -> Void in
            let friendsObjectQuery = PFQuery(className: "Friends")
            friendsObjectQuery.whereKey("User", equalTo: self.currentUser.username)
            var tempFriendsList = [PFObject]()
            if let friendObject = friendsObjectQuery.getFirstObject() {
                let friendUsernames = friendObject["Friends"] as! [String]
                for username in friendUsernames {
                    let friendsQuery = PFUser.query()
                    friendsQuery.whereKey("username", equalTo: username)
                    tempFriendsList.append(friendsQuery.getFirstObject())
                }
            }
            
            // Sorts friends by first name
            self.friendsList = sorted(tempFriendsList, { ($0["FirstName"] as! String) < ($1["FirstName"] as! String)})
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if self.friendsList.count == 0 {
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.loadingFriendsIndicator.alpha = 0.0
                        self.noFriendsLabel.alpha = 1.0
                        }, completion: { (completed) -> Void in
                            self.loadingFriendsIndicator.stopAnimating()
                    })
                }
                else {
                    self.friendsCollectionView.reloadData()
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        self.loadingFriendsIndicator.alpha = 0.0
                        self.friendsCollectionView.alpha = 1.0
                        }, completion: { (completed) -> Void in
                            self.loadingFriendsIndicator.stopAnimating()
                    })
                }
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Collection view data source methods
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendsList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Friend Cell", forIndexPath: indexPath)
        
        let friendObject = friendsList[indexPath.row]
        
        let profileImage = cell.viewWithTag(1) as! UIImageView
        let nameLabel = cell.viewWithTag(2) as! UILabel
        let usernameLabel = cell.viewWithTag(3) as! UILabel
        
        let profileFile = friendObject["Profile"] as! PFFile
        profileFile.getDataInBackgroundWithBlock { (data, error) -> Void in
            if error == nil {
                UIView.transitionWithView(profileImage, duration: 0.3, options: .TransitionCrossDissolve, animations: { () -> Void in
                    profileImage.image = UIImage(data: data)
                }, completion: nil)
            }
        }
        
        nameLabel.text = friendObject["FirstName"] as? String
        usernameLabel.text = friendObject["username"] as? String
        
        cells.append(cell)
        
        return cell
    }

    // MARK: - Collection view delegate methods
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let highlightView = cells[indexPath.row].viewWithTag(4)!
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            highlightView.alpha = 1.0
        })
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        cells[indexPath.row].viewWithTag(4)!.alpha = 1.0
        
        self.delegate?.choseFriend(friendsList[indexPath.row])
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let highlightView = cells[indexPath.row].viewWithTag(4)!
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            highlightView.alpha = 0.0
        })
    }
    

}
