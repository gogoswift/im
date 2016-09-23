//
//  DeviceAuthHelper.m
//  vdangkou
//
//  Created by james on 15/3/15.
//  Copyright (c) 2015年 9tong. All rights reserved.
//

#import "DeviceAuthHelper.h"
#import <EventKit/EventKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

#define DA_TipAlert(_S_, ...)     [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:(_S_), ##__VA_ARGS__] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]


@implementation DeviceAuthHelper

+ (BOOL)checkPhotoLibraryAuthorizationStatus
{
    if ([ALAssetsLibrary respondsToSelector:@selector(authorizationStatus)]) {
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        if (ALAuthorizationStatusDenied == authStatus ||
            ALAuthorizationStatusRestricted == authStatus) {
            [self showSettingAlertStr:@"请在iPhone的“设置->隐私->照片”中打开本应用的访问权限"];
            return NO;
        }
    }
    return YES;
}

+ (BOOL)checkCameraAuthorizationStatus
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        DA_TipAlert(@"该设备不支持拍照");
        return NO;
    }
    
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)]) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (AVAuthorizationStatusDenied == authStatus ||
            AVAuthorizationStatusRestricted == authStatus) {
            [self showSettingAlertStr:@"请在iPhone的“设置->隐私->相机”中打开本应用的访问权限"];
            return NO;
        }
    }
    
    return YES;
}

+ (BOOL)checkRecordPermission {
    
    __block BOOL auth = NO;
    
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        
        [avSession requestRecordPermission:^(BOOL granted) {
            
            if (granted) {
                auth = YES;
            } else {
                //包一层，防止在未决状态的弹窗时，用户点击“取消授权”而导致界面假死
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showSettingAlertStr:@"麦克风未开启，请在“设置>隐私>麦克风”中允许滴滴找布访问，以便语音找布"];
                });
                auth = NO;
            }
            
        }];
    }
    
    return auth;
}

+(BOOL)checkAddressBookPermission;
{
    NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
    NSInteger mainVerId = [[sysVersion substringToIndex:1] intValue];
    if(mainVerId>=6)
    {
        if(ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusAuthorized
           ||ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusNotDetermined)
            return YES;
        else{
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self showSettingAlertStr:@"请在设置>隐私>通讯录>中开启通讯录的访问权限"];
//            });
            return NO;
        }
    }else
        return YES;
}


+(BOOL)checkEventKitEventPermission;
{
    NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
    NSInteger mainVerId = [[sysVersion substringToIndex:1] intValue];
    if(mainVerId>=6)
    {
        EKAuthorizationStatus ekAuthStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
        if(ekAuthStatus ==kABAuthorizationStatusAuthorized||
           ekAuthStatus==kABAuthorizationStatusNotDetermined)
            return YES;
        else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showSettingAlertStr:@"请在设置>隐私>日历中打开访问权限"];
            });
            return NO;
        }
    }else
        return YES;
}



+ (void)showSettingAlertStr:(NSString *)tipStr{
//    //iOS8+系统下可跳转到‘设置’页面，否则只弹出提示窗即可
//    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) {
//        UIAlertView *alertView = [UIAlertView bk_alertViewWithTitle:@"提示" message:tipStr];
//        [alertView bk_setCancelButtonWithTitle:@"取消" handler:nil];
//        [alertView bk_addButtonWithTitle:@"设置" handler:nil];
//        [alertView bk_setDidDismissBlock:^(UIAlertView *alert, NSInteger index) {
//            if (index == 1) {
//                UIApplication *app = [UIApplication sharedApplication];
//                NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
//                if ([app canOpenURL:settingsURL]) {
//                    [app openURL:settingsURL];
//                }
//            }
//        }];
//        [alertView show];
//    }else{
//        DA_TipAlert(@"%@", tipStr);
//    }
    
    DA_TipAlert(@"%@", tipStr);
}

/**
 3D Touch能力监测 ，支持的话就返回YES
 */
+ (BOOL)check3DTouch:(UIViewController*)uvc delegate:(id<UIViewControllerPreviewingDelegate>)delegate{
    
    
    if([[[UIDevice currentDevice] systemVersion] floatValue]>= 9.0)
    {
        if (uvc.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
            
            [uvc registerForPreviewingWithDelegate:delegate sourceView:uvc.view];
            return YES;
            
        }else{
            return NO;
        }
        
    } else {
        return NO;
    }
    
}


@end
