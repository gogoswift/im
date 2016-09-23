//
//  ChatImageMessageTableViewCell.m
//  JTChat
//
//  Created by 姚卓禹 on 16/5/5.
//  Copyright © 2016年 jiutong. All rights reserved.
//

#import "ChatImageMessageTableViewCell.h"
#import <JTChat/JTChat-Swift.h>
#import "HexColor.h"
#import "UIViewAdditions.h"
#import "UIImage+Bundle.h"

@interface ChatImageMessageTableViewCell(){
    UIImageView *contentImgView;
    
    UILabel *percentLabel;
    
    CGFloat maxImageWidth;
}

@end


@implementation ChatImageMessageTableViewCell


@synthesize percentLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        maxImageWidth = rmtChatImageMaxWidth();
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    if (self.message) {
        ((JMSGImageContent *)self.message.content).uploadHandler = nil;
    }
}

- (void)cellSubViewsInit{
    [super cellSubViewsInit];
    
    contentImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [contentImgView setUserInteractionEnabled:YES];
    contentImgView.layer.cornerRadius = 2.0f;
    contentImgView.layer.masksToBounds = YES;
    
    //////
    percentLabel = [[UILabel alloc] init];
    percentLabel.font = [UIFont systemFontOfSize:18];
    percentLabel.textAlignment = NSTextAlignmentCenter;
    percentLabel.textColor=[UIColor whiteColor];
    [percentLabel setBackgroundColor:[UIColor clearColor]];
    [contentImgView addSubview:percentLabel];
//    [percentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(contentImgView);
//    }];
    
    percentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentImgView addConstraints:@[[NSLayoutConstraint constraintWithItem:percentLabel
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:contentImgView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:0.0],
                                     [NSLayoutConstraint constraintWithItem:percentLabel
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:contentImgView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0
                                                                   constant:0.0]]
     ];
    
    [self.bubbleBgImageView addSubview:contentImgView];
    
    
}

- (void)addUpLoadHandler {
    if (currentChatMsgModel.message.contentType != kJMSGContentTypeImage) {
        return;
    }
    __weak __typeof(self)weakSelfUpload = self;
    ((JMSGImageContent *)currentChatMsgModel.message.content).uploadHandler = ^(float percent, NSString *msgId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong __typeof(weakSelfUpload)strongSelfUpload = weakSelfUpload;
            if ([[strongSelfUpload cellChatMsgModel].message.msgId isEqualToString:msgId]) {
                NSString *percentString = [NSString stringWithFormat:@"%d%%", (int)(percent * 100)];
                strongSelfUpload.percentLabel.text = percentString;
            }
        });
    };
}



