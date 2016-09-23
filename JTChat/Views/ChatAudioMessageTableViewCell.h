//
//  ChatAudioMessageTableViewCell.h
//  JTChat
//
//  Created by 姚卓禹 on 16/5/5.
//  Copyright © 2016年 jiutong. All rights reserved.
//

#import "ChatMessageTableViewCell.h"

@class JMSGMessage;
@class JMSGConversation;

@interface ChatAudioMessageTableViewCell : ChatMessageTableViewCell

@property (nonatomic, strong) JMSGMessage *auidoMessage;
@property (nonatomic, strong) JMSGConversation *conversation;

@end
