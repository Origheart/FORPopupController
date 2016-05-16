//
//  FORPopupController.swift
//  FORPopupController
//
//  Created by Origheart on 16/5/3.
//  Copyright © 2016年 Origheart. All rights reserved.
//

import UIKit
import SnapKit

@objc public enum FORPopupActionStyle : Int {
    
    case Default
    case Highlight
}

public class FORPopupAction: NSObject {
    public convenience init(title: String?, style: FORPopupActionStyle, handler: ((FORPopupAction) -> Void)?) {
        self.init()
        self.title = title
        self.style = style
        self.handler = handler
    }
    
    override init() {
        self.style = .Default
        super.init()
        
    }
    
    private var title: String?
    private var style: FORPopupActionStyle
    private var handler: ((FORPopupAction) -> Void)?
}

public class FORPopupController: UIViewController, UIViewControllerTransitioningDelegate {
    
    // MARK: - Internel Classes
    
    private class FORPopupImage {
        var height: CGFloat
        var configurationHandler: ((UIImageView) -> Void)
        init(height: CGFloat, configurationHandler: ((UIImageView) -> Void)) {
            self.height = height
            self.configurationHandler = configurationHandler
        }
    }
    
    // MARK: - Properties
    
    public var showLoading: Bool = false
    public var presentationTransitionDidEnd: Bool = false {
        didSet {
            if shouldRenderContent {
                renderContent()
            }
        }
    }
    private var shouldRenderContent: Bool = false
    private var initialCenter: CGPoint?
    
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        return indicator
    }()
    
    private lazy var cancel: UIButton = {
        let button: UIButton = UIButton.for_buttonWithTarget(self, action: #selector(dismiss))
        button.setTitle("取消", forState: .Normal)
        button.setTitleColor(UIColor.colorFromHexColor(FOR_BUTTON_HIGHLIGHT_COLOR), forState: .Normal)
        return button
    }()
    
    private var image: FORPopupImage?
    private var popupTitle: String?
    private var detail: String?
    private var detailLabelConfigurationHandler: ((UILabel) -> Void)?
    private var actions: [FORPopupAction]? = []
    
    // MARK: - Initialize
    
    public init(showLoading: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.showLoading = showLoading
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    public func addAction(action: FORPopupAction) {
        self.actions?.append(action)
    }
    
    public func setImageWithHeight(height:CGFloat, configurationHandler:((UIImageView) -> Void)) {
        self.image = FORPopupImage(height: height, configurationHandler: configurationHandler)
    }
    
    public func setPopupTitle(title: String) {
        self.popupTitle = title
    }
    
    public func setDetail(detail: String, configurationHandler: ((UILabel) -> Void)?) {
        self.detail = detail
        self.detailLabelConfigurationHandler = configurationHandler
    }
    
    public func render() {
        if presentationTransitionDidEnd {
            renderContent()
        } else {
            shouldRenderContent = true
        }
    }
    
    public func renderLoading() {
        if shouldRenderContent {
            return
        }
        clearSubviews()
        self.view.addSubview(self.indicator)
        self.view.addSubview(self.cancel)
        self.indicator.startAnimating()
        
        self.cancel.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(0)
            make.height.equalTo(FOR_BUTTON_HEIGHT)
        }
        
        self.indicator.snp_makeConstraints { (make) in
            make.centerX.equalTo(self.view.snp_centerX)
            make.centerY.equalTo(self.view.snp_centerY).offset(-FOR_BUTTON_HEIGHT / 2.0)
        }
    }
    
    @objc func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Private methods
    
    private func initialize() {
        self.modalPresentationStyle = .Custom
        self.transitioningDelegate = self
        self.view.layer.cornerRadius = FOR_CORNER_RADIUS
        self.view.layer.masksToBounds = true
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    private func clearSubviews() {
        for subview in self.view.subviews {
            subview.removeFromSuperview()
        }
    }
    
    private func renderContent() {
        
        clearSubviews()
        
        self.view.snp_makeConstraints { (make) in
            make.width.equalTo(FOR_POPUP_WIDTH)
        }
        //设置当视图要变小时，视图的压缩改变方式，是水平缩小还是垂直缩小，并设置优先权
        self.view.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        //与上边相反是视图的放大改变方式
        self.view.setContentHuggingPriority(UILayoutPriorityFittingSizeLevel, forAxis: .Vertical)
        
        var lastAttribute = self.view.snp_top
        if let image = self.image {
            let imageView = UIImageView()
            self.view.addSubview(imageView)
            image.configurationHandler(imageView)
            imageView.snp_makeConstraints(closure: { (make) in
                make.left.top.right.equalTo(0)
                make.height.equalTo(image.height)
            })
            lastAttribute = imageView.snp_bottom
        }
        
        if let titleStr = self.popupTitle {
            if titleStr.characters.count > 0 {
                let titleLabel = UILabel.titleLabelWithText(titleStr)
                self.view.addSubview(titleLabel)
                titleLabel.snp_makeConstraints(closure: { (make) in
                    make.top.equalTo(lastAttribute).offset(15)
                    make.left.right.equalTo(self.view).inset(UIEdgeInsetsMake(0, FOR_INNER_MARGIN, 0, FOR_INNER_MARGIN))
                })
                lastAttribute = titleLabel.snp_bottom
            }
        }
        
        if let detail = self.detail where detail.characters.count > 0 {
            let detailLabel = UILabel.detailLabelWithText(detail)
            self.view.addSubview(detailLabel)
            if let handler = self.detailLabelConfigurationHandler {
                handler(detailLabel)
            }
            detailLabel.snp_makeConstraints(closure: { (make) in
                make.top.equalTo(lastAttribute).offset(15)
                make.left.right.equalTo(self.view).inset(UIEdgeInsetsMake(0, FOR_INNER_MARGIN, 0, FOR_INNER_MARGIN))
            })
            lastAttribute = detailLabel.snp_bottom
        }
        
        if let actions = self.actions where actions.count > 0 {
            let buttonsContainer = UIView()
            self.view.addSubview(buttonsContainer)
            buttonsContainer.snp_makeConstraints(closure: { (make) in
                make.top.equalTo(lastAttribute).offset(20)
                make.left.right.equalTo(self.view)
            })
            
            var firstButton: UIButton?
            var lastButton: UIButton?
            for index in 0 ..< actions.count {
                let action = actions[index]
                let button = UIButton.for_buttonWithTarget(self, action: #selector(buttonAction(_:)))
                buttonsContainer.addSubview(button)
                button.tag = index
                button.setTitle(action.title, forState: .Normal)
                let titleColor = action.style == .Highlight ? FOR_BUTTON_HIGHLIGHT_COLOR : FOR_BUTTON_NORMAL_COLOR
                button.setTitleColor(UIColor.colorFromHexColor(titleColor), forState: .Normal)
                
                button.snp_makeConstraints(closure: { (make) in
                    make.left.right.equalTo(buttonsContainer)
                    make.height.equalTo(FOR_BUTTON_HEIGHT)
                    if nil == firstButton {
                        firstButton = button
                        make.top.equalTo(buttonsContainer.snp_top).offset(-FOR_SPLIT_WIDTH)
                    } else {
                        make.top.equalTo(lastButton!.snp_bottom).offset(-FOR_SPLIT_WIDTH)
                    }
                    lastButton = button
                })
            }
            lastButton?.snp_updateConstraints(closure: { (make) in
                make.bottom.equalTo(buttonsContainer.snp_bottom)
            })
            lastAttribute = buttonsContainer.snp_bottom
        }
        
        self.view.snp_updateConstraints { (make) in
            make.bottom.equalTo(lastAttribute)
            if let superview = self.view.superview?.superview {
                make.center.equalTo((superview.snp_center))
                make.height.lessThanOrEqualTo(superview).priorityLow()
            } else {
                print("self.view.superview.superview is nil")
            }
        }
        
        self.view.setNeedsUpdateConstraints()
        self.view.updateConstraintsIfNeeded()
        if showLoading {
            UIView.animateWithDuration(0.1) {
                self.view.layoutIfNeeded()
            }
        }
        
        addPanGesture()
        
    }
    
    private func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(move(_:)))
        self.view.userInteractionEnabled = true
        self.view.addGestureRecognizer(panGesture)
    }
    
    private func moveToScreenCenter() {
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            self.view.center = self.initialCenter!
            }, completion: nil)
    }
    
    private func moveToDismiss() {
        UIView.animateWithDuration(0.3, delay: 0.0, options: .CurveEaseOut, animations: {
            self.view.center = CGPointMake(self.initialCenter!.x, -self.view.frame.size.height)
        }) { (completed) in
            if completed {
                self.dismiss()
            }
        }
    }
    
    @objc private func move(gesture: UIPanGestureRecognizer) {
        
        let delta = gesture.translationInView(self.view?.superview)
        var center = self.view.center
        center.y += delta.y
        self.view.center = center
        gesture.setTranslation(CGPointZero, inView: self.view.superview)
        
        if gesture.state == .Began {
            initialCenter = self.view.center
        } else if gesture.state == .Ended {
            // 判断临界值
            if center.y <= FOR_SCREEN_SIZE.height * 0.35 {
                moveToDismiss()
            } else {
                moveToScreenCenter()
            }
        } else if gesture.state == .Cancelled {
            moveToScreenCenter()
        }
        
    }
    
    @objc private func buttonAction(button: UIButton) {
        let action = actions![button.tag]
        dismissViewControllerAnimated(true) {
            action.handler!(action)
        }
    }
    
    // MARK: - UIViewControllerTransitioningDelegate
    
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        if presented == self {
            return FORPresentationController(presentedViewController: presented, presentingViewController: presenting)
        }
        return nil
    }
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented == self {
            return FORTransitionAnimator(isPresenting: true)
        }
        return nil
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return FORTransitionAnimator(isPresenting: false)
        }
        return nil
    }
    
}

