//
//  XHVoiceRecordHUD.m
//  MessageDisplayExample
//
//  Created by qtone-1 on 14-5-13.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "XHVoiceRecordHUD.h"
#import "UIImage+Bundle.h"
//#import "JChatConstants.h"
#define kXHVoiceRecordPauseString @"手指上滑，取消发送"
#define kXHVoiceRecordResaueString @"松开手指，取消发送"

@interface XHVoiceRecordHUD ()

@property (nonatomic, weak) UILabel *remindLabel;
@property (nonatomic, weak) UIImageView *microPhoneImageView;
@property (nonatomic, weak) UIImageView *cancelRecordImageView;
@property (nonatomic, weak) UIImageView *recordingHUDImageView;

@property (nonatomic, assign) BOOL onRecording;

/**
 *  逐渐消失自身
 *
 *  @param compled 消失完成的回调block
 */
- (void)dismissCompled:(void(^)(BOOL fnished))compled;

/**
 *  配置是否正在录音，需要隐藏和显示某些特殊的控件
 *
 *  @param recording 是否录音中
 */
- (void)configRecoding:(BOOL)recording;

/**
 *  根据语音输入的大小来配置需要显示的HUD图片
 *
 *  @param peakPower 输入音频的声音大小
 */
- (void)configRecordingHUDImageWithPeakPower:(CGFloat)peakPower;

/**
 *  配置默认参数
 */
- (void)setup;

@end

#define UIColorFromRGB(rgbValue) [UIColor  colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  green:((float)((rgbValue & 0xFF00) >> 8))/255.0  blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation XHVoiceRecordHUD

- (void)startRecordingHUDAtView:(UIView *)view {
    CGPoint center = CGPointMake(CGRectGetWidth(view.frame) / 2.0, CGRectGetHeight(view.frame) / 2.0);
    self.center = center;
    [view addSubview:self];
    [self configRecoding:YES];
}

- (void)pauseRecord {
    [self configRecoding:YES];
    self.remindLabel.backgroundColor = [UIColor clearColor];
    self.remindLabel.text = kXHVoiceRecordPauseString;
    //self.backgroundColor = UIColorFromRGB(0x3f80dd);
    
}

- (void)resaueRecord {
    [self configRecoding:NO];
    self.remindLabel.backgroundColor = [UIColor clearColor];
    self.remindLabel.text = kXHVoiceRecordResaueString;
    //[self setBackgroundColor:UIColorFromRGB(0xf47e7e)];
    
}

- (void)showCountDownString:(NSString *)countDownStr{
    if (self.onRecording) {
        self.remindLabel.text = [NSString stringWithFormat:@"%@", countDownStr];
    }
}

- (void)stopRecordCompled:(void(^)(BOOL fnished))compled {
    [self dismissCompled:compled];
}

- (void)cancelRecordCompled:(void(^)(BOOL fnished))compled {
    [self dismissCompled:compled];
}

- (void)dismissCompled:(void(^)(BOOL fnished))compled {
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
        compled(finished);
    }];
}

- (void)configRecoding:(BOOL)recording {
    self.onRecording = recording;
    self.microPhoneImageView.hidden = !recording;
    self.recordingHUDImageView.hidden = !recording;
    self.cancelRecordImageView.hidden = recording;
}

- (void)configRecordingHUDImageWithPeakPower:(CGFloat)peakPower {
    NSString *imageName = @"voc-act";
    if (peakPower >= 0 && peakPower <= 0.1) {
        imageName = [imageName stringByAppendingString:@"0"];
    } else if (peakPower > 0.1 && peakPower <= 0.2) {
        imageName = [imageName stringByAppendingString:@"0"];
    } else if (peakPower > 0.3 && peakPower <= 0.4) {
        imageName = [imageName stringByAppendingString:@"1"];
    } else if (peakPower > 0.4 && peakPower <= 0.5) {
        imageName = [imageName stringByAppendingString:@"1"];
    } else if (peakPower > 0.5 && peakPower <= 0.6) {
        imageName = [imageName stringByAppendingString:@"2"];
    } else if (peakPower > 0.7 && peakPower <= 0.8) {
        imageName = [imageName stringByAppendingString:@"3"];
    } else if (peakPower > 0.8 && peakPower <= 0.9) {
        imageName = [imageName stringByAppendingString:@"4"];
    } else if (peakPower > 0.9 && peakPower <= 1.0) {
        imageName = [imageName stringByAppendingString:@"5"];
    }
    self.recordingHUDImageView.image = [UIImage imageForCurrentBundleWithName:imageName];
}

- (void)setPeakPower:(CGFloat)peakPower {
    _peakPower = peakPower;
    [self configRecordingHUDImageWithPeakPower:peakPower];
}

- (void)setup {
    self.backgroundColor = UIColorFromRGB(0xf68929);
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10;
    if (!_remindLabel) {
        UILabel *remindLabel= [[UILabel alloc] initWithFrame:CGRectMake(10.0, 140.0-16-15, 120.0, 16.0)];
        remindLabel.textColor = [UIColor whiteColor];
        remindLabel.font = [UIFont systemFontOfSize:12];
        remindLabel.layer.masksToBounds = YES;
        remindLabel.layer.cornerRadius = 4;
        remindLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        remindLabel.backgroundColor = [UIColor clearColor];
        remindLabel.text = kXHVoiceRecordPauseString;
        remindLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:remindLabel];
        _remindLabel = remindLabel;
    }
    
    UILabel *beginLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 6, 120.0, 20.0)];
    beginLabel.textColor = [UIColor whiteColor];
    beginLabel.font = [UIFont systemFontOfSize:15];
    beginLabel.backgroundColor = [UIColor clearColor];
    beginLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:beginLabel];
    beginLabel.text = @"开始录音";
    
    if (!_microPhoneImageView) {
        UIImageView *microPhoneImageView = [[UIImageView alloc] initWithFrame:CGRectMake(32.0, 38.0, 36.0, 58.0)];
        microPhoneImageView.image = [UIImage imageForCurrentBundleWithName:@"microphone-l-white"];
        microPhoneImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        microPhoneImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:microPhoneImageView];
        _microPhoneImageView = microPhoneImageView;
    }
    
    if (!_recordingHUDImageView) {
        UIImageView *recordHUDImageView = [[UIImageView alloc] initWithFrame:CGRectMake(82.0, 38.0, 20.0, 58.0)];
        recordHUDImageView.image = [UIImage imageForCurrentBundleWithName:@"voc-act0"];
        recordHUDImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        recordHUDImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:recordHUDImageView];
        _recordingHUDImageView = recordHUDImageView;
    }
    
    if (!_cancelRecordImageView) {
        UIImageView *cancelRecordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30.0, 30.0, 80.0, 80.0)];
        cancelRecordImageView.image = [UIImage imageForCurrentBundleWithName:@"RecordCancel"];
        cancelRecordImageView.hidden = YES;
        cancelRecordImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
        cancelRecordImageView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:cancelRecordImageView];
        _cancelRecordImageView = cancelRecordImageView;
    }
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
