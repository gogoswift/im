//
//  DeviceAuthHelper.h
//  vdangkou
//
//  Created by james on 15/3/15.
//  Copyright (c) 2015年 9tong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DeviceAuthHelper : NSObject

/**
 * 检查系统"照片"授权状态, 如果权限被关闭, 提示用户去隐私设置中打开.
 */
+ (BOOL)checkPhotoLibraryAuthorizationStatus;

/**
 * 检查系统"相机"授权状态, 如果权限被关闭, 提示用户去隐私设置中打开.
 */
+ (BOOL)checkCameraAuthorizationStatus;

/**
 * 检查系统"麦克风"授权状态, 如果权限被关闭, 提示用户去隐私设置中打开.
 */
+ (BOOL)checkRecordPermission;

/**
 检查手机通讯录的访问权限
 */
 
+(BOOL)checkAddressBookPermission;

/**
 检查系统日历的访问权限
 */
+(BOOL)checkEventKitEventPermission;

/**
 3D Touch能力监测 ，支持的话就返回YES
 */
+ (BOOL)check3DTouch:(UIViewController*)uvc delegate:(id<UIViewControllerPreviewingDelegate>)delegate;

@end
