//
//  ChatTextMessageTableViewCell.m
//  JTChat
//
//  Created by 姚卓禹 on 16/5/4.
//  Copyright © 2016年 jiutong. All rights reserved.
//

#import "ChatTextMessageTableViewCell.h"
#import "UIViewAdditions.h"
#import "HexColor.h"
#import "JChatObjC.h"
#import <JTChat/JTChat-Swift.h>
#import "MLLinkLabel.h"

#define chatTextMessageTextLabelFontSize        15
const CGFloat kTextLabelMinHeight = 40.0f;

@interface ChatTextMessageTableViewCell()<MLLinkLabelDelegate>{
    CGFloat maxTextLabelWidth;
}

@end



@implementation ChatTextMessageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        maxTextLabelWidth = rmtTextLabelMaxWidth();
    }
    return self;
}

- (void)cellSubViewsInit{
    [super cellSubViewsInit];
    _attributeLabel = [[MLLinkLabel alloc] initWithFrame:CGRectZero];
    _attributeLabel.textColor = [UIColor blackColor];
    _attributeLabel.font = [UIFont systemFontOfSize:chatTextMessageTextLabelFontSize];
    _attributeLabel.numberOfLines = 0;
    _attributeLabel.dataDetectorTypes = MLDataDetectorTypeURL/*|MLDataDetectorTypePhoneNumber|MLDataDetectorTypeEmail*/;
    //_attributeLabel.textInsets = rmtTextLabelInset();
    _attributeLabel.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor blueColor]};
    _attributeLabel.activeLinkTextAttributes = @{NSForegroundColorAttributeName:[UIColor blueColor], NSBackgroundColorAttributeName:kDefaultActiveLinkBackgroundColorForMLLinkLabel};
    _attributeLabel.delegate = self;
    [self.bubbleBgImageView addSubview:_attributeLabel];
}


- (void)configWithChatMsg:(JChatViewModel *)chatMsg{
    
    if(chatMsg.mine){
        _attributeLabel.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    }else{
        _attributeLabel.linkTextAttributes =@{NSForegroundColorAttributeName:[UIColor blueColor]};
    }
    
    _attributeLabel.attributedText = chatMsg.textMsgAttributeContent;
    _attributeLabel.width = maxTextLabelWidth;
    _attributeLabel.height = 0;
    
    if (chatMsg.mine) {
        _attributeLabel.textInsets = rmtTextLabelRightInset();
        _attributeLabel.textColor = [UIColor colorWithHexString:@"0xffffff"];
    }else{
        _attributeLabel.textInsets = rmtTextLabelLeftInset();
        _attributeLabel.textColor = [UIColor colorWithHexString:@"0x333033"];
    }
    
    [_attributeLabel sizeToFit];
    if (_attributeLabel.height < kTextLabelMinHeight) {
        _attributeLabel.height = kTextLabelMinHeight;
    }
    self.bubbleBgImageView.size = _attributeLabel.size;
    
    [super configWithChatMsg:chatMsg];
    
    
    [stateActivityIndView stopAnimating];
    [sendFailedBtn setHidden:YES];
    if (chatMsg.message.status == kJMSGMessageStatusSending || chatMsg.message.status == kJMSGMessageStatusReceiving) {
        [stateActivityIndView startAnimating];
        [sendFailedBtn setHidden:YES];
    }else if (chatMsg.message.status == kJMSGMessageStatusSendSucceed || chatMsg.message.status == kJMSGMessageStatusReceiveSucceed)
    {
        [stateActivityIndView stopAnimating];
        [sendFailedBtn setHidden:YES];
    }else if (chatMsg.message.status == kJMSGMessageStatusSendFailed || chatMsg.message.status == kJMSGMessageStatusReceiveDownloadFailed)
    {
        [stateActivityIndView stopAnimating];
        [sendFailedBtn setHidden:NO];
    }else {
        [stateActivityIndView stopAnimating];
        [sendFailedBtn setHidden:YES];
    }
}

- (void)didClickLink:(MLLink*)link linkText:(NSString*)linkText linkLabel:(MLLinkLabel*)linkLabel{
    if (link.linkType == MLLinkTypeURL) {
        [self.delegate messageTableViewCell:self actionForTextUrlString:linkText];
    }
}

- (void)didLongPressLink:(MLLink*)link linkText:(NSString*)linkText linkLabel:(MLLinkLabel*)linkLabel{
    
}


static CGFloat rmtTextLabelMaxWidth(){
    return IM_WIDTH_SCREEN - 2*(rmtMessageCellAvatarBtnLeftPadding+rmtMessageCellAvatarBtnSize+rmtMessageCellAvatarBtnAndBubbleBgHPadding+4);
}

static UIEdgeInsets rmtTextLabelLeftInset(){
    return UIEdgeInsetsMake(10, 15, 10, 8);
}

static UIEdgeInsets rmtTextLabelRightInset(){
    return UIEdgeInsetsMake(10, 8, 10, 12);
}

#pragma mark - height

static MLLinkLabel * kProtypeLabel() {
    static MLLinkLabel *_protypeLabel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _protypeLabel = [MLLinkLabel new];
        _protypeLabel.font = [UIFont systemFontOfSize:chatTextMessageTextLabelFontSize];//[UIFont systemFontOfSize:rmtTextMessageTextLabelFont];
        _protypeLabel.numberOfLines = 0;
        _protypeLabel.dataDetectorTypes = MLDataDetectorTypeURL/*|MLDataDetectorTypePhoneNumber|MLDataDetectorTypeEmail*/;
        _protypeLabel.textInsets = rmtTextLabelLeftInset();
    });
    return _protypeLabel;
}



+ (CGFloat)bubbleBgImageViewHeightWithChatMsg:(JChatViewModel *)chatMsg{
    MLLinkLabel *label = kProtypeLabel();
    label.attributedText = chatMsg.textMsgAttributeContent;
    CGSize labelSize = [label preferredSizeWithMaxWidth:rmtTextLabelMaxWidth()];
    
    if (labelSize.height < kTextLabelMinHeight) {
        return kTextLabelMinHeight;
    }
    
    return labelSize.height; //上下间距
}


@end
