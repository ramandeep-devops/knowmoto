//
//  ExtensionAppDelegateNotifications.swift
//  Knowmoto
//
//  Created by Apple on 05/10/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
import UserNotifications
import FirebaseCore
import UserNotificationsUI
import FirebaseMessaging

extension AppDelegate : UNUserNotificationCenterDelegate , MessagingDelegate {
    
    
    // SetUp For Remote Notification
    func setUpForRemoteNotification(_ application: UIApplication) {
        
        if #available(iOS 10.0, *) {
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
        } else {
            
            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().delegate = self
            
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Messaging.messaging().apnsToken = deviceToken
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo as? [String : Any] ?? [:]
        self.handlePushNotification(userInfo: userInfo)
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        let userInfos = notification.request.content.userInfo
        
        self.apiGetNotificationsUnreadCount()
//
//        self.handlePushNotification(userInfo: userInfos)
        
        completionHandler([.badge , .sound , .alert])
        
    }
    

//    // Receive displayed notifications for iOS 10 devices.
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        let userInfos = notification.request.content.userInfo
//
//        // Print full message.
//        print(userInfos)
//
//        if let userInfo = userInfos as? [String : Any] {
//
//            // Print full message.
//            print(userInfo)
//
////            let model = PushNotificationModel()
////            model.mapping(userInfo: userInfo)
////
////            if model.pushNotiType == RemoteNotificationType.paymentSuccess || model.pushNotiType == RemoteNotificationType.paymentFailed{
////
////                self.handlePushData(model: model)
////
////            }
////
////            if (ez.topMostVC is MessagesViewController) && ((ez.topMostVC as? MessagesViewController)?.receiverId?.toString == model.oUserId || (ez.topMostVC as? MessagesViewController)?.receiverId?.toString == model.userId || (ez.topMostVC as? MessagesViewController)?.shopId?.toString ==  model.shopId || (ez.topMostVC as? MessagesViewController)?.eventId?.toString ==  model.eventId) {
////                completionHandler([])
////            }
//        }
//
//        // Change this to your preferred presentation option
//        completionHandler([.badge , .sound , .alert])
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//
//        if let userInfo = response.notification.request.content.userInfo as? [String : Any] {
//
//            // Print full message.
//            print(userInfo)
////
////            let model = PushNotificationModel()
////            model.mapping(userInfo: userInfo)
////            self.handlePushData(model: model)
//
//        }
//        completionHandler()
//    }
}

//Messaging delegate

extension AppDelegate{

    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
        debugPrint(remoteMessage.appData)
        
    }
    
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        print("Firebase registration token: \(fcmToken)")
        let dataDict:[String: String] = ["token": fcmToken]
        
        UserDefaults.standard.set(fcmToken, forKey: "fcmToken")
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        
        if !UserDefaultsManager.isGuestUser{
            
            EP_Profile.update_device_token(deviceToken: fcmToken).request(loaderNeeded: false, successMessage: nil, success: { (_) in
                
                
            }, error: nil)
            
        }
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }

    func handlePushNotification(userInfo:[String : Any]){
        
        
        let type = userInfo["type"] as? String
        let vehicleId = userInfo["vehicleId"] as? String
        
        let notificationType = ENUM_NOTIFICATION_TYPE.init(rawValue: /type?.toInt())
        
        switch notificationType ?? .followed {
        case .followed,.liked,.nearBy3Km,.live:
            
            self.openCarDetail(vehicleId: /vehicleId)
            
        case .taggedCar:
 
            let vc = ENUM_STORYBOARD<PostsListVC>.post.instantiateVC()
            vc.isFromAllowPostOnWall = true
            vc.isHideHeaderView = false
            vc.postId = userInfo["postId"] as? String
            vc.taggedId = userInfo["taggedId"] as? String
            vc.type = /type?.toInt()

            topMostVC?.navigationController?.pushViewController(vc, animated: true)
            
            break
            
        
        }
        
    }
   
}
