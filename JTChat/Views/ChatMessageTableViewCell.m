//
//  ChatMessageTableViewCell.m
//  JTChat
//
//  Created by 姚卓禹 on 16/5/4.
//  Copyright © 2016年 jiutong. All rights reserved.
//

#import "ChatMessageTableViewCell.h"
#import "UIViewAdditions.h"
#import "HexColor.h"
#import "JChatObjC.h"
#import "JCHATStringUtils.h"
#import <JTChat/JTChat-Swift.h>

const CGFloat rmtMessageCellSubViewTopPadding = 8.0f;
const CGFloat rmtMessageCellSubViewBottomPadding = 8.0f;

const CGFloat rmtMessageCellAvatarBtnLeftPadding = 10.0f;
const CGFloat rmtMessageCellTipLabelsVPadding = 15.0f;
const CGFloat rmtMessageCellAvatarBtnAndBubbleBgHPadding = 4.0f;

const CGFloat rmtMessageCellAvatarBtnSize = 40.0f;
const CGFloat rmtMessageCellTimeLabelHeight = 16.0f;

const CGFloat rmtMessageCellStateActivityIndViewAndBubbleBgViewHPadding = 10.0f;

const CGFloat rmtMessageCellBubbleBgAndMsgTipLabelVPadding = 10.0f;

const CGFloat rmtMsgNameLabelHeight = 16.0f;


#define msgContentFontSize              14

@interface ChatMessageTableViewCell(){
    UIView *msgTipContainerView;
}
@end

@implementation ChatMessageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        [self cellSubViewsInit];
    }
    return self;
}


- (JChatViewModel *)cellChatMsgModel{
    return currentChatMsgModel;
}


- (void)cellSubViewsInit{
    _userAvatarBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _userAvatarBtn.frame = CGRectMake(rmtMessageCellAvatarBtnLeftPadding, 0, rmtMessageCellAvatarBtnSize, rmtMessageCellAvatarBtnSize);
    [_userAvatarBtn addTarget:self action:@selector(actionForAvatarBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_userAvatarBtn];
    
    _userAvatarBtn.backgroundColor = [UIColor clearColor];
    
    
    _msgNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_userAvatarBtn.right+rmtMessageCellAvatarBtnAndBubbleBgHPadding+8, 0, IM_WIDTH_SCREEN/2, rmtMsgNameLabelHeight)];
    _msgNameLabel.width = IM_WIDTH_SCREEN - _msgNameLabel.left;
    _msgNameLabel.font = [UIFont systemFontOfSize:12];
    _msgNameLabel.textColor = [UIColor colorWithHexString:@"0x888888"];
    [self.contentView addSubview:_msgNameLabel];
    
    ///////////////////
    _bubbleBgImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _bubbleBgImageView.left = _userAvatarBtn.right + rmtMessageCellAvatarBtnAndBubbleBgHPadding;
    _bubbleBgImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:_bubbleBgImageView];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBubbleImageView:)];
    gesture.cancelsTouchesInView = NO;
    [_bubbleBgImageView addGestureRecognizer:gesture];
    
    
    ////////////
    _msgTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, rmtMessageCellSubViewTopPadding, IM_WIDTH_SCREEN, rmtMessageCellTimeLabelHeight)];
    _msgTimeLabel.backgroundColor = [UIColor clearColor];
    _msgTimeLabel.font = [UIFont systemFontOfSize:12];
    _msgTimeLabel.textColor = [UIColor colorWithHexString:@"0x888888"];
    _msgTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_msgTimeLabel];
    
    stateActivityIndView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    stateActivityIndView.hidesWhenStopped = YES;
    [self.contentView addSubview:stateActivityIndView];
    
    sendFailedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sendFailedBtn.frame = CGRectMake(0, 0, 30, 30);
    [sendFailedBtn setImage:[UIImage imageForCurrentBundleWithName:@"send_msg_error"] forState:UIControlStateNormal];
    [sendFailedBtn addTarget:self action:@selector(sendFailedBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    sendFailedBtn.hidden = YES;
    [self.contentView addSubview:sendFailedBtn];
    
    
    msgTipContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, _bubbleBgImageView.bottom + rmtMessageCellBubbleBgAndMsgTipLabelVPadding, IM_WIDTH_SCREEN, 20)];
    msgTipContainerView.backgroundColor = [UIColor colorWithHexString:@"0xcacbcc"];
    self.msgTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.msgTipLabel.backgroundColor = [UIColor clearColor];
    self.msgTipLabel.numberOfLines = 0;
    self.msgTipLabel.font = [UIFont systemFontOfSize:msgContentFontSize];
    self.msgTipLabel.textColor = [UIColor whiteColor];
    self.msgTipLabel.textAlignment = NSTextAlignmentCenter;
    [msgTipContainerView addSubview:self.msgTipLabel];
    [self.contentView addSubview:msgTipContainerView];
    
}

