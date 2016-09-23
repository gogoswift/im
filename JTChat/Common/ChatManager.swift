//
//  ChatManager.swift
//  JTChat
//
//  Created by 姚卓禹 on 16/4/19.
//  Copyright © 2016年 jiutong. All rights reserved.
//

import Foundation
import JMessage
import ReactiveCocoa
import Result

public class ChatManager: NSObject {
    public static let shareChatManager = ChatManager()
    
    
    var chatConfig: ChatConfigType? = DefaultChatConfig()
    
    
    //当前登录的jpush用户信息
    public var currentLoginUser: ChatUserLoginType?
    
    //
    internal let chatLogining = MutableProperty(false)
    
    //消息未读个数
    public let msgsUreadCount = MutableProperty(0)
    //收到消息的时候 signal会出发
    private let msgsRecviveSignal: Signal<Void, NoError>
    private let msgsRecviveSignalObserver: Observer<Void, NoError>
    
    var appProjectType: JTProjectType!
    
    
    //是否在做数据库迁移
    var dbMigrating: Bool = false
    
    private override init() {
        
        //
        let (msgsRecviveSignal, msgsRecviveSignalObserver) = Signal<Void, NoError>.pipe()
        self.msgsRecviveSignal = msgsRecviveSignal.throttle(1, onScheduler: QueueScheduler())
        self.msgsRecviveSignalObserver = msgsRecviveSignalObserver
        
        super.init()
        
        self.msgsRecviveSignal.observeNext {[weak self] in
                self?.computeMessageUnreadCount({ (unreadCount) in
                chatLog("compute message unread count \(unreadCount)")
                self?.msgsUreadCount.value = unreadCount
            })
        }
        
    }
    
    
    
}

//MARK:appdelegete的相关回调需要调用的函数
extension ChatManager{
    //appdelegete的didFinishLaunchingWithOptions方法调用
    public func setupJpushFrameworkWithKey(appKey:JChatAppKey, lanuchOptions:[NSObject: AnyObject]?, apsForProduction:Bool, projectType: JTProjectType){
        
        appProjectType = projectType
        
        
        if let sUserName = NSUserDefaults.standardUserDefaults().objectForKey(jTChatUserName) as? String{
            currentLoginUser = ChatUserLogin(getProjectUserIdWithChatUserId(sUserName))
            chatLog("user default logined user is  \(sUserName)")
//            refreshMsgsUreadCount()
        }
        
        //channel 应用的渠道名称
        JMessage.setupJMessage(lanuchOptions, appKey: appKey.rawValue, channel: " ", apsForProduction: apsForProduction, category: nil)
        
        JPUSHService.registerForRemoteNotificationTypes(UIUserNotificationType.Badge.rawValue |
            UIUserNotificationType.Sound.rawValue |
            UIUserNotificationType.Alert.rawValue, categories: nil)
        
        registerJPushStatusNotification()
        
        
    }
    
    // appdelegete的 didRegisterForRemoteNotificationsWithDeviceToken需要调用
    public func registerDeviceTokenWith(deviceToken: NSData){
        JPUSHService.registerDeviceToken(deviceToken)
    }
    
    //appdelegate的didReceiveRemoteNotification:fetchCompletionHandler 需要调用
    public func handleRemoteNotificationWithUserInfo(userInfo:[NSObject : AnyObject]){
        JPUSHService.handleRemoteNotification(userInfo)
    }
    
    
    //设置别名，用于jpush 推送
    public func setAliasWithName(aliasName: String) -> SignalProducer<Bool, NSError>{
        return SignalProducer { observer, disposable in
            
            JPUSHService.setTags(nil, alias: aliasName, fetchCompletionHandle: { (resultCode, tags, aliasName) in
                chatLog("set aliasName reuslt \(resultCode)  \(tags) \(aliasName)")
                if(resultCode == 6002){
                    //超时，重试
                    chatLog("set aliasName timeout ,retry......................")
                    self.setAliasWithName(aliasName).start(observer)
                }else if(resultCode == 0){
                    //成功
                    observer.sendNext(true)
                    observer.sendCompleted()
                }else{
                    //其他类型错误
                    observer.sendFailed(NSError(domain: ChatErrorDomain.jpush, code: Int(resultCode), userInfo: nil))
                }
            })
        }
    }
    
    //当其他设备登录，或者登录失效的时候，调用此方法  (任意jpush操作返回jmsg_error Code=863004的时候)
    internal func reLoginIMUser(){
        if self.chatLogining.value {
            return
        }
        guard let currentLoginUser = self.currentLoginUser else{
            return
        }
        
        self.currentLoginUser = nil
        
        chatLog("reLogin im user")
        self.loginIMWithUserLoginInfo(currentLoginUser).startOn(QueueScheduler()).start()
    }
    
    public func loginIMWithUserLoginInfo(userLoginType: ChatUserLoginType) -> SignalProducer<Bool, NSError>{
        return SignalProducer { observer, disposable in
            //如果当前userdefault里面存储的是要登录的帐号，直接当做登录成功
            if let currentLoginUser = self.currentLoginUser where currentLoginUser == userLoginType{
                observer.sendNext(true)
                self.loginedSuccessedWithUserLoginInfo(userLoginType)
                observer.sendCompleted()
                return
            }
            
            self.currentLoginUser = nil
            self.removeLoginInfoKey()
            
            self.chatLogining.value = true
            JMSGUser.loginWithUsername(userLoginType.userJChatId, password: userLoginType.userJchatPwd, completionHandler: { (_, error) in
                if (error != nil){
                    if (error.code == 801003){
                        chatLog("login error, user \(userLoginType.userJChatId) not has register in Jpush")
                      self.registerIMWithUserLoginInfo(userLoginType).start(observer)
                    }else{
                        chatLog("login error, user \(userLoginType.userJChatId) error \(error)")
                        observer.sendFailed(error)
                        self.chatLogining.value = false
                    }
                }else{
                    //登录成功
                    observer.sendNext(true)
                    
                    
                    chatLog("logined successed with user \(userLoginType.userJChatId)")
                    self.loginedSuccessedWithUserLoginInfo(userLoginType)
                    observer.sendCompleted()
                    NSNotificationCenter.defaultCenter().postNotificationName(JTChatLoginSuccessed, object: nil)
                    self.chatLogining.value = false
                }
            })
        }
    }
    
