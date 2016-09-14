//
//  AddPaymentTransition.swift
//  
//
//  Created by Anant Jain on 7/27/15.
//
//

import UIKit

class AddPaymentTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    var presenting: Bool
    var paymentAdded: Bool
    
    init(presenting: Bool, paymentAdded: Bool = false) {
        self.presenting = presenting
        self.paymentAdded = paymentAdded
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
            
            toView.frame = CGRect(x: 20, y: 40, width: UIScreen.mainScreen().bounds.size.width - 40, height: UIScreen.mainScreen().bounds.size.height - 80)
            toView.alpha = 0.0
            toView.transform = CGAffineTransformMakeScale(1.1, 1.1)
            toView.layer.cornerRadius = 10
            toView.layer.masksToBounds = true
            
            let toVC = (transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! UINavigationController).topViewController as! AddPaymentTableViewController
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
            let fromVC = (transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! UINavigationController).topViewController as! AddPaymentTableViewController
            let darkView = fromVC.shadowView!
            
            if self.paymentAdded {
                UIView.animateWithDuration(self.transitionDuration(transitionContext) * 2.5, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
                    darkView.alpha = 0.0
                    
                    fromView.transform = CGAffineTransformMakeTranslation(0, -(UIScreen.mainScreen().bounds.size.height - 40))
                    
                    }, completion: { (completed) -> Void in
                        transitionContext.completeTransition(true)
                })
                
            }
            else {
                UIView.animateWithDuration(self.transitionDuration(transitionContext), delay: 0, options: .CurveEaseOut, animations: { () -> Void in
                    darkView.alpha = 0.0
                    fromView.alpha = 0.0
                    fromView.transform = CGAffineTransformMakeScale(0.9, 0.9)
                    }, completion: { (completed) -> Void in
                        transitionContext.completeTransition(true)
                })
            }
        }
    }
}
