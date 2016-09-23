//
//  JChatViewModel.swift
//  JTChat
//
//  Created by 姚卓禹 on 16/5/3.
//  Copyright © 2016年 jiutong. All rights reserved.
//

import UIKit
import JMessage

public class JChatViewModel: NSObject {
    public var memberLevel:NSNumber?
    public let message: JMSGMessage
    public let messageTime: NSNumber
    ////为yes表示自己发送的消息，no表示对方发送的消息
    public let mine: Bool
    
    
    let fromId: String
    
    var targetId: String = ""
    public var isGroup: Bool = false
    public var chatType: JMSGConversationType = .Single
    
    // message content type
    public var contentType: JMSGContentType = .Unknown
    
    public var showTimeTip: Bool = false
    
    //文本消息 内容
    public var chatContent: String = " "
    //语音消息 长度
    public var voiceTime: String = ""
    //只有语音才有,是否正在播放
    public var isPlayingAudio: Bool = false
    
    
    public var avatar: String = ""
    
    public lazy var textMsgAttributeContent: NSAttributedString = {
        if self.chatContent.characters.count == 0{
            self.chatContent = " "
        }
        return self.chatContent.expressionAttributedStringWithExpression(MLExpression.chatLabelExpression())
        
    }()
    
    
    public var customMsgType: JMSGCustomMsgType = .None
    public var customMsgDict: NSDictionary = [:]
    
    public var attributeDisplayName: NSAttributedString?
    //信息是否需要加提示，如果为nil  就不加提示
    public var msgTipContent: NSString?
    
    var cellCacheHeight: CGFloat?
    
    public init(message: JMSGMessage) {
        self.message = message
        self.messageTime = message.timestamp
        self.fromId = message.fromUser.username
        
        self.mine = !message.isReceived
        
        if message.content is JMSGTextContent{
            let textContent = message.content as! JMSGTextContent
            contentType = .Text
            chatContent = textContent.text
            
            if let customMsgTypeObj = textContent.extras?[JMSGCustomMsgTypeKey] as? Int,
                extrasString = textContent.extras?[JMSGCustomMsgBodyKey] as? String{
                
                if let customType = JMSGCustomMsgType(rawValue: customMsgTypeObj){
                    contentType = .Custom
                    customMsgType = customType
                    customMsgDict = dictFromString(extrasString)
                }else{
                    chatContent = textContent.text
                }
            }
            
            
        } else if message.content is JMSGImageContent{
            contentType = .Image
        } else if message.content is JMSGVoiceContent{
            contentType = .Voice
            let voiceContent = message.content as! JMSGVoiceContent
            self.voiceTime = "\(voiceContent.duration)"
            
        } else if message.content is JMSGEventContent{
            contentType = .EventNotification
        } else{
            contentType = .Unknown
            chatContent = chatNotSupportMsgTypeTipString
        }
        
    }
    
    
    
    func configWithConversation(conversation: JMSGConversation, targetId: String, isGroup: Bool) {
        
        
        self.targetId = targetId
        self.isGroup = isGroup
        
        if isGroup{
            self.chatType = .Group
        }else{
            self.chatType = .Single
        }
        
        
        
        
    }
    
    
    
    
}
