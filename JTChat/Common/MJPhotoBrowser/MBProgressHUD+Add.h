//
//  MBProgressHUD+Add.h
//  视频客户端
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "JTMBProgressHUD.h"

@interface JTMBProgressHUD (Add)
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;

+ (JTMBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view;
+ (void)showMessage:(NSString *)text view:(UIView *)view;
@end