- (void)configWithChatMsg:(JChatViewModel *)chatMsgModel{
    currentChatMsgModel = chatMsgModel;
    //[self.userAvatarBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:chatMsgModel.avatar] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:NSLocalizedString(@"lxr_photo.png",@"")]];
    //[self.userAvatarBtn setBackgroundImage:[UIImage imageForCurrentBundleWithName:@"avatar_default"] forState:UIControlStateNormal];
    _msgNameLabel.hidden = YES;
    
    ////////////
    _msgTimeLabel.top = rmtMessageCellSubViewTopPadding;
    if (currentChatMsgModel.showTimeTip) {
        _msgTimeLabel.hidden = NO;
        _msgTimeLabel.text = [JCHATStringUtils getFriendlyDateString:[currentChatMsgModel.messageTime doubleValue]];
        [_msgTimeLabel sizeToFit];
        _msgTimeLabel.top = rmtMessageCellSubViewTopPadding;
        _msgTimeLabel.width += 10.0f;
        _msgTimeLabel.height = rmtMessageCellTimeLabelHeight;
        _msgTimeLabel.centerX = IM_WIDTH_SCREEN/2;
        
        _userAvatarBtn.top = _msgTimeLabel.bottom + rmtMessageCellTipLabelsVPadding;
        _bubbleBgImageView.top = _userAvatarBtn.top;
    }else{
        _msgTimeLabel.hidden = YES;
        _userAvatarBtn.top = _msgTimeLabel.top;
        _bubbleBgImageView.top = _userAvatarBtn.top;
        
    }

    if (currentChatMsgModel.mine) {
        //是发送者
        _userAvatarBtn.right = IM_WIDTH_SCREEN - rmtMessageCellAvatarBtnLeftPadding;
        _bubbleBgImageView.right = _userAvatarBtn.left - rmtMessageCellAvatarBtnAndBubbleBgHPadding;
        
        stateActivityIndView.right = _bubbleBgImageView.left - rmtMessageCellStateActivityIndViewAndBubbleBgViewHPadding;
        stateActivityIndView.centerY = _bubbleBgImageView.centerY;
        sendFailedBtn.centerY = _bubbleBgImageView.centerY;
        sendFailedBtn.right = _bubbleBgImageView.left - rmtMessageCellStateActivityIndViewAndBubbleBgViewHPadding;
        
        _bubbleBgImageView.image = [[UIImage imageForCurrentBundleWithName:@"im_bubble_bg_right"] resizableImageWithCapInsets:UIEdgeInsetsMake(28, 25, 10, 20)];
        
    }else{
        _userAvatarBtn.left = rmtMessageCellAvatarBtnLeftPadding;
        
        if (currentChatMsgModel.chatType == kJMSGConversationTypeGroup) {
            _msgNameLabel.hidden = NO;
            _msgNameLabel.attributedText = chatMsgModel.attributeDisplayName;//chatMsgModel.msgFromUserName;
//            _msgNameLabel.attributedText = chatMsgModel.attributeDisplayName;//chatMsgModel.msgFromUserName;
            _msgNameLabel.top = _userAvatarBtn.top;
            if (chatMsgModel.attributeDisplayName.length == 2) {
                _bubbleBgImageView.top = _userAvatarBtn.top;
            }else{
                _bubbleBgImageView.top = _userAvatarBtn.top + _msgNameLabel.height;
            }
            
        }else{
            
            _bubbleBgImageView.top = _userAvatarBtn.top;
        }
        
        _bubbleBgImageView.left = _userAvatarBtn.right + rmtMessageCellAvatarBtnAndBubbleBgHPadding;
        stateActivityIndView.left = _bubbleBgImageView.right + rmtMessageCellStateActivityIndViewAndBubbleBgViewHPadding;
        stateActivityIndView.centerY = _bubbleBgImageView.centerY;
        sendFailedBtn.hidden = YES;
        _bubbleBgImageView.image = [[UIImage imageForCurrentBundleWithName:@"im_bubble_bg_left"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 8, 25)];
    }
    
    if (IM_STR_IS_NIL(currentChatMsgModel.msgTipContent)) {
        msgTipContainerView.hidden = YES;
    }else{
        msgTipContainerView.hidden = NO;
        self.msgTipLabel.width = rmtMsgTipContentLabelMaxWidth();
        self.msgTipLabel.height = MAXFLOAT;
        self.msgTipLabel.text = currentChatMsgModel.msgTipContent;
        [self.msgTipLabel sizeToFit];
        
        UIEdgeInsets inset = rmtMsgTipContentLabelInset();
        msgTipContainerView.size = CGSizeMake(self.msgTipLabel.width + inset.left + inset.right, self.msgTipLabel.height + inset.top + inset.bottom);
        if (_bubbleBgImageView.bottom > _userAvatarBtn.bottom) {
            msgTipContainerView.top = _bubbleBgImageView.bottom + rmtMessageCellBubbleBgAndMsgTipLabelVPadding;
        }else{
            msgTipContainerView.top = _userAvatarBtn.bottom + rmtMessageCellBubbleBgAndMsgTipLabelVPadding;
        }
        
        msgTipContainerView.centerX = self.width/2;
        
        self.msgTipLabel.origin = CGPointMake(inset.left, inset.top);
        
    }
    ////////
    
    
}

