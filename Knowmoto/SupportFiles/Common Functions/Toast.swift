import Foundation
import SwiftMessages

class Toast {
    
  class func show(text: String?,type: Theme,changeBackground:Bool = false){
    
    let view = MessageView.viewFromNib(layout: .messageView)
    
    // Theme message elements with the warning style.
    view.configureTheme(type)
//    let isUserLoggedIn = UserSingleton.shared.loggedInUser?.data?.accessToken != nil
    view.configureTheme(type)
    view.backgroundColor = UIColor.BlueColor!

//    view.backgroundHeight = 80
    
    view.titleLabel?.font = ENUM_APP_FONT.bold.size(18)
    view.bodyLabel?.font = ENUM_APP_FONT.book.size(14)
    
    view.button?.isHidden = true
    view.configureContent(title: type == Theme.error ? AlertMessageTitle.alert.localized() : AlertMessageTitle.success.localized(), body: /text, iconImage: nil, iconText: nil, buttonImage: nil, buttonTitle: "OK") { (button) in
        SwiftMessages.hide()
    }
//    view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    SwiftMessages.defaultConfig.presentationStyle = .top
    
    SwiftMessages.defaultConfig.presentationContext = .window(windowLevel: UIWindow.Level.statusBar)
    
    // Disable the default auto-hiding behavior.
    SwiftMessages.defaultConfig.duration = .automatic
    
    // Dim the background like a popover view. Hide when the background is tapped.
    //SwiftMessages.defaultConfig.dimMode = .gray(interactive: true)
    SwiftMessages.defaultConfig.dimMode = .none
    
    // Disable the interactive pan-to-hide gesture.
    SwiftMessages.defaultConfig.interactiveHide = true
    
    // Specify a status bar style to if the message is displayed directly under the status bar.
    SwiftMessages.defaultConfig.preferredStatusBarStyle = .default
    // Show message with default config.
    SwiftMessages.show(view: view)
    
    // Customize config using the default as a base.
    var config = SwiftMessages.defaultConfig
    config.duration = .forever
    
    // Show the message.
    SwiftMessages.show(config: config, view: view)
  }
}
