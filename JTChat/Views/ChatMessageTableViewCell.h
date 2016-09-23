//
//  ChatMessageTableViewCell.h
//  JTChat
//
//  Created by 姚卓禹 on 16/5/4.
//  Copyright © 2016年 jiutong. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JChatViewModel;

extern const CGFloat rmtMessageCellSubViewTopPadding;
extern const CGFloat rmtMessageCellSubViewBottomPadding;

extern const CGFloat rmtMessageCellAvatarBtnSize;
extern const CGFloat rmtMessageCellStateActivityIndViewAndBubbleBgViewHPadding;

extern const CGFloat rmtMessageCellAvatarBtnLeftPadding;
extern const CGFloat rmtMessageCellAvatarBtnAndBubbleBgHPadding;


@class ChatMessageTableViewCell;

@protocol ChatMessageTableViewCellDelegate <NSObject>

@optional
//- (void)messageTableViewCell:(RMTMessageTableViewCell *)cell
//actionForExchangeContactWithType:(ExchangeContactType)contactType
//                   messageId:(NSString *)msgId
//                     isAgree:(BOOL)isAgree;

- (void)messageTableViewCell:(ChatMessageTableViewCell * _Nonnull)cell
         reloadWithMessageId:(NSString *_Nonnull)msgId;

- (void)messageTableViewCell:(ChatMessageTableViewCell * _Nonnull)cell
          tapPictureWithView:(UIImageView *_Nonnull)contentImageView
                   messageId:(NSString *_Nonnull)msgId;


- (void)messageTableViewCell:(ChatMessageTableViewCell * _Nonnull)cell
      actionForCustomMsgType:(NSInteger)customMsgType
                      object:(id _Nullable)obj;

- (void)messageTableViewCell:(ChatMessageTableViewCell * _Nonnull)cell
      resendMessageWithModel:(JChatViewModel *_Nonnull)chatMsgModel;

- (void)messageTableViewCell:(ChatMessageTableViewCell * _Nonnull)cell
      actionForTextUrlString:(NSString * _Nullable)urlString;

- (void)messageTableViewCell:(ChatMessageTableViewCell * _Nonnull)cell
      actionForAudioMsgModel:(JChatViewModel * _Nonnull)chatModel;

@end





@interface ChatMessageTableViewCell : UITableViewCell{
    JChatViewModel *currentChatMsgModel;
    UIActivityIndicatorView *stateActivityIndView;
    UIButton *sendFailedBtn;
}

@property (nonatomic, weak, nullable) id<ChatMessageTableViewCellDelegate> delegate;
@property (nonatomic, strong, nonnull) UIButton *userAvatarBtn;
//气泡的背景imageview
@property (nonatomic, strong, nonnull) UIImageView *bubbleBgImageView;
@property (nonatomic, strong, nonnull) UILabel *msgTimeLabel;

@property (nonatomic, strong, nonnull) UILabel *msgTipLabel;

//显示群成员名字
@property (nonatomic, strong, nonnull) UILabel *msgNameLabel;

- ( JChatViewModel * _Nullable )cellChatMsgModel;



//子类重写
- (void)cellSubViewsInit;
- (void)configWithChatMsg:(JChatViewModel * _Nullable)chatMsg;
+ (CGFloat)bubbleBgImageViewHeightWithChatMsg:(JChatViewModel * _Nullable)chatMsg;


//返回高度
+ (CGFloat)heightWithChatMsg:(JChatViewModel * _Nullable)chatMsg;


- (void)bubbleBgImageAction;
- (void)actionForAvatarBtn:(UIButton *_Nullable)btn;

@end


