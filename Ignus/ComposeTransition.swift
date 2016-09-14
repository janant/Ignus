//
//  ComposeTransition.swift
//  
//
//  Created by Anant Jain on 7/27/15.
//
//

import UIKit

class ComposeTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var presenting: Bool
    var messageSent: Bool
    
    init(presenting: Bool, messageSent: Bool = false) {
        self.presenting = presenting
        self.messageSent = messageSent
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.15
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
            let toView = transitionContext.viewForKey(UITransitionContextToViewKey)!
            let containerView = transitionContext.containerView()
            
            let darkView = UIView()
            darkView.frame = UIScreen.mainScreen().bounds
            darkView.backgroundColor = UIColor.blackColor()
            darkView.alpha = 0.0
            
            toView.frame = CGRect(x: 20, y: 40, width: UIScreen.mainScreen().bounds.size.width - 40, height: 244)
            toView.alpha = 0.0
            toView.transform = CGAffineTransformMakeScale(1.2, 1.2)
            toView.layer.cornerRadius = 10
            toView.layer.masksToBounds = true
            
            let toVC = (transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! UINavigationController).topViewController as! ComposeMessageViewController
            toVC.shadowView = darkView
            
            containerView.addSubview(darkView)
            containerView.addSubview(toView)
            
            UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                darkView.alpha = 0.7
                toView.alpha = 1.0
                toView.transform = CGAffineTransformIdentity
            }, completion: { (completed) -> Void in
                transitionContext.completeTransition(true)
            })
        }
        else {
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let fromVC = (transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! UINavigationController).topViewController as! ComposeMessageViewController
            let darkView = fromVC.shadowView!
            
            if self.messageSent {
                UIView.animateWithDuration(self.transitionDuration(transitionContext) * 1.5, delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                    darkView.alpha = 0.0
                    fromView.transform = CGAffineTransformMakeTranslation(0, -288)
                    }, completion: { (completed) -> Void in
                        transitionContext.completeTransition(true)
                })
                
            }
            else {
                UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                    darkView.alpha = 0.0
                    fromView.alpha = 0.0
                    fromView.transform = CGAffineTransformMakeScale(0.8, 0.8)
                    }, completion: { (completed) -> Void in
                        transitionContext.completeTransition(true)
                })
            }
        }
    }
}
