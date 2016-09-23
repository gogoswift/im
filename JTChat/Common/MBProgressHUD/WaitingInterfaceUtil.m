//
//  WaitingInterfaceUtil.m
//  tranb
//
//  Created by zhaoguohui on 15/6/8.
//  Copyright (c) 2015年 cmf. All rights reserved.
//

#import "WaitingInterfaceUtil.h"
#import "JTMBProgressHUD.h"
#import "JChatObjC.h"


#define HUD_DEFAULT_DELAY       2.0f

@implementation WaitingInterfaceUtil

+ (WaitingInterfaceUtil *)sharedInstance {
    static WaitingInterfaceUtil *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WaitingInterfaceUtil alloc] init];
    });
    
    return sharedInstance;
}


- (void)showWaitingAddedTo:(UIView *)view title:(NSString *)title{
    [self showWaitingAddedTo:view title:title xOffset:0.0f yOffset:0.0f];
}

- (void)showWaitingAddedTo:(UIView *)view title:(NSString *)title xOffset:(float)x yOffset:(float)y{
    if (view == nil) return;//保护
    JTMBProgressHUD *hud = [[JTMBProgressHUD alloc] initWithView:view];
    hud.labelText = title;
    [view addSubview:hud];
    hud.center = CGPointMake(hud.center.x +x, hud.center.y +y);
    [hud show:NO];
}

- (BOOL)hideWaitingForView:(UIView *)view{
    if (view == nil) return NO;//保护
    UIView *viewToRemove = nil;
    for (UIView *v in [view subviews]) {
        if ([v isKindOfClass:[JTMBProgressHUD class]]) {
            viewToRemove = v;
        }
    }
    if (viewToRemove != nil) {
        JTMBProgressHUD *HUD = (JTMBProgressHUD *)viewToRemove;
        HUD.removeFromSuperViewOnHide = YES;
        [HUD hide:NO];
        return YES;
    } else {
        return NO;
    }
}

- (void)changeWaitingTitle:(NSString *)title waitingShowView:(UIView *)view{
    if (view == nil) return;//保护
    JTMBProgressHUD *HUD = nil;
    for (UIView *v in [view subviews]) {
        if ([v isKindOfClass:[JTMBProgressHUD class]]) {
            HUD = (JTMBProgressHUD *)v;
            break;
        }
    }
    if (HUD) {
        HUD.labelText = title;
    }
}

- (void)showCompleteTo:(UIView *)view WithText:(NSString *)resultString delay:(NSTimeInterval)delay withImage:(UIImage *)image{
    [self showCompleteTo:view WithText:resultString delay:delay withImage:image xOffset:0.0f yOffset:0.0f];
}

- (void)showCompleteTo:(UIView *)view WithText:(NSString *)resultString delay:(NSTimeInterval)delay withImage:(UIImage *)image xOffset:(float)x yOffset:(float)y{
    if (view == nil) return; //保护
    UIView *viewToRemove = nil;
    for (UIView *v in [view subviews]) {
        if ([v isKindOfClass:[JTMBProgressHUD class]]) {
            viewToRemove = v;
        }
    }
    
    //change log: 如果没有会新建一个HUD
    JTMBProgressHUD *HUD;
    if (viewToRemove != nil) {
        HUD = (JTMBProgressHUD *)viewToRemove;
        HUD.customView = [[UIImageView alloc] initWithImage:image];
        HUD.mode = JTMBProgressHUDModeCustomView;
        HUD.labelText = resultString;
    }
    else{
        // 代表之前没有新建过
        HUD = [[JTMBProgressHUD alloc] initWithView:view];
        HUD.customView = [[UIImageView alloc] initWithImage:image];
        HUD.mode = JTMBProgressHUDModeCustomView;
        [view addSubview:HUD];
        HUD.center = CGPointMake(HUD.center.x + x, HUD.center.y + y);
        HUD.labelText = resultString;
        [HUD show:NO];
    }
    
//    HUD = [[JTMBProgressHUD alloc] initWithView:view];
//    HUD.customView = [[UIImageView alloc] initWithImage:image];
//    HUD.mode = JTMBProgressHUDModeCustomView;
//    [view addSubview:HUD];
//    HUD.center = CGPointMake(HUD.center.x + x, HUD.center.y + y);
//    HUD.labelText = resultString;
//    [HUD show:NO];
    
    [HUD hide:NO afterDelay:delay];
}

-(void) showResult:(NSString *)msg
{
    if (!IM_STR_IS_NIL(msg)) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:nil
                              message:msg
                              delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"确定", nil];
        [alert show];
    }
}

- (void)showSuccessOnTopWindow:(NSString *)resultString
{
    UIWindow *topWindow = [self getTopWindow_];
    if (topWindow != nil) {
        [self showSuccessTo:topWindow withText:resultString];
    }
}

- (void)showSuccessTo:(UIView *)view withText:(NSString *)resultString{
    [self showSuccessTo:view withText:resultString delay:HUD_DEFAULT_DELAY];
}

- (void)showSuccessTo:(UIView *)view withText:(NSString *)resultString delay:(NSTimeInterval)delay{
    [self showCompleteTo:view WithText:resultString delay:delay withImage:[UIImage imageForCurrentBundleWithName:@"indicator_ok.png"]];
}

- (void)showSuccessTo:(UIView *)view withText:(NSString *)resultString withImage:(UIImage *)image
                delay:(NSTimeInterval)delay
{
    [self showCompleteTo:view WithText:resultString delay:delay withImage:image];
}

- (void)showSuccessTo:(UIView *)view withText:(NSString *)resultString delay:(NSTimeInterval)delay xOffset:(float)x yOffset:(float)y{
    [self showCompleteTo:view WithText:resultString delay:delay withImage:[UIImage imageForCurrentBundleWithName:@"indicator_ok.png"]];
}

- (void)showFailureOnTopWindow:(NSString *)resultString
{
    UIWindow *topWindow = [self getTopWindow_];
    if (topWindow != nil) {
        [self showFailureTo:topWindow withText:resultString];
    }
}

- (void)showFailureTo:(UIView *)view withText:(NSString *)resultString{
    [self showFailureTo:view withText:resultString delay:HUD_DEFAULT_DELAY];
}

- (void)showFailureTo:(UIView *)view withText:(NSString *)resultString delay:(NSTimeInterval)delay{
    [self showCompleteTo:view WithText:resultString delay:delay withImage:[UIImage imageForCurrentBundleWithName:@"indicator_problem.png"]];
}

- (void)showFailureTo:(UIView *)view withText:(NSString *)resultString delay:(NSTimeInterval)delay xOffset:(float)x yOffset:(float)y{
    [self showCompleteTo:view WithText:resultString delay:delay withImage:[UIImage imageForCurrentBundleWithName:@"indicator_problem.png"] xOffset:x yOffset:y];
}

- (void)showFailureAlertWithText:(NSString *)resultString {
    [self showCompleteTo:[[UIApplication sharedApplication] keyWindow] WithText:nil delay:0.0f withImage:nil];
    [self showResult:resultString];
}

- (UIWindow *)getTopWindow_ {
    UIWindow *topWindow = nil;
    NSArray *currentWindows = [[UIApplication sharedApplication] windows];
    for (NSInteger i = [currentWindows count] - 1; i >= 0; i--) {
        UIWindow *window = [currentWindows objectAtIndex:i];
        topWindow = window;
        break;
    }
    
    return topWindow;
}


@end

