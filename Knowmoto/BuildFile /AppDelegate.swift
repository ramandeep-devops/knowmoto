//
//  AppDelegate.swift
//  Knowmoto
//
//  Created by Apple on 25/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import KontaktSDK
import Fabric
import FirebaseCore
import Crashlytics
import FirebaseDynamicLinks


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //keyboard configguration
        UITextField.appearance().keyboardAppearance = .dark
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = true
        
        //kontakt api for beacons
        Kontakt.setAPIKey(APIBasePath.accessTokenKontaktIO)
        KontaktBeaconDataSource.shared.beaconSearchConfiguration()
        
        //firebase
        FirebaseApp.configure()
        
        //socket.io client
        SocketAppManager.sharedManager.initializeSocket()
        
        //cllocation update
        LocationManager.shared.configureCLLocation()
        
        //notification setup
        setUpForRemoteNotification(application)
        
        
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) != nil {
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // ...
            return true
        }
        return false
        
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        if let incomigURL = userActivity.webpageURL{
            
            self.startAnimateLoader(message: "Loading...")
            let linkHandle = DynamicLinks.dynamicLinks().handleUniversalLink(incomigURL) { (dynamiclink, error) in
                
//                self.stopAnimateLoader()
                if let dynamiclink = dynamiclink, let _ = dynamiclink.url {
                    self.handleIncomingDynamicLink(dynamicLink: dynamiclink)
                } else {
                    print("dynamiclink = nil")
                }
            }
            return linkHandle
        }
        print("userActivity = nil")
        return false
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        self.apiGetNotificationsUnreadCount()
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Knowmoto")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
 
    func reInstantiateWindow(){
        
        let isLoggedInUser = UserDefaultsManager.shared.loggedInUser?.accessToken != nil

        guard let window = self.window else { return}

//        if(isLoggedInUser) {

            let storyBoard = UIStoryboard(name: ENUM_STORYBOARD.tabbar.rawValue, bundle: nil)
            guard let navigationController = (storyBoard.instantiateInitialViewController() as? UINavigationController) else {
                return
            }
            

            self.setWindowAnimation(window : window , rootViewController : navigationController , statusBarColor : UIColor.clear)

//        }
        
    }
    
    func setWindowAnimation(window : UIWindow , rootViewController : UIViewController , statusBarColor : UIColor) {
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            
            window.rootViewController = rootViewController
            }, completion: { completed in
                // maybe do something here
        })
    }

}

//MARK:- Deep link handling
extension AppDelegate{
    
    func handleIncomingDynamicLink(dynamicLink:DynamicLink){
        
        if /dynamicLink.url?.absoluteString.contains(APIBasePath.firebaseDynamicBasePath + "/" + ENUM_DYNAMIC_LINK_TYPE.postId.rawValue){
            
            if let postId = dynamicLink.url?.lastPathComponent{
                self.redirectToPostDetail(postId: postId)
            }
            
        }else if /dynamicLink.url?.absoluteString.contains(APIBasePath.firebaseDynamicBasePath + "/" + ENUM_DYNAMIC_LINK_TYPE.vehicleId.rawValue){
            
            if let vehicleId = dynamicLink.url?.lastPathComponent{
                self.redirectToCarDetail(vehicleId: vehicleId)
            }
            
        }
        
    }
    
    func redirectToCarDetail(vehicleId:String){
        
        let vc = ENUM_STORYBOARD<CarDetailSegmentedVC>.car.instantiateVC()
        vc.vehicleId = vehicleId
        vc.isFromCarDetail = true
        
        topMostVC?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func redirectToPostDetail(postId:String){
        
        let vc = ENUM_STORYBOARD<PostsListVC>.post.instantiateVC()
        vc.isHideHeaderView = false
        vc.postId = postId
        if topMostVC?.navigationController == nil{
            topMostVC?.present(vc, animated: true, completion: nil)
        }else{
            topMostVC?.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}
