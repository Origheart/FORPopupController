//
//  MyController.m
//  FORPopupController
//
//  Created by Origheart on 16/5/5.
//  Copyright © 2016年 CocoaPods. All rights reserved.
//

#import "MyController.h"
#import "FORPopupController_Example-Swift.h"
@import FORPopupController;

@implementation MyController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    FORPopupController* popupView = [[FORPopupController alloc] initWithShowLoading:YES];
    [self presentViewController:popupView animated:YES completion:nil];
    
    FORPopupAction* action = [[FORPopupAction alloc] initWithTitle:@"ok" style: FORPopupActionStyleDefault handler:^(FORPopupAction * _Nonnull action) {
        
    }];
    
    [popupView addAction:action];
    
    [popupView addDetail:@"哈喽" configurationHandler:^(UILabel * _Nonnull label) {
        label.textColor = [UIColor redColor];
    }];
    
    [popupView addTitle:@"我是标题"];
    
    [popupView addImageWithHeight:300 configurationHandler:^(UIImageView * _Nonnull imageView) {
        imageView.image = [UIImage imageNamed:@"pic.jpg"];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [popupView render];
    });
}

@end
