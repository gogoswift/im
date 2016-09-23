//
//  ChatThreadViewModel.swift
//  JTChat
//
//  Created by 姚卓禹 on 16/4/27.
//  Copyright © 2016年 jiutong. All rights reserved.
//

import Foundation

import JMessage
import ReactiveCocoa
import Result

public enum ChatThreadType: Int{
    case SingleChat = 1
    case GroupChat
    
}

public protocol ChatThreadViewModelProtocol {
    var unreadCount: Int{ get }
    var titleShowString: String{ get set}
    var contentString: String{ get }
    var showDateString: String{ get }
    var avatar: String{ get set}
    var departString: String{ get set}
    var conversation: JMSGConversation?{ get }
    
    var chatID: String{get}
    var ext: Any?{ get }
}


public class ChatThreadViewModel: ChatThreadViewModelProtocol{
    
    let type :ChatThreadType
    
    
    public var unreadCount: Int = 0
    var date: Double = 0
    public var conversation: JMSGConversation?{
        
        didSet{
            guard let conversation = self.conversation else{
                return
            }
            deleNotification(conversation)
            unreadCount = conversation.unreadCount?.integerValue ?? 0
            date = conversation.latestMessage?.timestamp.doubleValue ?? 0
            
            
            //
            if conversation.target is JMSGUser{
                titleShowString = (conversation.target as! JMSGUser).nickname ?? ""
                chatID = (conversation.target as! JMSGUser).username
            }else if conversation.target is JMSGGroup{
//                titleShowString = (conversation.target as! JMSGGroup).name ?? ""
                titleShowString = "采购助手"
                chatID = (conversation.target as! JMSGGroup).gid
            }
            
//            if conversation.latestMessage?.contentType == JMSGContentType.EventNotification {
//                if let id = conversation.latestMessage?.msgId {
//                    conversation.deleteMessageWithMessageId(id)
//                }
//                
//            }
            contentString = conversation.latestMessageContentText()
            showDateString = chatThreadModelShowTimeWithTimestamp(date)
            

//            titleShowString = " "
            departString = ""
        }
    }
    //过滤事件
    func deleNotification(conversation:JMSGConversation){
        if conversation.latestMessage?.contentType == JMSGContentType.EventNotification {
            if let id = conversation.latestMessage?.msgId {
                conversation.deleteMessageWithMessageId(id)
            }
            deleNotification(conversation)
            
        }
    }
    //show
    public var showDateString: String = ""
    public var titleShowString: String = ""
    public var contentString: String = ""
    public var avatar: String = ""
    public var departString: String = ""
    public var chatID: String = ""
    public var ext: Any?
    
    
    init(type: ChatThreadType){
        self.type = type
    }
}

