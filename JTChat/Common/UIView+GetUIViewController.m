//
//  UIView+GetUIViewController.m
//  tranb
//
//  Created by VictorChou on 13-3-13.
//  Copyright (c) 2013年 cmf. All rights reserved.
//

#import "UIView+GetUIViewController.h"

@implementation UIView (GetUIViewController)
- (UIViewController * _Nullable)viewController;
{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}
@end
