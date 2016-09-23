//
//  ChatCommon.swift
//  JTChat
//
//  Created by 姚卓禹 on 16/4/20.
//  Copyright © 2016年 jiutong. All rights reserved.
//

import Foundation
import JMessage


public enum JChatAppKey: String{
    case DDQPTest = "29983b3bef80b58053499c85"
    case DDQPRelease = "e007ebbea1c0b3e2f5815558"
}

public enum JTProjectType: Int{
    case DDQP = 1
    case DDZB = 2
    case RMT = 3
}



@objc public enum JMSGCustomMsgType : Int {
    
    /// 不知道类型的消息
    case None = 0
    //商品卡片
    case BrowseProduct = 7
    /*
    /// 名片
    case Card = 1
    /// 电话交换请求
    case PhoneExchangeRequest = 2
    ///
    case PhoneExchangeResponse = 3
    ///
    case WeiXinExchangeRequest = 4
    ///
    case WeiXinExchangeResponse = 5
    ///
    case RecommendUsers = 101
    case RecommendProducts = 102
    case RecommendPurchases = 103
    case RecommendSpreadResult = 104
    case RecommendNotice = 105
    case InviteGroupMemberContent = 106
    case InviteGroupActivityContent = 107
     */
}

let jPushUpLoadOriginImgWidth = 720
let jPushUpLoadImgWidth = 500

public let JMSGCustomMsgTypeKey: String = "customMsgType"
public let JMSGCustomMsgBodyKey: String = "customMsgBody"



//////BrowseProduct Key
public let CustomMsg_Product_Id = "productId"
public let CustomMsg_Product_UserId = "productUserId"
public let CustomMsg_Product_Name: String = "productName"
public let CustomMsg_Product_Price = "productPrice"
public let CustomMsg_Product_ImageUrl = "productImageUrl"

//Notification Name
public let JTChatLoginSuccessed: String = "JTChatLoginSuccessed"


internal struct DefaultChatConfig : ChatConfigType{
    func chatLog(@autoclosure closure: () -> String?){
        print(closure())
    }
}

public struct ChatUserLogin : ChatUserLoginType{
    public init(_ userJChatId: String){
        let proType: JTProjectType = ChatManager.shareChatManager.appProjectType
        switch  proType{
        case .DDQP:
            self.userJChatId = String((Int(userJChatId) ?? 0) * 3)
            self.userJchatPwd = userJChatId
        default:
            self.userJChatId = userJChatId
            self.userJchatPwd = userJChatId
        }
        
    }
    public let userJChatId: String
    public let userJchatPwd: String
}

//由jpush的chatid获取对应工程的userid
public func getProjectUserIdWithChatUserId(chatUserId: String) -> String{
//    let proType: JTProjectType = ChatManager.shareChatManager.appProjectType
//    switch  proType{
//    case .DDQP:
//        return String((Int(chatUserId) ?? 0) / 3)
//    default:
//        return String(chatUserId)
//    }
    
    return String(getProjectUserIDWithChatUserId(chatUserId))
}

public func getProjectUserIDWithChatUserId(chatUserId: String) -> Int{
    let proType: JTProjectType = ChatManager.shareChatManager.appProjectType
    switch  proType{
    case .DDQP:
        return (Int(chatUserId) ?? 0) / 3
    default:
        return Int(chatUserId) ?? 0
    }
    
}


//由对应工程的userid获取jpush的chatid
public func getChatUserIdWithProjectUserId(projectUserId: String) -> String{
    let proType: JTProjectType = ChatManager.shareChatManager.appProjectType
    switch  proType{
    case .DDQP:
        return String((Int(projectUserId) ?? 0) * 3)
    default:
        return String(projectUserId)
    }
}


public protocol ChatConfigType{
    //打印log信息
    func chatLog(@autoclosure closure: () -> String?)
}


public protocol ChatUserLoginType{
    var userJChatId: String { get }
    var userJchatPwd: String { get }
    
}

func == (left: ChatUserLoginType, right: ChatUserLoginType) -> Bool {
    return left.userJChatId == right.userJChatId && left.userJchatPwd == right.userJchatPwd
}




func chatLog(@autoclosure closure: () -> String?){
    ChatManager.shareChatManager.chatConfig?.chatLog(closure)
}


struct ChatErrorDomain {
    static let jpush = "jpush"
}

func errorIsUserLoginInvalid(errorCode: Int) -> Bool{
    if errorCode == Int(JMSGTcpErrorCode.ErrorTcpUserLogoutState.rawValue) ||
    errorCode == Int(JMSGTcpErrorCode.ErrorTcpUserOfflineState.rawValue) ||
        errorCode == Int(JMSGSDKErrorCode.JMSGErrorSDKUserNotLogin.rawValue){
        return  true
    }
    return false
}


