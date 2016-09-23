//
//  ChatAudioMessageTableViewCell.m
//  JTChat
//
//  Created by 姚卓禹 on 16/5/5.
//  Copyright © 2016年 jiutong. All rights reserved.
//

#import "ChatAudioMessageTableViewCell.h"
#import <JTChat/JTChat-Swift.h>
#import "HexColor.h"
#import "UIViewAdditions.h"
#import "UIImage+Bundle.h"

const static CGFloat kBubbleAudioHeight = 40.0f;

@interface ChatAudioMessageTableViewCell(){
    UIImageView *voiceImgView;
    UILabel *voiceTimeLabel;
}

@property(assign, nonatomic) NSInteger audioImageIndex;

@end

@implementation ChatAudioMessageTableViewCell

- (void)cellSubViewsInit{
    [super cellSubViewsInit];
    
    voiceImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    voiceImgView.image = [UIImage imageForCurrentBundleWithName:@"icon-voice-white-3"];
    voiceImgView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.bubbleBgImageView addSubview:voiceImgView];
    
    
    voiceTimeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    voiceTimeLabel.textColor = [UIColor colorWithHexString:@"0x888888"];
    voiceTimeLabel.textAlignment = NSTextAlignmentCenter;
    voiceTimeLabel.font = [UIFont systemFontOfSize:14];
    [self.bubbleBgImageView addSubview:voiceTimeLabel];
    
}


- (void)configWithChatMsg:(JChatViewModel *)chatMsg{
    self.bubbleBgImageView.size = CGSizeMake(rmtAudioWidth(chatMsg.voiceTime), kBubbleAudioHeight);
    [super configWithChatMsg:chatMsg];
    
    if ([chatMsg.voiceTime rangeOfString:@"''"].location != NSNotFound) {
        voiceTimeLabel.text = [NSString stringWithFormat:@"%ld", [chatMsg.voiceTime integerValue]];
    } else {
        voiceTimeLabel.text = [[NSString stringWithFormat:@"%ld", [chatMsg.voiceTime integerValue]] stringByAppendingString:@"''"];
    }
    [voiceTimeLabel sizeToFit];
    
    if (chatMsg.mine) {
        voiceImgView.right = self.bubbleBgImageView.width - 14.0f;
        voiceImgView.centerY = kBubbleAudioHeight/2;
        voiceTimeLabel.right = -6.0f;
        voiceTimeLabel.bottom = kBubbleAudioHeight - 2;
        voiceImgView.image = [UIImage imageForCurrentBundleWithName:@"icon-voice-white2-3"];
    }else{
        voiceImgView.left = 14.0f;
        voiceImgView.centerY = kBubbleAudioHeight/2;
        voiceTimeLabel.left = self.bubbleBgImageView.width + 6.0f;
        voiceTimeLabel.bottom = kBubbleAudioHeight - 2;
        voiceImgView.image = [UIImage imageForCurrentBundleWithName:@"icon-voice-oringe-3"];
    }
    
    ////
    [stateActivityIndView stopAnimating];
    [sendFailedBtn setHidden:YES];
    
    if (chatMsg.message.status == kJMSGMessageStatusSending ||
        chatMsg.message.status == kJMSGMessageStatusReceiving) {
        [stateActivityIndView startAnimating];
        [sendFailedBtn setHidden:YES];
    }else if (chatMsg.message.status == kJMSGMessageStatusSendSucceed ||
              chatMsg.message.status == kJMSGMessageStatusReceiveSucceed)
    {
        [stateActivityIndView stopAnimating];
        [sendFailedBtn setHidden:YES];
    }else if (chatMsg.message.status == kJMSGMessageStatusSendFailed)
    {
        [stateActivityIndView stopAnimating];
        [sendFailedBtn setHidden:YES];
        [sendFailedBtn setHidden:NO];
    }else {
        [stateActivityIndView stopAnimating];
        [sendFailedBtn setHidden:YES];
    }
    
    
    if (currentChatMsgModel.isPlayingAudio){
        [self changeVoiceImage];
    }else{
        self.audioImageIndex = 0;
        if (chatMsg.mine) {
            voiceImgView.image = [UIImage imageForCurrentBundleWithName:@"icon-voice-white2-3"];
        }else{
            voiceImgView.image = [UIImage imageForCurrentBundleWithName:@"icon-voice-oringe-3"];
        }
    }
}


- (void)bubbleBgImageAction{
    [self actionPlayVoice];
}

- (void)actionPlayVoice{
    
    if ([self.delegate respondsToSelector:@selector(messageTableViewCell:actionForAudioMsgModel:)]) {
        [self.delegate messageTableViewCell:self actionForAudioMsgModel:currentChatMsgModel];
    }
}

- (void)changeVoiceImage {
    if (!currentChatMsgModel.isPlayingAudio) {
        return;
    }
    NSString *voiceImagePreStr = @"";
    voiceImagePreStr = @"icon-voice-white2-";
    if (currentChatMsgModel.mine) {
        voiceImagePreStr = @"icon-voice-white2-";
    } else {
        voiceImagePreStr = @"icon-voice-oringe-";
    }
    voiceImgView.image = [UIImage imageForCurrentBundleWithName:[NSString stringWithFormat:@"%@%zd.png", voiceImagePreStr, self.audioImageIndex % 3 + 1]];
    if (currentChatMsgModel.isPlayingAudio) {
        self.audioImageIndex++;
        [self performSelector:@selector(changeVoiceImage) withObject:nil afterDelay:0.45];
    }
}




static CGFloat rmtAudioWidth(NSString *audioTimeStr){
    NSInteger audioTime = 0;
    if ([audioTimeStr rangeOfString:@"''"].location != NSNotFound) {
        NSString *audioStr = [audioTimeStr substringToIndex:[audioTimeStr rangeOfString:@"''"].location];
        audioTime = [audioStr integerValue];
    } else {
        audioTime = [audioTimeStr integerValue];
    }
    
    CGFloat minWidth = IM_WIDTH_SCREEN/4;
    CGFloat maxWidth = IM_WIDTH_SCREEN/1.5;
    
    if (audioTime <= 0) {
        return ceilf(minWidth);
    }else if (audioTime>=60){
        return ceilf(maxWidth);
    }else{
        return ceilf(minWidth + (maxWidth - minWidth)*audioTime/60.0f);
    }
}


+ (CGFloat)bubbleBgImageViewHeightWithChatMsg:(JChatViewModel *)chatMsg{
    return kBubbleAudioHeight;
}


@end
