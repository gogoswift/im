//
//  ChatTipMessageTableViewCell.m
//  JTChat
//
//  Created by 姚卓禹 on 16/5/6.
//  Copyright © 2016年 jiutong. All rights reserved.
//

#import "ChatTipMessageTableViewCell.h"
#import "UIViewAdditions.h"
#import "HexColor.h"
#import "JChatObjC.h"
#import <JTChat/JTChat-Swift.h>
#import "MLLinkLabel.h"


@interface ChatTipMessageTableViewCell()<MLLinkLabelDelegate, MLLinkLabelDelegate>{
    MLLinkLabel *tipLabel;
    UIView *tipContainerView;
    CGFloat maxTextLabelWidth;
}

@end

@implementation ChatTipMessageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        maxTextLabelWidth = rmtTextTipLabelMaxWidth();
    }
    return self;
}


- (void)cellSubViewsInit{
    [super cellSubViewsInit];
    
    tipContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, rmtMessageCellSubViewTopPadding, maxTextLabelWidth, 10)];
    tipContainerView.backgroundColor = [UIColor colorWithHexString:@"0xe4e3e2"];
    tipContainerView.layer.cornerRadius = 4.0f;
    tipContainerView.layer.masksToBounds = YES;
    //CGRectMake(0, rmtMessageCellSubViewTopPadding, maxTextLabelWidth, 10)
    tipLabel = [[MLLinkLabel alloc] initWithFrame:CGRectMake(0, 0, maxTextLabelWidth, 10)];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.numberOfLines = 0;
    tipLabel.delegate = self;
    tipLabel.font = [UIFont systemFontOfSize:12];
    tipLabel.textColor = [UIColor colorWithHexString:@"0x888888"];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    
    tipLabel.dataDetectorTypes = MLDataDetectorTypeURL;
    //tipLabel.textInsets = rmtTextLabelInset();
    tipLabel.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor blueColor]};
    tipLabel.activeLinkTextAttributes = @{NSForegroundColorAttributeName:[UIColor blueColor], NSBackgroundColorAttributeName:kDefaultActiveLinkBackgroundColorForMLLinkLabel};
    
    
    [self.contentView addSubview:tipContainerView];
    [tipContainerView addSubview:tipLabel];
    
    
    self.userAvatarBtn.hidden = YES;
    self.bubbleBgImageView.hidden = YES;
    
    
}


#define TipLabelVPadding            5
#define TipLabelHPadding            10

- (void)configWithChatMsg:(JChatViewModel *)chatMsg{
    
    tipLabel.size = CGSizeMake(maxTextLabelWidth - TipLabelHPadding *2, MAXFLOAT);
    NSAttributedString *attributedString = [[self class] tipTextWithChatMsg:chatMsg];
    
//    MLLinkType linkType = MLLinkTypeNone;
//    if (chatMsg.customMsgType == JMSGCustomMsgTypePhoneExchangeResponse) {
//        linkType = MLLinkTypePhoneNumber;
//    }else if(chatMsg.customMsgType == JMSGCustomMsgTypeWeiXinExchangeResponse){
//        linkType = MLLinkTypeWeiXin;
//    }
    
//    if (chatMsg.specialRange.length > 0) {
//        NSString *tipString = [attributedString string];
//        MLLink *link = [MLLink linkWithType:linkType value:[tipString substringWithRange:chatMsg.specialRange] range:chatMsg.specialRange];
//        [tipLabel setAttributedText:attributedString withOtherLink:link];
//    }else{
//        tipLabel.attributedText = attributedString;
//    }
    tipLabel.attributedText = attributedString;
    
    [tipLabel sizeToFit];
    tipContainerView.size = CGSizeMake(tipLabel.size.width + TipLabelHPadding *2, tipLabel.size.height + TipLabelVPadding *2);
    
    
    self.bubbleBgImageView.size = CGSizeMake(100, 30);
    
    [super configWithChatMsg:chatMsg];
    sendFailedBtn.hidden = YES;
    stateActivityIndView.hidden = YES;
    
    tipContainerView.centerX = IM_WIDTH_SCREEN/2;
    tipContainerView.top = self.bubbleBgImageView.top;
    tipLabel.center = CGPointMake(tipContainerView.width/2, tipContainerView.height/2);
}