//////
- (void)tapBubbleImageView:(UIGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        [self bubbleBgImageAction];
    }
}

- (void)bubbleBgImageAction{
    
}

- (void)actionForAvatarBtn:(UIButton *)btn{
//    NSString *chatId = currentChatMsgModel.fromId;
//    [[tranbAppDelegate sysDirector] GoUserProfileWithUID:[ContactUnit getTranbIdForChatId:chatId] UMengTag:@"对话cell"];
}

- (void)sendFailedBtnAction:(UIButton *)btn{
    if ([self.delegate respondsToSelector:@selector(messageTableViewCell:resendMessageWithModel:)]) {
        [self.delegate messageTableViewCell:self resendMessageWithModel:currentChatMsgModel];
    }
}


static CGFloat rmtMsgTipContentLabelMaxWidth(){
    return IM_WIDTH_SCREEN - 80;
}

static UIEdgeInsets rmtMsgTipContentLabelInset(){
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

static UILabel * kMsgTipContentLabel() {
    static UILabel *_kMsgTipContentLabel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kMsgTipContentLabel = [UILabel new];
        _kMsgTipContentLabel.font = [UIFont systemFontOfSize:msgContentFontSize];
        _kMsgTipContentLabel.numberOfLines = 0;
    });
    return _kMsgTipContentLabel;
}


+ (CGFloat)heightWithChatMsg:(JChatViewModel *)chatMsg{
    CGFloat cellHeight = rmtMessageCellSubViewTopPadding;
    if (chatMsg.showTimeTip) {
        cellHeight += rmtMessageCellTimeLabelHeight + rmtMessageCellTipLabelsVPadding;
    }else{
        
    }
    
    //如果是群聊 并且在左边，加上名字label的高度
    if (!chatMsg.mine && chatMsg.chatType == kJMSGConversationTypeGroup) {
        cellHeight += rmtMsgNameLabelHeight;
    }
    
    CGFloat bubbleBgHeight = [self bubbleBgImageViewHeightWithChatMsg:chatMsg];
    
    CGFloat lHeight = bubbleBgHeight > rmtMessageCellAvatarBtnSize ? bubbleBgHeight : rmtMessageCellAvatarBtnSize;
    NSString *currentClassName = [NSString stringWithUTF8String:class_getName(self)];
    if ([currentClassName isEqualToString:@"ChatTipMessageTableViewCell"] ||
        [currentClassName isEqualToString:@"ChatSubscribeMessageTableViewCell"]) {
        lHeight = bubbleBgHeight;
    }
    
    cellHeight += lHeight;
    
    if (IM_STR_IS_NIL(chatMsg.msgTipContent)) {
        cellHeight += rmtMessageCellSubViewBottomPadding;
    }else{
        UILabel *label = kMsgTipContentLabel();
        label.text = chatMsg.msgTipContent;
        label.frame = CGRectMake(0, 0, rmtMsgTipContentLabelMaxWidth(), MAXFLOAT);
        [label sizeToFit];
        
        UIEdgeInsets labelInsets = rmtMsgTipContentLabelInset();
        cellHeight += rmtMessageCellBubbleBgAndMsgTipLabelVPadding + label.height + labelInsets.top + labelInsets.bottom;
        cellHeight += rmtMessageCellSubViewBottomPadding;
    }
    
    
    return cellHeight;
}

+ (CGFloat)bubbleBgImageViewHeightWithChatMsg:(JChatViewModel *)chatMsg{
    return 0;
}





@end