- (void)configWithChatMsg:(JChatViewModel *)chatMsg{
    currentChatMsgModel = chatMsg;
    if (chatMsg.message.status == kJMSGMessageStatusReceiveDownloadFailed) {
        contentImgView.image = [UIImage imageNamed:@"receiveFail"];
    }else{
        [(JMSGImageContent *)chatMsg.message.content thumbImageData:^(NSData *data, NSString *objectId, NSError *error) {
            if (error == nil) {
                if (data != nil) {
                    [contentImgView setImage:[UIImage imageWithData:data]];
                } else {
                    [contentImgView setImage:[UIImage imageNamed:@"receiveFail"]];
                }
            } else {
                [contentImgView setImage:[UIImage imageNamed:@"receiveFail"]];
            }
        }];
    }
    
    [self addUpLoadHandler];
    
    NSInteger imgHeight = contentImgView.image.size.height;
    NSInteger imgWidth = contentImgView.image.size.width;
    
    
    
    
    if (imgWidth > maxImageWidth) {
        
        imgHeight =imgHeight * maxImageWidth / imgWidth;
        imgWidth = maxImageWidth;
    }
    
    UIEdgeInsets imageInsets = rmtImageViewInset();
    
    self.bubbleBgImageView.size = CGSizeMake(imgWidth + imageInsets.left + imageInsets.right, imgHeight + imageInsets.top + imageInsets.bottom);
    if (chatMsg.mine) {
        contentImgView.frame = CGRectMake(imageInsets.left, imageInsets.top, imgWidth, imgHeight);
    }else{
        contentImgView.frame = CGRectMake(imageInsets.right, imageInsets.top, imgWidth, imgHeight);
    }
    
    
    [super configWithChatMsg:chatMsg];
    
    [stateActivityIndView stopAnimating];
    [sendFailedBtn setHidden:YES];
    
    percentLabel.hidden = NO;
    
    if (chatMsg.mine) {
        self.bubbleBgImageView.image = [[UIImage imageForCurrentBundleWithName:@"im_bubble_empty_bg_right"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 25, 10, 20)];
    }else{
        self.bubbleBgImageView.image = [[UIImage imageForCurrentBundleWithName:@"im_bubble_bg_left"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 18, 8, 20)];
    }
    
    if (chatMsg.message.status == kJMSGMessageStatusSending || chatMsg.message.status == kJMSGMessageStatusReceiving) {
        [stateActivityIndView startAnimating];
        [sendFailedBtn setHidden:YES];
    }else if (chatMsg.message.status == kJMSGMessageStatusSendSucceed || chatMsg.message.status == kJMSGMessageStatusReceiveSucceed)
    {
        [stateActivityIndView stopAnimating];
        [sendFailedBtn setHidden:YES];
        [percentLabel setHidden:YES];
    }else if (chatMsg.message.status == kJMSGMessageStatusSendFailed)
    {
        [stateActivityIndView stopAnimating];
        [sendFailedBtn setHidden:YES];
        [sendFailedBtn setHidden:NO];
    }else {
        [stateActivityIndView stopAnimating];
        [sendFailedBtn setHidden:YES];
    }
}


static CGFloat rmtChatImageMaxWidth(){
    return IM_WIDTH_SCREEN/3.0f;
}

static UIEdgeInsets rmtImageViewInset(){
    return UIEdgeInsetsMake(2, 2, 2, 8);
}


- (void)bubbleBgImageAction{
    ///先判断是否是缩略图下载失败，失败的话直接下载缩略图
    if (currentChatMsgModel.message.status == kJMSGMessageStatusReceiveDownloadFailed) {
        
        ///
        [(JMSGImageContent *)currentChatMsgModel.message.content thumbImageData:^(NSData *data, NSString *objectId, NSError *error) {
            if (error == nil) {
                if (data != nil) {
                    [contentImgView setImage:[UIImage imageWithData:data]];
                } else {
                    [contentImgView setImage:[UIImage imageNamed:@"receiveFail"]];
                }
            } else {
                [contentImgView setImage:[UIImage imageNamed:@"receiveFail"]];
            }
        }];
    }else{
        if ([self.delegate respondsToSelector:@selector(messageTableViewCell:tapPictureWithView:messageId:)]) {
            [self.delegate messageTableViewCell:self tapPictureWithView:contentImgView messageId:currentChatMsgModel.message.msgId];
        }
    }
}


+ (CGFloat)bubbleBgImageViewHeightWithChatMsg:(JChatViewModel *)chatMsg{
    __block UIImage *bubbleImage = [UIImage imageNamed:@"receiveFail"];
    if (chatMsg.message.status == kJMSGMessageStatusReceiveDownloadFailed) {
        bubbleImage = [UIImage imageNamed:@"receiveFail"];
    }else{
        [(JMSGImageContent *)chatMsg.message.content thumbImageData:^(NSData *data, NSString *objectId, NSError *error) {
            if (error == nil) {
                if (data != nil) {
                    bubbleImage = [UIImage imageWithData:data];
                }
            }
        }];
    }
    
    
    
    NSInteger imgHeight = bubbleImage.size.height;
    NSInteger imgWidth = bubbleImage.size.width;
    
    
    if (imgWidth > rmtChatImageMaxWidth()) {
        imgHeight =imgHeight * rmtChatImageMaxWidth() / imgWidth;
    }
    
    UIEdgeInsets insets = rmtImageViewInset();
    
    return imgHeight + insets.top + insets.bottom;
}


@end