- (void)didClickLink:(MLLink*)link linkText:(NSString*)linkText linkLabel:(MLLinkLabel*)linkLabel{
//    if (link.linkType == MLLinkTypePhoneNumber) {
//        PSTAlertController *controller = [PSTAlertController alertControllerWithTitle:@"电话" message:linkText preferredStyle:PSTAlertControllerStyleActionSheet];
//        [controller addAction:[PSTAlertAction actionWithTitle:@"呼叫" style:PSTAlertActionStyleDefault handler:^(PSTAlertAction *action) {
//            NSString *modelname = [[UIDevice currentDevice] model];
//            if ([modelname isEqualToString:@"iPhone"]) {
//                // iPhone
//                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",linkText]]];
//            }else {
//                [[self viewController] showWarningTips:NSLocalizedString(@"您的设备没有电话功能", @"")];
//            }
//        }]];
//        [controller addAction:[PSTAlertAction actionWithTitle:@"取消" style:PSTAlertActionStyleCancel handler:^(PSTAlertAction *action) {
//            
//        }]];
//        [controller showWithSender:nil controller:[self viewController] animated:YES completion:nil];
//    }else{
//        PSTAlertController *controller = [PSTAlertController alertControllerWithTitle:@"微信" message:linkText preferredStyle:PSTAlertControllerStyleActionSheet];
//        [controller addAction:[PSTAlertAction actionWithTitle:@"复制" style:PSTAlertActionStyleDefault handler:^(PSTAlertAction *action) {
//            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//            pasteboard.string = linkText;
//        }]];
//        [controller addAction:[PSTAlertAction actionWithTitle:@"取消" style:PSTAlertActionStyleCancel handler:^(PSTAlertAction *action) {
//            
//        }]];
//        [controller showWithSender:nil controller:[self viewController] animated:YES completion:nil];
//        
//        
//    }
}

- (void)didLongPressLink:(MLLink*)link linkText:(NSString*)linkText linkLabel:(MLLinkLabel*)linkLabel{
    
}


static CGFloat rmtTextTipLabelMaxWidth(){
    return IM_WIDTH_SCREEN - 100;
}



static MLLinkLabel * kTipLabel() {
    static MLLinkLabel *_kTipLabel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kTipLabel = [MLLinkLabel new];
        _kTipLabel.font = [UIFont systemFontOfSize:14];
        _kTipLabel.numberOfLines = 0;
    });
    return _kTipLabel;
}

