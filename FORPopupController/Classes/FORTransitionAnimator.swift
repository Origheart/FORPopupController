//
//  ForTransitionAnimator.swift
//  FORPopupController
//
//  Created by Origheart on 16/5/3.
//  Copyright © 2016年 Origheart. All rights reserved.
//

import UIKit

class FORTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - Property
    
    let isPresenting: Bool
    let duration: NSTimeInterval = 0.3
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        super.init()
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return self.duration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            animatePresentationWithTransitionContext(transitionContext)
        } else {
            animateDismissalWithTransitionContext(transitionContext)
        }
    }
    
    // MARK: - Helper methods
    
    func animatePresentationWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let presentedController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextToViewKey),
            let containerView = transitionContext.containerView()
        else {
            return
        }
        
        presentedControllerView.frame = transitionContext.finalFrameForViewController(presentedController)
        presentedControllerView.alpha = 0.0
        containerView.addSubview(presentedControllerView)
        
        UIView.animateWithDuration(self.duration, animations: { 
            presentedControllerView.alpha = 1.0
            }) { (completed) in
                transitionContext.completeTransition(completed)
        }
    }
    
    func animateDismissalWithTransitionContext(transitionContext: UIViewControllerContextTransitioning) {
        guard
            let presentedControllerView = transitionContext.viewForKey(UITransitionContextFromViewKey)
        else {
            return
        }
        
        UIView.animateWithDuration(self.duration, animations: {
            presentedControllerView.alpha = 0.0
        }) { (completed) in
            transitionContext.completeTransition(completed)
        }
    }
    
}