    //更新消息push的时候显示的用户名信息
    public func updatePushUserNickNameWith(nickName: String){
        JMSGUser.updateMyInfoWithParameter(nickName, userFieldType: JMSGUserField.FieldsNickname, completionHandler: nil)
    }
    
    public func refreshMsgsUreadCount(){
        self.msgsRecviveSignalObserver.sendNext()
    }
    
    
    //是否正在登录
    public func chatInLogining() -> Bool{
        return chatLogining.value
    }
    
}

private let jTChatUserName = "jchat.username"

//MARK: private
extension ChatManager{
    private func registerIMWithUserLoginInfo(userLoginType: ChatUserLoginType) -> SignalProducer<Bool, NSError>{
        return SignalProducer{ observer, disposable in
            JMSGUser.registerWithUsername(userLoginType.userJChatId, password: userLoginType.userJchatPwd, completionHandler: { (_, err) in
                
                if (err != nil){
                    //
                    chatLog("register error, user \(userLoginType.userJChatId) err:\(err)")
                    observer.sendFailed(err)
                }else{
                    //注册成功
                    chatLog("register successed, user \(userLoginType.userJChatId)")
                    observer.sendNext(true)
                    self.loginedSuccessedWithUserLoginInfo(userLoginType)
                    observer.sendCompleted()
                }
                self.chatLogining.value = false
            })
        }
    }

    private func loginedSuccessedWithUserLoginInfo(userLoginType: ChatUserLoginType){
        
        
        self.currentLoginUser = userLoginType
        
        
        NSUserDefaults.standardUserDefaults().setObject(self.currentLoginUser?.userJChatId, forKey: jTChatUserName)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        computeMessageUnreadCount { (unreadCount) in
            self.msgsUreadCount.value = unreadCount
        }

    }
    
    private func removeLoginInfoKey(){
        NSUserDefaults.standardUserDefaults().removeObjectForKey(jTChatUserName)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    private func computeMessageUnreadCount(unreadCompletedHandelr:(unreadCount:Int) -> Void){
        JMSGConversation.allConversations { (result, err) in
            guard let conversations = result as? [JMSGConversation] else{
                unreadCompletedHandelr(unreadCount: 0)
                return
            }

            let unreadMsgsCount = conversations.reduce(0, combine: { (c, conversation) -> Int in
                return c + (conversation.unreadCount?.integerValue ?? 0)
            })
            unreadCompletedHandelr(unreadCount: unreadMsgsCount)
            
        }
    }
    
    
    
}



extension ChatManager: JMessageDelegate{
    public func onReceiveMessage(message: JMSGMessage!, error: NSError!) {
        if error == nil{
            self.msgsRecviveSignalObserver.sendNext()
            chatLog("recived message -------------- \(message)")
        }
    }
    
    public func onConversationChanged(conversation: JMSGConversation!) {
        self.msgsRecviveSignalObserver.sendNext()
    }
    
    public func onDBMigrateStart() {
        dbMigrating = true
    }
    
    public func onDBMigrateFinishedWithError(error: NSError!) {
        dbMigrating = false
    }
    
    
    
    
}

//MARK: private funcation
extension ChatManager{
    private func registerJPushStatusNotification(){
        JMessage.addDelegate(self, withConversation: nil)
        let defaultCenter = NSNotificationCenter.defaultCenter()
        defaultCenter.addObserver(self, selector: #selector(ChatManager.networkDidSetup(_:)), name: kJPFNetworkDidSetupNotification, object: nil)
        defaultCenter.addObserver(self, selector: #selector(ChatManager.networkIsConnecting(_:)), name: kJPFNetworkIsConnectingNotification, object: nil)
        defaultCenter.addObserver(self, selector: #selector(ChatManager.networkDidClose(_:)), name: kJPFNetworkDidCloseNotification, object: nil)
        defaultCenter.addObserver(self, selector: #selector(ChatManager.networkDidRegister(_:)), name: kJPFNetworkDidRegisterNotification, object: nil)
        defaultCenter.addObserver(self, selector: #selector(ChatManager.networkDidLogin(_:)), name: kJPFNetworkDidLoginNotification, object: nil)
        defaultCenter.addObserver(self, selector: #selector(ChatManager.receivePushMessage(_:)), name: kJPFNetworkDidReceiveMessageNotification, object: nil)
        
        
    }
    
    
    func networkDidSetup(notification: NSNotification){
        
    }
    
    func networkIsConnecting(notification:NSNotification) {
        
    }
    
    // notification from JPush
    func networkDidClose(notification:NSNotification) {
        
    }
    
    // notification from JPush
    func networkDidRegister(notification:NSNotification) {
        
    }
    
    // notification from JPush
    func networkDidLogin(notification:NSNotification) {
        
    }
    // notification from JPush
    
    func receivePushMessage(notification:NSNotification) {
        
    }
}



