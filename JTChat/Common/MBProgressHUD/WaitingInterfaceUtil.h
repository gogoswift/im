//
//  WaitingInterfaceUtil.h
//  tranb
//
//  Created by zhaoguohui on 15/6/8.
//  Copyright (c) 2015年 cmf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WaitingInterfaceUtil : NSObject

+ (WaitingInterfaceUtil *)sharedInstance;

//显示等待界面， 参数view为等待界面的superView，title为显示的提示
- (void)showWaitingAddedTo:(UIView *)view title:(NSString *)title;
- (void)showWaitingAddedTo:(UIView *)view title:(NSString *)title xOffset:(float)x yOffset:(float)y;

- (void)changeWaitingTitle:(NSString *)title waitingShowView:(UIView *)view;

//没有成功或者失败提示，隐藏等待界面
- (BOOL)hideWaitingForView:(UIView *)view;

//操作成功时调用，delay为显示成功的等待时间
//没有等待HUD时直接调用该方法，会新建一个HUD
- (void)showSuccessTo:(UIView *)view withText:(NSString *)resultString delay:(NSTimeInterval)delay;

- (void)showSuccessTo:(UIView *)view withText:(NSString *)resultString withImage:(UIImage *)image
                delay:(NSTimeInterval)delay;

- (void)showSuccessTo:(UIView *)view withText:(NSString *)resultString;

- (void)showSuccessTo:(UIView *)view withText:(NSString *)resultString delay:(NSTimeInterval)delay xOffset:(float)x yOffset:(float)y;

- (void)showSuccessOnTopWindow:(NSString *)resultString;

//操作失败是调用，delay为显示失败的等待时间
//没有等待HUD时直接调用该方法，会新建一个HUD
- (void)showFailureTo:(UIView *)view withText:(NSString *)resultString delay:(NSTimeInterval)delay;

- (void)showFailureTo:(UIView *)view withText:(NSString *)resultString;

- (void)showFailureTo:(UIView *)view withText:(NSString *)resultString delay:(NSTimeInterval)delay xOffset:(float)x yOffset:(float)y;

- (void)showFailureAlertWithText:(NSString *)resultString;

- (void)showFailureOnTopWindow:(NSString *)resultString;

@end


