//
//  ViewController.swift
//  FORPopupController
//
//  Created by Origheart on 16/5/3.
//  Copyright © 2016年 Origheart. All rights reserved.
//

import UIKit
import FORPopupController

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    var popupView: FORPopupController! = nil
    @IBAction func show(sender: AnyObject) {
//        let vc = MyController()
//        self.presentViewController(vc, animated: true, completion: nil)
        
//        showLoading()
        showWithoutLoading()
        
    }
    
    func showLoading() {
        self.popupView = FORPopupController.init(showLoading: true)
        configurePopupView()
        self.performSelector(#selector(render), withObject: nil, afterDelay: 5)
        self.presentViewController(popupView, animated: true, completion: nil)
    }
    
    func showWithoutLoading() {
        self.popupView = FORPopupController(showLoading: false)
        configurePopupView()
        self.presentViewController(popupView, animated: true, completion: nil)
    }
    
    func render() {
        self.popupView.render()
    }
    
    func configurePopupView() {
        popupView.addImageWithHeight(200) { (imageView) in
            imageView.image = UIImage(named: "pic.jpg")
        }
        
        popupView.addTitle("剑桥大学")
        
        // 假如文字很长
        popupView.addDetail("TIMES排名：1\nQS排名：3\n学校特色：\n最古老的大学-知名学府\n欧洲科学院-学院制管理\n导师制教学-文化学术氛围浓厚") { (detailLabel) in
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 15.0
            let detail = NSMutableAttributedString(string: "TIMES排名：1\nQS排名：3", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14), NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: style])
            let style1 = NSMutableParagraphStyle()
            style1.lineSpacing = 10.0
            let features = NSMutableAttributedString(string: "学校特色：\n最古老的大学-知名学府最古老的大学-知名学府\n欧洲科学院-学院制管理\n导师制教学-文化学术氛围浓厚", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14), NSForegroundColorAttributeName: UIColor.blackColor(), NSParagraphStyleAttributeName: style1])
            detail.appendAttributedString(features)
            detailLabel.attributedText = detail
        }
        
        //        popupView.addDetail("TIMES排名：1\nQS排名：3\n学校特色：\n最古老的大学-知名学府\n欧洲科学院-学院制管理\n导师制教学-文化学术氛围浓厚", configurationHandler: nil)
        
        let action = FORPopupAction(title: "查看学校详情", style: .Highlight) { (myAction) in
            print("查看学校详情")
        }
        popupView.addAction(action)
    }
    
}

