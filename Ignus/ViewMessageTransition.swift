//
//  ViewMessageTransition.swift
//  
//
//  Created by Anant Jain on 7/28/15.
//
//

import UIKit

class ViewMessageTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var presenting: Bool
    var messageSent: Bool
    var sourceCellFrame: CGRect
    
    init(presenting: Bool, sourceCellFrame: CGRect, messageSent: Bool = false) {
        self.presenting = presenting
        self.messageSent = messageSent
        self.sourceCellFrame = sourceCellFrame
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
            toView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(sourceCellFrame.size.width / toView.frame.size.width, sourceCellFrame.size.height / toView.frame.size.height), CGAffineTransformMakeTranslation(CGRectGetMidX(sourceCellFrame) - CGRectGetMidX(toView.frame), CGRectGetMidY(sourceCellFrame) - CGRectGetMidY(toView.frame)))
            toView.layer.cornerRadius = 10
            toView.layer.masksToBounds = true
            
            let toVC = (transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey) as! UINavigationController).topViewController as! ViewMessageViewController
            toVC.shadowView = darkView
            
            containerView.addSubview(darkView)
            containerView.addSubview(toView)
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                darkView.alpha = 0.5
                toView.alpha = 1.0
            })
            
            UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
                toView.transform = CGAffineTransformIdentity
                }, completion: { (completed: Bool) -> Void in
                    transitionContext.completeTransition(true)
            })
        }
        else {
            let fromView = transitionContext.viewForKey(UITransitionContextFromViewKey)!
            let fromVC = (transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey) as! UINavigationController).viewControllers[0] as! ViewMessageViewController
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
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
                    fromView.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(self.sourceCellFrame.size.width / fromView.frame.size.width, self.sourceCellFrame.size.height / fromView.frame.size.height), CGAffineTransformMakeTranslation(CGRectGetMidX(self.sourceCellFrame) - CGRectGetMidX(fromView.frame), CGRectGetMidY(self.sourceCellFrame) - CGRectGetMidY(fromView.frame)))
                    }, completion: { (completed) -> Void in
                                                
                        transitionContext.completeTransition(true)
                })
            }
        }
    }
}