///////
public func getGroupChatConversation(groupID: String, completedBlock:(conversation:JMSGConversation?)->Void){
    if ChatManager.shareChatManager.chatInLogining(){
        WaitingInterfaceUtil.sharedInstance().showFailureOnTopWindow("登录中，请稍候")
        completedBlock(conversation: nil)
        return
    }
    
    JMSGConversation.createGroupConversationWithGroupId(groupID) { (result, error) in
        dispatch_async(dispatch_get_main_queue(), {
            
            if error != nil{
                chatLog("createSingleConversationWithUsername error \(error!)")
                if errorIsUserLoginInvalid(error.code){
                    //用户没有登录
                    ChatManager.shareChatManager.reLoginIMUser()
                    WaitingInterfaceUtil.sharedInstance().showFailureOnTopWindow("登录中，请稍候")
                    
                }else{
                    WaitingInterfaceUtil.sharedInstance().showFailureOnTopWindow("失败，请稍候")
                }
                completedBlock(conversation: nil)
                return
            }
            
            guard let conversation = result as? JMSGConversation else{
                WaitingInterfaceUtil.sharedInstance().showFailureOnTopWindow("创建回话失败，请稍候")
                completedBlock(conversation: nil)
                return
            }
            
            completedBlock(conversation: conversation)
            
        })
    }
}


public func getChatConversationWithUsername(chatID: String, completedBlock:(conversation:JMSGConversation?)->Void){
    if ChatManager.shareChatManager.chatInLogining(){
        WaitingInterfaceUtil.sharedInstance().showFailureOnTopWindow("登录中，请稍候")
        completedBlock(conversation: nil)
        return
    }
    
    JMSGConversation.createSingleConversationWithUsername(chatID) { (result, error) in
        dispatch_async(dispatch_get_main_queue(), {
            
            if error != nil{
                chatLog("createSingleConversationWithUsername error \(error!)")
                if errorIsUserLoginInvalid(error.code){
                    //用户没有登录
                    ChatManager.shareChatManager.reLoginIMUser()
                    WaitingInterfaceUtil.sharedInstance().showFailureOnTopWindow("登录中，请稍候")
                    
                }else{
                    WaitingInterfaceUtil.sharedInstance().showFailureOnTopWindow("失败，请稍候")
                }
                completedBlock(conversation: nil)
                return
            }
            
            guard let conversation = result as? JMSGConversation else{
                WaitingInterfaceUtil.sharedInstance().showFailureOnTopWindow("创建回话失败，请稍候")
                completedBlock(conversation: nil)
                return
            }
            
            completedBlock(conversation: conversation)
            
        })
    }
}

////////
func chatThreadModelShowTimeWithTimestamp(date: Double) -> String{
    let theDate = NSDate(timeIntervalSince1970: date)
    return theDate.getThreadModelFormatDateString()
}

///屏幕宽度
public func screenWidth() -> CGFloat{
    return UIScreen.mainScreen().bounds.width
}



////// json string  dict 转换

public func stringFromDict(dict: NSDictionary) -> NSString{
    if dict.count == 0{
        return ""
    }
    
    var string: NSString = ""
    do{
        let jsonData = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions(rawValue: 0))
        string = NSString(data: jsonData, encoding: NSUTF8StringEncoding) ?? ""
    }catch _ {
        
    }
    return string
}

public func dictFromString(string: NSString) -> NSDictionary{
    if string.length == 0{
        return [:]
    }
    
    guard let data = string.dataUsingEncoding(NSUTF8StringEncoding) else{
        return [:]
    }
    
    return ((try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))) as? NSDictionary) ?? [:]
}




//////
//MARK: 自定义 Dictionary +=
public func += <KeyType, ValueType>(inout left: Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>){
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}



///////
public func showAlertWithTitle(title: String, message: String, presentViewController: UIViewController){
    let alartVC = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    let cancel = UIAlertAction(title: "确定", style: UIAlertActionStyle.Cancel, handler: { (action) -> Void in
        
    })
    alartVC.addAction(cancel)
    presentViewController.presentViewController(alartVC, animated: true, completion: nil)
}


func deletFileWithPath(path: String){
    if path.isEmpty{
        return
    }
    
    _ = try? NSFileManager.defaultManager().removeItemAtPath(path)
    return
}


extension UINavigationController {
    func navBarStyle() {
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
        self.navigationBar.barTintColor = UIColor(hexString: "0xFF7817")//UIColor(hex: "#FF7817")
        self.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationBar.barStyle = UIBarStyle.Black//设置系统电池颜色
        self.navigationBar.translucent = false
        //设置标题颜色，及标题字体大小
        let parames = [NSFontAttributeName : UIFont.systemFontOfSize(18),
                       NSForegroundColorAttributeName : UIColor.whiteColor()]
        self.navigationBar.titleTextAttributes = parames
        
//        //清除navigationBar下默认的白线
//        self.navigationBar.setBackgroundImage(UIImage(), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
//        self.navigationBar.shadowImage = UIImage()
    }
    
    func setInteractivePopGestureRecognizer(enabler:Bool) {
        
        if self.respondsToSelector(Selector("interactivePopGestureRecognizer")) {
            
            self.interactivePopGestureRecognizer?.enabled = enabler;
            
        }
        
    }
    
}