+ (NSAttributedString *)tipTextWithChatMsg:(JChatViewModel *)chatMsg{
    NSString *tipText = chatMsg.chatContent;
//    NSDictionary *customDict = chatMsg.customMsgDict;
//    
//    
//    NSRange linkRange = NSMakeRange(0, 0);
    if (chatMsg.contentType == kJMSGContentTypeCustom) {
        tipText = @"自定义消息";
//        if (chatMsg.customMsgType == JMSGCustomMsgTypePhoneExchangeRequest) {
//            if (chatMsg.mine) {
//                tipText = @"你已发送交换电话请求，等待对方同意";
//            }
//        }else if (chatMsg.customMsgType == JMSGCustomMsgTypePhoneExchangeResponse){
//            
//            BOOL isAgree = [customDict[customExchangeResponseTypeAgreeKey] integerValue];
//            if (chatMsg.mine) {
//                if (isAgree) {
//                    NSString *requestPhoneStr = customDict[customExchangeResponseTypeRequestUserContactKey];
//                    if (STR_IS_NIL(requestPhoneStr)) {
//                        requestPhoneStr = @" ";
//                    }
//                    tipText = [NSString stringWithFormat:@"%@的电话：%@", chatMsg.msgToUserName, requestPhoneStr];
//                    linkRange = [tipText rangeOfString:requestPhoneStr options:NSBackwardsSearch];
//                }else{
//                    //tipText = [NSString stringWithFormat:@"你拒绝了%@的电话交换请求", chatMsg.msgToUserName];
//                    tipText = @"我已拒绝与你交换联系方式";
//                }
//            }else{
//                if (isAgree) {
//                    NSString *responsePhoneStr = customDict[customExchangeResponseTypeResponseUserContactKey];
//                    if (STR_IS_NIL(responsePhoneStr)) {
//                        responsePhoneStr = @" ";
//                    }
//                    tipText = [NSString stringWithFormat:@"%@的电话：%@", chatMsg.msgFromUserName, responsePhoneStr];
//                    linkRange = [tipText rangeOfString:responsePhoneStr options:NSBackwardsSearch];
//                }else{
//                    //tipText = [NSString stringWithFormat:@"%@拒绝了你的电话交换请求", chatMsg.msgFromUserName];
//                    tipText = @"对方拒绝与你交换联系方式";
//                }
//                
//            }
//        }else if (chatMsg.customMsgType == JMSGCustomMsgType_WeiXinExchangeRequest){
//            if (chatMsg.mine) {
//                tipText = @"你已发送交换微信请求，等待对方同意";
//            }
//        }else if (chatMsg.customMsgType == JMSGCustomMsgType_WeiXinExchangeResponse){
//            
//            BOOL isAgree = [customDict[customExchangeResponseTypeAgreeKey] integerValue];
//            if (chatMsg.mine) {
//                if (isAgree) {
//                    NSString *requestPhoneStr = customDict[customExchangeResponseTypeRequestUserContactKey];
//                    if (STR_IS_NIL(requestPhoneStr)) {
//                        requestPhoneStr = @" ";
//                    }
//                    tipText = [NSString stringWithFormat:@"%@的微信：%@", chatMsg.msgToUserName, requestPhoneStr];
//                    linkRange = [tipText rangeOfString:requestPhoneStr options:NSBackwardsSearch];
//                }else{
//                    //tipText = [NSString stringWithFormat:@"你拒绝了%@的微信号交换请求", chatMsg.msgToUserName];
//                    tipText = @"我已拒绝与你交换微信";
//                }
//            }else{
//                if (isAgree) {
//                    NSString *responsePhoneStr = customDict[customExchangeResponseTypeResponseUserContactKey];
//                    if (STR_IS_NIL(responsePhoneStr)) {
//                        tipText = [NSString stringWithFormat:@"%@的微信：", chatMsg.msgFromUserName];
//                        linkRange = NSMakeRange(0, 0);
//                    }else{
//                        tipText = [NSString stringWithFormat:@"%@的微信：%@", chatMsg.msgFromUserName, responsePhoneStr];
//                        linkRange = [tipText rangeOfString:responsePhoneStr options:NSBackwardsSearch];
//                    }
//                    
//                }else{
//                    //tipText = [NSString stringWithFormat:@"%@拒绝了你的微信号交换请求", chatMsg.msgFromUserName];
//                    tipText = @"对方拒绝与你交换微信";
//                }
//                
//            }
//        }
    }else if (chatMsg.contentType == kJMSGContentTypeEventNotification){
        //
        JMSGEventContent *eventContent = (JMSGEventContent *)chatMsg.message.content;
        tipText = [eventContent showEventNotification];
    }
    
    if(IM_STR_IS_NIL(tipText)){
        tipText = @"未知错误类型";
    }
    
    chatMsg.textMsgAttributeContent = [tipText expressionAttributedStringWithExpression:[MLExpression chatLabelExpression]];
    //chatMsg.specialRange = linkRange;
    return chatMsg.textMsgAttributeContent;
}



+ (CGFloat)bubbleBgImageViewHeightWithChatMsg:(JChatViewModel *)chatMsg{
    MLLinkLabel *label = kTipLabel();
    label.attributedText = [self tipTextWithChatMsg:chatMsg];
    CGSize labelSize = [label preferredSizeWithMaxWidth:rmtTextTipLabelMaxWidth() - TipLabelHPadding *2];
    //label.frame = CGRectMake(0, 0, rmtTextTipLabelMaxWidth() - TipLabelHPadding *2, MAXFLOAT);
    //[label sizeToFit];
    return labelSize.height + TipLabelVPadding *2;
}
@end