extension UIButton {
    class func for_buttonWithTarget(target: AnyObject, action: Selector) -> UIButton {
        let button = UIButton(type: .Custom)
        button.addTarget(target, action: action, forControlEvents: .TouchUpInside)
        button.exclusiveTouch = true
        button.layer.borderColor = UIColor.colorFromHexColor(FOR_SPLIT_COLOR).CGColor
        button.layer.borderWidth = FOR_SPLIT_WIDTH
        return button
    }
}

extension UIColor {
    class func colorFromHexColor(rgbValue: UInt) -> UIColor {
        return UIColor(
            red:    CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green:  CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue:   CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha:  CGFloat(1.0)
        )
    }
}

extension UILabel {
    class func titleLabelWithText(text: String) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.colorFromHexColor(FOR_TITLE_COLOR)
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(FOR_TITLE_FONT)
        label.numberOfLines = 0
        label.text = text
        return label
    }
    
    class func detailLabelWithText(text: String) -> UILabel {
        let label = UILabel()
        label.textColor = UIColor.colorFromHexColor(FOR_DETAIL_COLOR)
        label.textAlignment = .Left
        label.font = UIFont.systemFontOfSize(FOR_DETAIL_FONT)
        label.numberOfLines = 0
        label.text = text
        return label
    }
}

