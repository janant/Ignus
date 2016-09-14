//
//  FriendOptionsTransition.swift
//  Ignus
//
//  Created by Anant Jain on 3/26/15.
//  Copyright (c) 2015 Anant Jain. All rights reserved.
//

import UIKit

class FriendOptionsTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var presenting: Bool
    var sourceButtonFrame: CGRect
    var profileType: String
    
    init(presenting: Bool, sourceButtonFrame: CGRect, profileType: String) {
        self.presenting = presenting
        self.sourceButtonFrame = sourceButtonFrame
        self.profileType = profileType
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return self.presenting ? 0.5 : 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let screenSize = UIScreen.mainScreen().bounds
        
        let darkView = UIView(frame: screenSize)
        darkView.backgroundColor = UIColor.blackColor()
        
        darkView.addGestureRecognizer(UITapGestureRecognizer(target: transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!, action: "dismiss"))
        
        if (self.presenting) {
            let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! FriendOptionsViewController
            let containerView = transitionContext.containerView()
            
            fromVC.view.userInteractionEnabled = false
            
            darkView.alpha = 0.0
            
            switch (profileType) {
            case "Current User":
                toVC.view.frame = CGRect(x: CGRectGetMidX(screenSize) - 125, y: CGRectGetMidY(screenSize) - 100  , width: 250, height: 200)
            case "Friend":
                toVC.view.frame = CGRect(x: CGRectGetMidX(screenSize) - 125, y: CGRectGetMidY(screenSize) - 200  , width: 250, height: 400)
            case "User":
                toVC.view.frame = CGRect(x: CGRectGetMidX(screenSize) - 125, y: CGRectGetMidY(screenSize) - 50  , width: 250, height: 100)
            case "Pending Friend":
                toVC.view.frame = CGRect(x: CGRectGetMidX(screenSize) - 125, y: CGRectGetMidY(screenSize) - 50  , width: 250, height: 100)
            case "Requested Friend":
                toVC.view.frame = CGRect(x: CGRectGetMidX(screenSize) - 125, y: CGRectGetMidY(screenSize) - 100  , width: 250, height: 200)
            default:
                break
            }
            
            toVC.view.layer.cornerRadius = 10
            toVC.view.layer.masksToBounds = true
            
            toVC.view.alpha = 0.0
            toVC.view.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(sourceButtonFrame.size.width / screenSize.size.width, sourceButtonFrame.size.height / screenSize.size.height), CGAffineTransformMakeTranslation(CGRectGetMidX(sourceButtonFrame) - CGRectGetMidX(toVC.view.frame), CGRectGetMidY(sourceButtonFrame) - CGRectGetMidY(toVC.view.frame)))
            
            containerView.addSubview(darkView)
            containerView.addSubview(toVC.view)
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                darkView.alpha = 0.5
            })
            
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                toVC.view.transform = CGAffineTransformIdentity
                toVC.view.alpha = 1.0
                }, completion: { (completed: Bool) -> Void in
                    toVC.darkView = darkView
                    transitionContext.completeTransition(true)
            })
        }
        else {
            let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! FriendOptionsViewController
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            let containerView = transitionContext.containerView()
            
            fromVC.view.userInteractionEnabled = false
            
            darkView.alpha = 0.5
            
            fromVC.view.userInteractionEnabled = false
            
            containerView.addSubview(fromVC.view)
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                fromVC.darkView.alpha = 0.0
            })
            
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                fromVC.view.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(self.sourceButtonFrame.size.width / screenSize.size.width, self.sourceButtonFrame.size.height / screenSize.size.height), CGAffineTransformMakeTranslation(CGRectGetMidX(self.sourceButtonFrame) - CGRectGetMidX(fromVC.view.frame), CGRectGetMidY(self.sourceButtonFrame) - CGRectGetMidY(fromVC.view.frame)))
                fromVC.view.alpha = 0.0
                }, completion: { (completed: Bool) -> Void in
                    toVC.view.userInteractionEnabled = true
                    transitionContext.completeTransition(true)
            })
        }
    }
}