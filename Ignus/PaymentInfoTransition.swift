//
//  PaymentInfoTransition.swift
//  Ignus
//
//  Created by Anant Jain on 3/29/15.
//  Copyright (c) 2015 Anant Jain. All rights reserved.
//

import UIKit

class PaymentInfoTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var presenting: Bool
    var sourceCellFrame: CGRect
    
    init(presenting: Bool, cellFrame: CGRect = CGRect()) {
        self.presenting = presenting
        self.sourceCellFrame = cellFrame
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return self.presenting ? 0.5 : 0.25
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let screenSize = UIScreen.mainScreen().bounds
        
        let darkView = UIView(frame: screenSize)
        darkView.backgroundColor = UIColor.blackColor()
        
        if (self.presenting) {
            let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! UINavigationController
            let containerView = transitionContext.containerView()
            
            fromVC.view.userInteractionEnabled = false
            
            darkView.alpha = 0.0
            
            toVC.view.frame = CGRect(x: screenSize.size.width / 12.0, y: screenSize.size.height / 12.0, width: screenSize.size.width * 5.0 / 6.0, height: screenSize.size.height * 5.0 / 6.0)
            toVC.view.layer.cornerRadius = 10
            toVC.view.layer.masksToBounds = true
            
            toVC.view.alpha = 0.0
            toVC.view.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(sourceCellFrame.size.width / toVC.view.frame.size.width, sourceCellFrame.size.height / toVC.view.frame.size.height), CGAffineTransformMakeTranslation(CGRectGetMidX(sourceCellFrame) - CGRectGetMidX(toVC.view.frame), CGRectGetMidY(sourceCellFrame) - CGRectGetMidY(toVC.view.frame)))
            
            containerView.addSubview(darkView)
            containerView.addSubview(toVC.view)
            
            let paymentInfoTVC = toVC.topViewController as! PaymentInfoTableViewController
            
            darkView.addGestureRecognizer(UITapGestureRecognizer(target: paymentInfoTVC, action: "dismiss"))
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                darkView.alpha = 0.5
            })
            
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                toVC.view.transform = CGAffineTransformIdentity
                toVC.view.alpha = 1.0
                }, completion: { (completed: Bool) -> Void in
                    paymentInfoTVC.shadowView = darkView
                    transitionContext.completeTransition(true)
            })
        }
        else {
            let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! UINavigationController
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
            
            fromVC.view.userInteractionEnabled = false
            
            let paymentInfoTVC = fromVC.viewControllers[0] as! PaymentInfoTableViewController
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                paymentInfoTVC.shadowView!.alpha = 0.0
            })
            
            UIView.animateWithDuration(transitionDuration(transitionContext), delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                
                if self.sourceCellFrame == CGRect() {
                    fromVC.view.transform = CGAffineTransformMakeScale(0.85, 0.85)
                }
                else {
                    fromVC.view.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(self.sourceCellFrame.size.width / fromVC.view.frame.size.width, self.sourceCellFrame.size.height / fromVC.view.frame.size.height), CGAffineTransformMakeTranslation(CGRectGetMidX(self.sourceCellFrame) - CGRectGetMidX(fromVC.view.frame), CGRectGetMidY(self.sourceCellFrame) - CGRectGetMidY(fromVC.view.frame)))
                }
                
                fromVC.view.alpha = 0.0
                }, completion: { (completed: Bool) -> Void in
                    toVC.view.userInteractionEnabled = true
                    (((toVC as! UITabBarController).viewControllers![0] as! UINavigationController).topViewController as! PaymentsViewController).viewDidAppear(true)
                    transitionContext.completeTransition(true)
            })
        }
    }
}
