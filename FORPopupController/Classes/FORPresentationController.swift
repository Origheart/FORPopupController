//
//  FORPresentationController.swift
//  FORPopupController
//
//  Created by Origheart on 16/5/3.
//  Copyright © 2016年 Origheart. All rights reserved.
//

import UIKit

class FORPresentationController: UIPresentationController {
    
    // MARK: - Property
    
    lazy var dimmingView: UIView = {
        let view = UIView(frame: self.containerView!.bounds)
        view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.8)
        view.alpha = 0.0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    // MARK: - Private methods
    
    @objc func dismiss() {
        let presented: FORPopupController = self.presentedViewController as! FORPopupController
        presented.dismiss()
    }
    
    // MARK: - Override
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView, let presentedView = presentedView() else {return}
        dimmingView.frame = containerView.bounds
        containerView.addSubview(dimmingView)
        containerView.addSubview(presentedView)
        
        if let transitionCoordinator = self.presentingViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ (context) in
                self.dimmingView.alpha = 1.0
                }, completion: nil)
        }
    }
    
    override func presentationTransitionDidEnd(completed: Bool) {
        if !completed {
            self.dimmingView.removeFromSuperview()
        }
        let presented: FORPopupController = self.presentedViewController as! FORPopupController
        presented.presentationTransitionDidEnd = true
    }
    
    override func dismissalTransitionWillBegin() {
        if let transitionCoordinator = self.presentingViewController.transitionCoordinator() {
            transitionCoordinator.animateAlongsideTransition({ (context) in
                self.dimmingView.alpha = 0.0
                }, completion: nil)
        }
    }
    
    override func dismissalTransitionDidEnd(completed: Bool) {
        if completed {
            self.dimmingView.removeFromSuperview()
        }
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        guard let containerView = containerView else {return CGRectZero}
        
        let presented: FORPopupController = self.presentedViewController as! FORPopupController
        if presented.showLoading {
            presented.renderLoading()
            let frame = containerView.bounds
            let viewFrame = CGRectInset(frame, (frame.size.width - FOR_POPUP_WIDTH) / 2.0, (frame.size.height - FOR_LOADING_HEIGHT) / 2.0)
            return viewFrame
        } else {
            presented.render()
            return CGRectZero
        }
        
    }
    
}
