//
//  Extension.swift
//  Idea
//
//  Created by Dhan Guru Nanak on 2/16/18.
//  Copyright © 2018 OSX. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import NVActivityIndicatorView
import SafariServices
import Kingfisher
import CoreLocation
import Photos
import Mapbox
import MapboxGeocoder
import AWSS3
import FirebaseDynamicLinks

typealias didTapTermsOfService = ()->()
typealias didTapPrivacyPolicy = ()->()

extension UILabel{
  
    func addImage(imageName: String, afterLabel bolAfterLabel: Bool = false)
    {
        let attachment: NSTextAttachment = NSTextAttachment()
        attachment.image = UIImage(named: imageName)
        let attachmentString: NSAttributedString = NSAttributedString(attachment: attachment)
        
        if (bolAfterLabel)
        {
            let strLabelText: NSMutableAttributedString = NSMutableAttributedString(string: self.text!)
            strLabelText.append(attachmentString)
            
            self.attributedText = strLabelText
        }
        else
        {
            let strLabelText: NSAttributedString = NSAttributedString(string: self.text!)
            let mutableAttachmentString: NSMutableAttributedString = NSMutableAttributedString(attributedString: attachmentString)
            mutableAttachmentString.append(strLabelText)
            
            self.attributedText = mutableAttachmentString
        }
    }
    
    func removeImage()
    {
        let text = self.text
        self.attributedText = nil
        self.text = text
    }
    
  func setLineSpacing(lineSpacing: CGFloat = 0.0, lineHeightMultiple: CGFloat = 0.0) {
    
    guard let labelText = self.text else { return }

    let attributedString = NSMutableAttributedString(string: labelText)
    
    // *** Create instance of `NSMutableParagraphStyle`
    let paragraphStyle = NSMutableParagraphStyle()
    
    // *** set LineSpacing property in points ***
    paragraphStyle.lineSpacing = lineSpacing // Whatever line spacing you want in points
    
    // *** Apply attribute to string ***
    attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
    
    // *** Set Attributed String to your label ***
    self.attributedText = attributedString
  }
  
//  func setUpTermsAndContion(text:String){
//    
//    self.attributedText = Utility.shared.getAttributedTextWithFont(text: text, font: UIFont.systemFont(ofSize: 14))
//    self.setLineSpacing(lineSpacing: 4, lineHeightMultiple: 0)
//    
//    let text = /self.text
//    let underlineAttriString = NSMutableAttributedString(string: text)
//    let range1 = (text as NSString).range(of: "terms of Service")
//    underlineAttriString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: range1)
//    
//    let range2 = (text as NSString).range(of: "Privacy Policy")
//    underlineAttriString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: range2)
//    self.attributedText = underlineAttriString
//  }
  
}

extension UIViewController : NVActivityIndicatorViewable {
  
    
    func presentWithNavigationController(){
        
        let navigationController = UINavigationController(rootViewController: self)
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.isHidden = true
        navigationController.navigationBar.barTintColor = UIColor.clear
        
        topMostVC?.present(navigationController, animated: true, completion: nil)
        
    }
    
    func showInputDialog(cancelNeeded:Bool = false,title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? =  ButtonTitle.cancel.localized(),
                         inputPlaceholder:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((_ text: String?) -> Void)? = nil
        ) {
        
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
//        alert.view.tintColor  = UIColor.colorDefaultApp()
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = inputPlaceholder
            textField.keyboardType = inputKeyboardType
        }
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            actionHandler?(textField.text)
        }))
        if cancelNeeded{
            alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func isCameraPermission(actionOkButton: ((_ isOk: Bool) -> Void)? = nil){
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        switch cameraAuthorizationStatus {
        case .authorized: actionOkButton!(true)
        case .restricted: actionOkButton!(false)
        case .denied: actionOkButton!(false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
                
                if granted {
                    actionOkButton!(true)
                }else {
                    actionOkButton!(false)
                }
            })
        }
    }

  
  func openHyperLink(link:String?){
    var addUrl = link
    if addUrl?.lowercased().hasPrefix("http://")==false{
      addUrl = "http://" + /addUrl
    }
    
    guard let url = URL(string: /addUrl) else {
      return //be safe
    }
    let safariVC = SFSafariViewController(url:url)
    safariVC.delegate = self as? SFSafariViewControllerDelegate
    topMostVC?.present(safariVC, animated: false)
    
  }
  
  func openVideoPlayer(url:String){
    
    if let url = URL(string: url){
      
      let player = AVPlayer(url: url)
      let playerViewController = AVPlayerViewController()
      playerViewController.player = player
      
      self.present(playerViewController, animated: true) {
        playerViewController.player!.play()
      }
    }
  }
  
  
  func showShare(shareLink : [Any]?){
    
    if let linkToShare = shareLink, !linkToShare.isEmpty{
      
      let objectsToShare = [link] as [Any]
      
      let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
      
      topMostVC?.present(activityVC, animated: true, completion: nil)
      
    }
  }
  
}

extension NSObject {

    
    
    //getting location address object
    
    func getLocationAddressObject(data:Any?) ->LocationAddress{ //for save this object to recent searches
        
        if let location = data as? GeocodedPlacemark{
            
            let state = location.addressDictionary?["state"] as? String
            let nameWithState = [/location.name,/state].joined(separator: ",")
            
            debugPrint(/location.formattedName)
            
            let locationAddress = LocationAddress(address: /location.qualifiedName, latitude: location.location?.coordinate.latitude, longitude: location.location?.coordinate.longitude, state: state, name: /location.name)
            
            return locationAddress
            
        }else if let location = data as? LocationAddress{
            
            return location
        }
        
        return LocationAddress()
    }
    
    func setTableViewBackgroundView(tableview:UITableView,noDataFoundText:String? = nil){
        
        
        let view = UIView(frame: tableview.bounds)
        
        let label = UILabel(frame: CGRect(x: tableview.frame.midX, y: tableview.frame.midY, width: tableview.bounds.width, height: 56))
        label.center = view.center
        
        view.addSubview(label)
        view.backgroundColor = UIColor.clear
        label.font = ENUM_APP_FONT.bold.size(16)
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.text = noDataFoundText ?? "No data found"
        
        
        tableview.backgroundView = view
        
    }
    
    func setCollectionViewBackgroundView(collectionView:UICollectionView,noDataFoundText:String? = nil,yaxis:CGFloat = 32,textColor:UIColor = .white){
        
        let view = UIView(frame: collectionView.bounds)
        let label = UILabel(frame: CGRect(x: collectionView.center.x, y: collectionView.center.y, width: collectionView.bounds.width, height: 56))
        label.center = collectionView.center
//        label.center.y = label.center.y - yaxis
        label.textAlignment = .center
        view.addSubview(label)
        view.backgroundColor = UIColor.clear
        label.font = ENUM_APP_FONT.bold.size(16)
        label.textColor = textColor
        label.text = noDataFoundText ?? "No data found!"
        
        collectionView.backgroundView = view
    }
    
    func switchTab(tab:ENUM_HOME_TAB){
        
        guard let tabbarVC = (topMostVC?.navigationController?.viewControllers.first as? UITabBarController) else {return}
        
        tabbarVC.selectedIndex = tab.rawValue
    }
    
    func openAlertForSettings(for PermissionType:PermissionType){
        
        switch PermissionType {
            
        case .camera:
            
            UtilityFunctions.show(alert: "Enable camera access".localized, message: "knowmoto does not have access to your Camera. To enable access, tap Settings and turn on Camera".localized, buttonText: "Settings".localized, buttonOk: { [weak self] in
                
                self?.openSettings()
            })
            
        case .photos:
            
            UtilityFunctions.show(alert: "Enable photos access".localized, message: "Please enable photo permission from settings".localized, buttonText: "Settings".localized, buttonOk: { [weak self] in
                
                self?.openSettings()
            })
            
        case .microphone:
            
            UtilityFunctions.show(alert: "Enable MicroPhone Access".localized, message: "knowmoto does not have access to your MicroPhone. To enable access, tap Settings and turn on Camera".localized, buttonText: "Settings".localized, buttonOk: { [weak self] in
                
                self?.openSettings()
            })
            
        case .locationAlwaysInUse:
            
            UtilityFunctions.show(alert: "Enable Location Access".localized, message: "knowmoto required your location access for detect your current location, nearby live cars or to go live. To enable access, tap Settings and turn on Location".localized, buttonText: "Settings".localized, buttonOk: { [weak self] in
                
                self?.openSettings()
            })
            
        default:
            break
        }
        
    }
    
    func startAnimateLoader(message:String? = nil,color:UIColor = UIColor.white){
        
        let activityData = ActivityData(size: CGSize.init(width: 24, height: 24), message: message, messageFont: ENUM_APP_FONT.bold.size(14), type: .circleStrokeSpin, color: color, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: nil, textColor: nil)
      
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData, nil)
    }
    
    func setLoaderMessage(message:String){
        
        NVActivityIndicatorPresenter.sharedInstance.setMessage(message)
    }
    
    func stopAnimateLoader(){
        
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        
    }
    
    public var topMostVC:UIViewController?{
        return UIApplication.getTopViewController()
    }
    
    func openSettings(){
        
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(settingsUrl)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(settingsUrl)
            }
        }
        
    }
  
  func checkForLocationPermissoion() {
    
    if CLLocationManager.locationServicesEnabled() {
      
      switch(CLLocationManager.authorizationStatus()) {
        
      case  .restricted, .denied:
        openSettings()
        
      case .authorizedAlways, .authorizedWhenInUse:
       break
      case .notDetermined:
        break
      }
    } else {
      debugPrint("Location services are not enabled")
    }
  }

  
  
  func alertBox(message:String,okButtonTitle:String = ButtonTitle.ok.localized(),title:String, ok:@escaping ()->()){
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    
//    alert.view.tintColor = UIColor.colorDefaultApp()
    
    alert.addAction(UIAlertAction(title: okButtonTitle, style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
      ok()
    }))
    alert.addAction(UIAlertAction(title:ButtonTitle.cancel.localized(), style: UIAlertAction.Style.cancel, handler: { (action: UIAlertAction!) in
      alert.dismiss(animated: true, completion: nil)
    }))
    
    alert.showW()
//    topMostVC?.present(alert, animated: true, completion: nil)
  }
  
  func alertBox(message:String,title:String,leftButtonTitle:String?,rightButtonTitle:String?,leftButton:@escaping ()->(),rightButton:@escaping ()->()){
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    
//    alert.view.tintColor = UIColor.colorDefaultApp()
    
    alert.addAction(UIAlertAction(title:leftButtonTitle, style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
        leftButton()
        }))
    
    alert.addAction(UIAlertAction(title: rightButtonTitle, style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
      rightButton()
      
    }))
    

    
    alert.showW()
    
//    ez.topMostVC?.present(alert, animated: true, completion: nil)
  }
  
  
  func alertBox(message:String,okButtonTitle:String = ButtonTitle.ok.localized(),title:String, ok:(()->())?,cancel:(()->())?){
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    
//    alert.view.tintColor = UIColor.colorDefaultApp()
    
    alert.addAction(UIAlertAction(title: okButtonTitle, style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
      ok?()
    }))
    alert.addAction(UIAlertAction(title:"Cancel".localized, style: UIAlertAction.Style.cancel, handler: { (action: UIAlertAction!) in
      cancel?()
      alert.dismiss(animated: true, completion: nil)
    }))
    
    alert.showW()
  }
  
    func alertBoxOk(alignment:NSTextAlignment = .center,message:String,title:String, ok:@escaping ()->()){
    
    let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    
    paragraphStyle.alignment = alignment
    
    let messageText = NSMutableAttributedString(
        string: message,
        attributes: [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)
        ]
    )
    
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    
//    alert.view.tintColor = UIColor.colorDefaultApp()
    
        alert.addAction(UIAlertAction(title: "Ok".localized, style: UIAlertAction.Style.default, handler: { (action: UIAlertAction!) in
      ok()
    }))
    
    
    
    alert.setValue(messageText, forKey: "attributedMessage")
    alert.showW()
  }
  
  func callToNumber(number : String?){
    
    if let url = URL(string: "tel://\(number ?? "9875642354")"), UIApplication.shared.canOpenURL(url) {
      if #available(iOS 10, *) {
        UIApplication.shared.open(url)
      } else {
        UIApplication.shared.openURL(url)
      }
    }
    
  }
  
  
  func sendEmailToUser(emalAddress : String?){
    
    let email = emalAddress ?? "foo@foo.com"
    if let url = URL(string: "mailto:\(email)") ,UIApplication.shared.canOpenURL(url)  {
      if #available(iOS 10, *) {
        UIApplication.shared.open(url)
      } else {
        UIApplication.shared.openURL(url)
      }
    }
    
  }
  
  func getAddressFromLatLon(pdblLatitude: String, withLongitude pdblLongitude: String,completion:@escaping(String)->()) {
    var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
    let lat: Double = Double("\(pdblLatitude)")!
    //21.228124
    let lon: Double = Double("\(pdblLongitude)")!
    //72.833770
    let ceo: CLGeocoder = CLGeocoder()
    center.latitude = lat
    center.longitude = lon
    
    let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
    
    ceo.reverseGeocodeLocation(loc, completionHandler:
      {(placemarks, error) in
        if (error != nil)
        {
          debugPrint("reverse geodcode fail: \(error!.localizedDescription)")
        }
        let pm = (placemarks ?? []) as [CLPlacemark]
        
        if pm.count > 0 {
          let pm = placemarks![0]
          debugPrint(/pm.country)
          debugPrint(/pm.locality)
          debugPrint(/pm.subLocality)
          debugPrint(/pm.thoroughfare)
          debugPrint(/pm.postalCode)
          debugPrint(/pm.subThoroughfare)
          var addressString : String = ""
          if pm.subLocality != nil {
            addressString = addressString + pm.subLocality! + ", "
          }
          if pm.thoroughfare != nil {
            addressString = addressString + pm.thoroughfare! + ", "
          }
          if pm.locality != nil {
            addressString = addressString + pm.locality! + ", "
          }
          if pm.country != nil {
            addressString = addressString + pm.country! + ", "
          }
          if pm.postalCode != nil {
            addressString = addressString + pm.postalCode! + " "
          }
         
          completion(addressString)
        }
    })
    
  }
  
}

extension UIApplication {
    
    
    
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)
            
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)
            
        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
 
}

extension UIScrollView {
  func scrollToBottom(animated: Bool) {
    if self.contentSize.height < self.bounds.size.height { return }
    let bottomOffset = CGPoint(x: 0, y: self.contentSize.height - self.bounds.size.height)
    self.setContentOffset(bottomOffset, animated: animated)
  }
}


//MARK:- UIImage Extension

//MARK: - UIImageView extension
extension UIImageView {
  
  func addBlackGradientLayer(frame: CGRect, colors:[UIColor]){
    let gradient = CAGradientLayer()
    gradient.frame = frame
    gradient.colors = colors.map{$0.cgColor}
    self.layer.addSublayer(gradient)
    }
    
    func loadImageFromSignedUrl(cacheKey:String,key:String,completion:((UIImage)->())?){
        
        S3BucketHelper.shared.setupForS3Bucket()
        let getPreSignedURLRequest = AWSS3GetPreSignedURLRequest()
        getPreSignedURLRequest.bucket = AWSConstants.S3BucketName
        getPreSignedURLRequest.key = key
        getPreSignedURLRequest.httpMethod = .GET
        getPreSignedURLRequest.expires = Date(timeIntervalSinceNow: 3600)  // Change the value of the expires time interval as required
        AWSS3PreSignedURLBuilder.default().getPreSignedURL(getPreSignedURLRequest).continueWith { (task:AWSTask<NSURL>) -> Any? in
            
            if let presignedURL = task.result {
                DispatchQueue.main.async {
                    
                    self.loadImage(url: /presignedURL.absoluteString, cacheKey: cacheKey, completion: { (image, error) in
                        
                        if let image = image{
                            completion?(image)
                        }
                    })
              
                    
                }
            }
            return nil
        }
        
    }
    
    func loadImage(nameInitialImage:String? = nil,placeHolder:UIImage? = nil, url: String,indicator:Bool = true,cacheKey:String,completion: @escaping (UIImage?,NSError?)->()) {
        
        self.contentMode = .scaleAspectFill
        
        let modifier = AnyModifier { request in
            var r = request
            r.timeoutInterval = 300
            return r
        }
        
        let fullUrl = AWSConstants.baseUrl + url
        
        if (url != "" && nameInitialImage == nil) || (url != ""){
            if fullUrl.contains("/") {
           
                if let url = URL(string: fullUrl) {
                    
                    if indicator{
                        
                        self.kf.indicatorType = .activity
                        
                    }
                    
                    let resource = ImageResource(downloadURL: url, cacheKey: cacheKey)
                    self.kf.setImage(with: resource)
                    
                    
                    
                    self.kf.setImage(with: resource, placeholder: placeHolder, options: [.requestModifier(modifier)], progressBlock: nil) { (image, error, cache, url) in
                        
                        completion(image,error)
                        
                    }
                    
                }
            }
            
        }else if nameInitialImage != nil && !(/nameInitialImage?.isEmpty){
            
            
            self.setImageForName(/nameInitialImage, gradientColors: (top:UIColor.clear,bottom:UIColor.clear), circular: true, textAttributes: [NSAttributedString.Key.foregroundColor: UIColor.BlueColor!,NSAttributedString.Key.font: ENUM_APP_FONT.xbold.size(24.0)])
            completion(self.image,NSError(domain: "", code: 200, userInfo: nil))

            
        }
    }
    
    
}

protocol Localizable {
    var localized: String { get }
}

protocol XIBLocalizable {
    var xibLocKey: String? { get set }
}

//MARK: - String extension
extension String:Localizable {

    
    func share(from fromVC: UIViewController, title: String?, desc: String?, imgurl: URL? , image : UIImage?) {
        
        fromVC.startAnimateLoader(message: "Loading..".localized)
        
        guard let link = URL(string: self) else {
            fromVC.stopAnimateLoader()
            return
            
        }
        
        let webPath = "https://knowmoto.com"
        let dynamicLinksDomain = APIBasePath.firebaseDynamicBasePath
        
        let fallbackUrl = link.absoluteString.replacingOccurrences(of: APIBasePath.firebaseDynamicBasePath, with: webPath)
        
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomain)
        
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.bridge-below.knowmoto")
        linkBuilder?.iOSParameters?.fallbackURL = URL.init(string: fallbackUrl)
        linkBuilder?.iOSParameters?.appStoreID = "1475907322"
        linkBuilder?.iOSParameters?.minimumAppVersion = "1.0"
        
        linkBuilder?.androidParameters = DynamicLinkAndroidParameters(packageName: "com.example.knowmoto")
        linkBuilder?.androidParameters?.fallbackURL = URL.init(string: fallbackUrl)
        
        linkBuilder?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        linkBuilder?.socialMetaTagParameters?.title = title
        linkBuilder?.socialMetaTagParameters?.descriptionText = desc
        linkBuilder?.socialMetaTagParameters?.imageURL = imgurl
        linkBuilder?.navigationInfoParameters = DynamicLinkNavigationInfoParameters()
        
        
        linkBuilder?.navigationInfoParameters?.isForcedRedirectEnabled = true
        
        
        guard let longDynamicLink = linkBuilder?.url else {
            fromVC.stopAnimateLoader()
            return
            
        }
        debugPrint(longDynamicLink)
        
        DynamicLinkComponents.shortenURL(longDynamicLink, options: nil) { url, warnings, error in
            
            fromVC.stopAnimateLoader()
            
            guard let shortUrl = url else {
                
                fromVC.alertBoxOk(message: "Something went wrong!",title: "Alert", ok: {
                })
                return
                
            }
            
            
            let str = shortUrl.absoluteString
            
            print("The short URL is: \(shortUrl)")
            let vc = UIActivityViewController(activityItems: [(str)], applicationActivities: [])
            fromVC.present(vc, animated: true, completion: nil)
        }
    }
    
    // EZSE: Checks if string is empty or consists only of whitespace and newline characters
    public var isBlank: Bool {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty
    }
    
    /// EZSE: Trims white space and new line characters
    public mutating func trim() {
        self = self.trimmed()
    }
    
    /// EZSE: Trims white space and new line characters, returns a new string
    public func trimmed() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    static func trim(_ string: String?) -> String {
        return string?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
    }
    
    func toBoolValue() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    
  func getTheSnippet(afterThis:String)-> String{
    if let range = self.range(of: afterThis) {
      let snippet = self.substring(from: range.upperBound).trimmingCharacters(in: .whitespacesAndNewlines)
      return snippet
    }else{
      return ""
    }
  }
  
  var westernArabicNumeralsOnly: String {
    let pattern = UnicodeScalar("0")..."9"
    return String(unicodeScalars
      .flatMap { pattern ~= $0 ? Character($0) : nil })
  }
  
  
    func isEmptyText(withErrorMessage:String?,changeBackground:Bool = true) -> Bool{
        
    if self.trimmed().isEmpty{
//      Toast.show(text: withErrorMessage, type: .error,changeBackground: changeBackground)
      return true
    } else {
      return false
    }
  }
  
  func isNull() ->String? {
    if self.trimmed().isEmpty{
      return nil
    }
    return self
  }
  
  public func separate(withChar char : String) -> [String]{
    var word : String = ""
    var words : [String] = [String]()
    for chararacter in self.characters {
      if String(chararacter) == char && word != "" {
        words.append(word)
        word = char
      }else {
        word += String(chararacter)
      }
    }
    words.append(word)
    return words
  }
    
    func getAttributedText(linSpacing:CGFloat = 2) ->NSMutableAttributedString{
        
        let attributedString = NSMutableAttributedString(string: self)
        
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = linSpacing // Whatever line spacing you want in points
        
        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        return attributedString
        
    }
    
}


extension String {
 
    
    var html2AttributedString: NSAttributedString? {
        guard
            let data = data(using: String.Encoding.utf8)
            else { return nil }
        do {
            if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                
                return attributedString
            }

        } catch let error as NSError {
            print(error.localizedDescription)
            return  nil
        }
        
        return nil
    }
    
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
    
    func addZeroForTime()->String{
       let newString = self.count == 1 ? "0\(/self)" : self
        
        return newString
    }
 
    func slice(from: String, to: String) -> String? {
        
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                 substring(with: substringFrom..<substringTo)
            }
        }
    }
    
    func stringToDate(dateFormat:String) ->Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: "en_US")
        let date = dateFormatter.date(from: self)
        return date
    }
    
    func setAttributedTextColorOf(stringToChange:String?,color:UIColor?,font:UIFont?)-> NSAttributedString {
        
        let range = (self as NSString).range(of: stringToChange ?? "")
        
        let attributedString = NSMutableAttributedString.init(string: self)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color ?? UIColor.white , range: range)
        attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        
        return attributedString
        
    }
    
    func widthOfString(font:UIFont) -> CGFloat {
        
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
    
    func lastIndexOf(s: String) -> Int? {
        
        if let r = self.range(of: s, options: String.CompareOptions.backwards, range: nil, locale: nil) {
            return self.distance(from: self.startIndex, to: r.lowerBound)
        }
        return nil
    }

    public func toInt() -> Int? {
        if let num = NumberFormatter().number(from: self) {
            return num.intValue
        } else {
            return nil
        }
    }
    
    /// EZSE: Converts String to Double
    public func toDouble() -> Double? {
        if let num = NumberFormatter().number(from: self) {
            return num.doubleValue
        } else {
            return nil
        }
    }
    
    /// EZSE: Converts String to Float
    public func toFloat() -> Float? {
        if let num = NumberFormatter().number(from: self) {
            return num.floatValue
        } else {
            return nil
        }
    }
    
    /// EZSE: Converts String to Bool
    public func toBool() -> Bool? {
        let trimmedString = trimmed().lowercased()
        if trimmedString == "true" || trimmedString == "false" {
            return (trimmedString as NSString).boolValue
        }
        return nil
    }
    
    /// EZSE: Character count
    public var length: Int {
        return self.characters.count
    }
}

extension Double {
    /// EZSE: Converts Double to String
    public var toString: String { return String(self) }
    
    /// EZSE: Converts Double to Int
    public var toInt: Int { return Int(self) }
    
    #if os(iOS) || os(tvOS)
    
    /// EZSE: Converts Double to CGFloat
    public var toCGFloat: CGFloat { return CGFloat(self) }
    
    #endif
}

extension Int {
    /// EZSE: Checks if the integer is even.
    public var isEven: Bool { return (self % 2 == 0) }
    
    /// EZSE: Checks if the integer is odd.
    public var isOdd: Bool { return (self % 2 != 0) }
    
    /// EZSE: Checks if the integer is positive.
    public var isPositive: Bool { return (self > 0) }
    
    /// EZSE: Checks if the integer is negative.
    public var isNegative: Bool { return (self < 0) }
    
    /// EZSE: Converts integer value to Double.
    public var toDouble: Double { return Double(self) }
    
    /// EZSE: Converts integer value to Float.
    public var toFloat: Float { return Float(self) }
    
    /// EZSE: Converts integer value to CGFloat.
    public var toCGFloat: CGFloat { return CGFloat(self) }
    
    /// EZSE: Converts integer value to String.
    public var toString: String { return String(self) }
    
    /// EZSE: Converts integer value to UInt.
    public var toUInt: UInt { return UInt(self) }
    
    /// EZSE: Converts integer value to Int32.
    public var toInt32: Int32 { return Int32(self) }
    
    /// EZSE: Converts integer value to a 0..<Int range. Useful in for loops.
    public var range: CountableRange<Int> { return 0..<self }
    
    /// EZSE: Returns number of digits in the integer.
    public var digits: Int {
        if self == 0 {
            return 1
        } else if Int(fabs(Double(self))) <= LONG_MAX {
            return Int(log10(fabs(Double(self)))) + 1
        } else {
            return -1; //out of bound
        }
    }
    
    /// EZSE: The digits of an integer represented in an array(from most significant to least).
    /// This method ignores leading zeros and sign
    public var digitArray: [Int] {
        var digits = [Int]()
        for char in self.toString.characters {
            if let digit = Int(String(char)) {
                digits.append(digit)
            }
        }
        return digits
    }
    
    /// EZSE: Returns a random integer number in the range min...max, inclusive.
    public static func random(within: Range<Int>) -> Int {
        let delta = within.upperBound - within.lowerBound
        return within.lowerBound + Int(arc4random_uniform(UInt32(delta)))
    }
}



extension UIButton{

  func loadingIndicator(_ show: Bool,view:UIView) {
    let tag = 808404
    let text = self.titleLabel?.text
    if show {
      
      self.setTitle("", for: .normal)
      view.isUserInteractionEnabled = false
      self.isEnabled = false
      let indicator = UIActivityIndicatorView()
      let buttonHeight = self.bounds.size.height
      let buttonWidth = self.bounds.size.width
      indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
      indicator.tag = tag
      self.addSubview(indicator)
      indicator.startAnimating()
    } else {
      
      self.setTitle(text, for: .normal)
      view.isUserInteractionEnabled = true
      self.isEnabled = true
      if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
        indicator.stopAnimating()
        indicator.removeFromSuperview()
      }
    }
  }
  
  
  func bounce(){
    self.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    UIView.animate(withDuration: 0.2,
                   delay: 0,
                   options: .allowUserInteraction,
                   animations: { [weak self] in
                    self?.transform = .identity
      },
                   completion: nil)
  }
  
  func transformContent(){
    self.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    self.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    self.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
  }
  
  func setInsetsWithImage(){
    self.imageEdgeInsets = UIEdgeInsets(top: 0, left: self.frame.size.width - 24, bottom: 0, right: 0)
    self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: self.frame.size.width/2 + 16)
  }
  
  func addGradient(topColor:UIColor,bottomColor:UIColor,statPoint:CGPoint,endPoint:CGPoint){
    let gradient:CAGradientLayer = CAGradientLayer()
    let colorTop = topColor
    let colorBottom = bottomColor
    
    gradient.colors = [colorTop, colorBottom]
    gradient.startPoint = statPoint
    gradient.endPoint = endPoint
    gradient.frame = self.bounds
    gradient.cornerRadius = 5
    self.layer.insertSublayer(gradient, at: 0)
  }
}




extension UIPageViewController {
  
  func goToCenterVC(viewController:UIViewController?){
    
    guard let seconVC = viewController else { return }
    setViewControllers([seconVC], direction: .forward, animated: false, completion: nil)
    
  }
}

extension UITapGestureRecognizer {
  
  func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
    // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
    let layoutManager = NSLayoutManager()
    let textContainer = NSTextContainer(size: CGSize.zero)
    let textStorage = NSTextStorage(attributedString: label.attributedText!)
    
    // Configure layoutManager and textStorage
    layoutManager.addTextContainer(textContainer)
    textStorage.addLayoutManager(layoutManager)
    
    // Configure textContainer
    textContainer.lineFragmentPadding = 0.0
    textContainer.lineBreakMode = label.lineBreakMode
    textContainer.maximumNumberOfLines = label.numberOfLines
    let labelSize = label.bounds.size
    textContainer.size = labelSize
    
    // Find the tapped character location and compare it to the specified range
    let locationOfTouchInLabel = self.location(in: label)
    let textBoundingBox = layoutManager.usedRect(for: textContainer)
    let textContainerOffset = CGPoint(x:(labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,y:
      (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
    let locationOfTouchInTextContainer = CGPoint(x:locationOfTouchInLabel.x - textContainerOffset.x,y:
      locationOfTouchInLabel.y - textContainerOffset.y);
    let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
    
    return NSLocationInRange(indexOfCharacter, targetRange)
  }
  
}

extension NSLayoutConstraint {
  func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
    return NSLayoutConstraint(item: self.firstItem, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
  }
}

extension UITableView{
  
  func registerNibTableCell(nibName:String){
    let nib = UINib(nibName: nibName, bundle: nil)
    self.register(nib, forCellReuseIdentifier: nibName)
  }
  
}

extension UICollectionView{
  
  func getVisibleIndexOnScroll()-> IndexPath?{
    
    var visibleRect = CGRect()
    visibleRect.origin = self.contentOffset
    visibleRect.size = self.bounds.size
    let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
    let indexPath = self.indexPathForItem(at: visiblePoint)
    return indexPath
  }
    
  func registerNibCollectionCell(nibName:String){
    let nib = UINib(nibName: nibName, bundle: nil)
    self.register(nib, forCellWithReuseIdentifier: nibName)
  }
  
  func deselectAllItems(animated: Bool = false) {
    for indexPath in self.indexPathsForSelectedItems ?? [] {
      self.deselectItem(at: indexPath, animated: animated)
    }
  }
  
}


extension NSMutableAttributedString {
  
  //    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
  //      let attrs: [NSAttributedStringKey: Any] = [(NSFontAttributeName as NSString) as NSAttributedStringKey: UIFont(name:R.font.sfuiDisplayBold.fontName, size: 13)!]
  //        let boldString = NSMutableAttributedString(string:text, attributes: attrs as [String : Any])
  //        append(boldString)
  //
  //        return self
  //    }
  //
  //    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
  //      let attrs: [NSAttributedStringKey: Any] = [(NSFontAttributeName as NSString) as NSAttributedStringKey: UIFont(name:R.font.sfuiDisplayRegular.fontName, size: 13)!]
  //        let boldString = NSMutableAttributedString(string:text, attributes: attrs as [String : Any])
  //        append(boldString)
  //
  //        return self
  //    }
}

extension URL{
  
  static var documentsDirectory: URL {
    let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    return try! documentsDirectory.asURL()
  }
  
  static func urlInDocumentsDirectory(with filename: String) -> URL {
    return documentsDirectory.appendingPathComponent(filename)
  }
  
  
  func getMediaDuration() -> Float64{
    
    let asset : AVURLAsset = AVURLAsset.init(url: self) as AVURLAsset
    let duration : CMTime = asset.duration
    return CMTimeGetSeconds(duration)
    
  }
  
  func generateThumbnail() -> UIImage? {
    do {
      let asset = AVURLAsset(url: self)
      let imageGenerator = AVAssetImageGenerator(asset: asset)
      imageGenerator.appliesPreferredTrackTransform = true
        let cgImage = try imageGenerator.copyCGImage(at: CMTime.zero, actualTime: nil)
      
      return UIImage(cgImage: cgImage)
    } catch {
      debugPrint(error.localizedDescription)
      
      return nil
    }
  }
}

extension Double {
    
    func string(maximumFractionDigits: Int = 2) -> String {
        let s = String(format: "%.\(maximumFractionDigits)f", self)
        for i in stride(from: 0, to: -maximumFractionDigits, by: -1) {
            if s[s.index(s.endIndex, offsetBy: i - 1)] != "0" {
                return String(s[..<s.index(s.endIndex, offsetBy: i)])
            }
        }
        return String(s[..<s.index(s.endIndex, offsetBy: -maximumFractionDigits - 1)])
    }
    
    
  var cleanValue: String {
    return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
  }
}

extension Array {
  mutating func remove(at indexes: [Int]) {
    var lastIndex: Int? = nil
    for index in indexes.sorted(by: >) {
      guard lastIndex != index else {
        continue
      }
      remove(at: index)
      lastIndex = index
    }
  }
}

extension Array where Element: Equatable {
  
  @discardableResult mutating func remove(object: Element) -> Bool {
    if let index = index(of: object) {
      self.remove(at: index)
      return true
    }
    return false
  }
  
  @discardableResult mutating func remove(where predicate: (Array.Iterator.Element) -> Bool) -> Bool {
    if let index = self.index(where: { (element) -> Bool in
      return predicate(element)
    }) {
      self.remove(at: index)
      return true
    }
    return false
  }
  
}

extension UIView
{
    ///Corner Radius
    @IBInspectable var cRadius:CGFloat{
        get{
            return layer.cornerRadius
        }
        set{
            layer.cornerRadius = newValue
        }
    }
    
    ///Border Width
    @IBInspectable var bWidth:CGFloat {
        get{
            return layer.borderWidth
        }
        set{
            layer.borderWidth = newValue
            layer.masksToBounds = newValue > 0
            
        }
    }
    
    ///Border Color
    @IBInspectable var bColor:UIColor{
        get{
            return UIColor.clear
        }
        set{
            layer.borderColor = newValue.cgColor
        }
    }
    
    ///Shadow Opacity
    @IBInspectable var sOpacity:Float{
        get{
            return layer.shadowOpacity
        }
        set{
            layer.shadowOpacity = newValue
        }
    }
    
    ///Shadow Radius
    @IBInspectable var sRadius:CGFloat{
        get{
            return layer.cornerRadius
        }
        set{
            layer.shadowRadius = newValue
        }
    }
    
    ///Shadow OffSet
    @IBInspectable var sOffSet:CGSize{
        get{
            return layer.shadowOffset
        }
        set{
            layer.shadowOffset = newValue
        }
    }
    
    ///Shadow Color
    @IBInspectable var sColor:UIColor{
        get{
            return UIColor.clear
        }
        set{
            layer.shadowColor = newValue.cgColor
        }
    }
    
    
    
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
    
  
    /// EZSwiftExtensions
    public func addTapGesture(tapNumber: Int = 1, target: AnyObject, action: Selector) {
        let tap = UITapGestureRecognizer(target: target, action: action)
        tap.numberOfTapsRequired = tapNumber
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
    
//    /// EZSwiftExtensions - Make sure you use  "[weak self] (gesture) in" if you are using the keyword self inside the closure or there might be a memory leak
//    public func addTapGesture(tapNumber: Int = 1, action: ((UITapGestureRecognizer) -> Void)?) {
//        let tap = BlockTap(tapCount: tapNumber, fingerCount: 1, action: action)
//        addGestureRecognizer(tap)
//        isUserInteractionEnabled = true
//    }
    
    func addDottedBorder(){
        
        let layer = UIView(frame: self.bounds)
        layer.layer.cornerRadius = 8
        layer.layer.borderWidth = 1.5
        layer.layer.borderColor = UIColor(red:0.13, green:0.85, blue:0.83, alpha:1).cgColor
        layer.layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.layer.shadowColor = UIColor(red:0.21, green:0.25, blue:0.29, alpha:0.55).cgColor
        layer.layer.shadowOpacity = 1
        layer.layer.shadowRadius = 3
        self.addSubview(layer)
    }
    

    func addDottedBorder(cornerRadius:CGFloat = 8,color:UIColor = UIColor.white){
            
            let cornerRadius: CGFloat = cornerRadius
            let borderWidth: CGFloat = 1.5
            let dashPattern1: Int = 4
            let dashPattern2: Int = 4
            
            
            //drawing
            let frame: CGRect? = self.bounds
            
            var _shapeLayer = CAShapeLayer()
            
            //creating a path
            let path = CGMutablePath()
            
            //drawing a border around a view
            path.move(to: CGPoint(x: 0, y: (frame?.size.height ?? 0.0) - cornerRadius), transform: .identity)
            path.addLine(to: CGPoint(x: 0, y: cornerRadius), transform: .identity)
            path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .pi, endAngle: CGFloat(-M_PI_2), clockwise: false, transform: .identity)
            path.addLine(to: CGPoint(x: (frame?.size.width ?? 0.0) - cornerRadius, y: 0), transform: .identity)
            path.addArc(center: CGPoint(x: (frame?.size.width ?? 0.0) - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: CGFloat(-M_PI_2), endAngle: 0, clockwise: false, transform: .identity)
            path.addLine(to: CGPoint(x: frame?.size.width ?? 0.0, y: (frame?.size.height ?? 0.0) - cornerRadius), transform: .identity)
            path.addArc(center: CGPoint(x: (frame?.size.width ?? 0.0) - cornerRadius, y: (frame?.size.height ?? 0.0) - cornerRadius), radius: cornerRadius, startAngle: 0, endAngle: CGFloat(M_PI_2), clockwise: false, transform: .identity)
            path.addLine(to: CGPoint(x: cornerRadius, y: frame?.size.height ?? 0.0), transform: .identity)
            path.addArc(center: CGPoint(x: cornerRadius, y: (frame?.size.height ?? 0.0) - cornerRadius), radius: cornerRadius, startAngle: CGFloat(M_PI_2), endAngle: .pi, clockwise: false, transform: .identity)
            
            //path is set as the _shapeLayer object's path
            _shapeLayer.path = path
            
            _shapeLayer.backgroundColor = UIColor.clear.cgColor
            _shapeLayer.frame = frame ?? CGRect.zero
            _shapeLayer.masksToBounds = false
            _shapeLayer.setValue(0, forKey: "isCircle")
            _shapeLayer.fillColor = UIColor.clear.cgColor
            _shapeLayer.strokeColor = color.cgColor
            _shapeLayer.lineWidth = 1
            _shapeLayer.lineDashPattern = [Int32(dashPattern1), Int32(dashPattern2)] as [NSNumber]
            //        _shapeLayer.lineCap = kCALineCapRound
            
            //_shapeLayer is added as a sublayer of the view, the border is visible
            self.layer.addSublayer(_shapeLayer)
            self.layer.cornerRadius = cornerRadius
            
        }
        

}

extension UIDevice {
    static var isIphoneX: Bool {
        var modelIdentifier = ""
        if isSimulator {
            modelIdentifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
        } else {
            var size = 0
            sysctlbyname("hw.machine", nil, &size, nil, 0)
            var machine = [CChar](repeating: 0, count: size)
            sysctlbyname("hw.machine", &machine, &size, nil, 0)
            modelIdentifier = String(cString: machine)
        }
        
        return modelIdentifier == "iPhone10,3" || modelIdentifier == "iPhone10,6"
    }
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}


enum ScreenType: String {
    case iPhones_4_4S = "iPhone 4 or iPhone 4S"
    case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
    case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
    case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
    case iPhones_X_XS = "iPhone X or iPhone XS"
    case iPhone_XR = "iPhone XR"
    case iPhone_XSMax = "iPhone XS Max"
    case unknown
}

extension UIDevice {
   static var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
   static var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    static var isIPhoneXStyle:Bool{
        return screenType == .iPhone_XR || screenType == .iPhone_XSMax || screenType == .iPhones_X_XS
    }
    
   static var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhones_4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1792:
            return .iPhone_XR
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhones_X_XS
        case 2688:
            return .iPhone_XSMax
        default:
            return .unknown
        }
    }
}

func isCameraPermission(actionOkButton: ((_ isOk: Bool) -> Void)? = nil){
    
    let cameraMediaType = AVMediaType.video
    let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
    switch cameraAuthorizationStatus {
    case .authorized: actionOkButton!(true)
    case .restricted: actionOkButton!(false)
    case .denied: actionOkButton!(false)
    case .notDetermined:
        AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted) in
            
            if granted {
                actionOkButton!(true)
            }else {
                actionOkButton!(false)
            }
        })
    }
    
}

func accessToPhotos(actionOkButton: ((_ isOk: Bool) -> Void)? = nil){
    let status = PHPhotoLibrary.authorizationStatus()
    switch status {
    case .authorized: actionOkButton!(true)
    case .restricted: actionOkButton!(false)
    case .denied: actionOkButton!(false)
    case .notDetermined:
        PHPhotoLibrary.requestAuthorization({ (newStatus) in
            if (newStatus == PHAuthorizationStatus.authorized) {
                
                actionOkButton!(true)
            }else {
                actionOkButton!(false)
            }
        })
    }
}

extension UIImage {
    
    func resize(withPercentage percentage: CGFloat) -> UIImage? {
        var newRect = CGRect(origin: .zero, size: CGSize(width: size.width*percentage, height: size.height*percentage))
        UIGraphicsBeginImageContextWithOptions(newRect.size, true, 1)
        self.draw(in: newRect)
        defer {UIGraphicsEndImageContext()}
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func resizeTo(MB: Double) -> UIImage? {
        
  
        
        guard let fileSize = self.pngData()?.count else {return nil}
        let fileSizeInMB = CGFloat(fileSize)/(1024.0*1024.0)//form bytes to MB
        let percentage = 1/fileSizeInMB
        return resize(withPercentage: percentage)
        
    }
}

extension UIImage{
    
    
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.7
        case highest = 1
    }
    
    var png: Data? { return self.pngData() }
    
    func reduceSize(_ quality: JPEGQuality) -> UIImage {
        
        switch quality {
            
        case .low, .lowest:
            
            let height:CGFloat = 200.0
            
            let ratio = self.size.width / self.size.height
            let newWidth = height * ratio
            
            return self.kf.image(withRoundRadius: 0.0, fit: CGSize(width: newWidth, height: height))
            
        case .high:
            
            let size = self.size
            
            let targetSize = CGSize(width: 1600, height: 1600)
            
            if size.width > targetSize.width{
                
                let widthRatio  = targetSize.width  / size.width
                let heightRatio = targetSize.height / size.height
                
                // Figure out what our orientation is, and use that to form the rectangle
                var newSize: CGSize
                
                if(widthRatio > heightRatio) {
                    
                    newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
                    
                } else {
                    
                    newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
                    
                }
                
               return self.kf.image(withRoundRadius: 0.0, fit: newSize)
                
            }else{
                
                return self
                
            }
            
            
            
        default :
            return self.kf.image(withRoundRadius: 0.0, fit: CGSize(width: 400.0, height: 400.0))
        }
    }
    
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return self.jpegData(compressionQuality: quality.rawValue)
    }
    
    
    
    func imageRotatedByDegrees( degrees: CGFloat) -> UIImage {
        

        // Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat.pi / 180)
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        //Rotate the image context
        bitmap.rotate(by: (degrees * CGFloat.pi / 180))
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        bitmap.draw(self.cgImage!, in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        UIApplication.shared.endIgnoringInteractionEvents()
        return newImage
    }
    
    
    
    public func fixedOrientation() -> UIImage {
        if imageOrientation == UIImage.Orientation.up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case UIImage.Orientation.down, UIImage.Orientation.downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi/2)
            break
        case UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -CGFloat.pi/2)
            break
        case UIImage.Orientation.up, UIImage.Orientation.upMirrored:
            break
        }
        
        switch imageOrientation {
        case UIImage.Orientation.upMirrored, UIImage.Orientation.downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImage.Orientation.leftMirrored, UIImage.Orientation.rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImage.Orientation.up, UIImage.Orientation.down, UIImage.Orientation.left, UIImage.Orientation.right:
            break
        }
        
        let ctx: CGContext = CGContext(data: nil,
                                       width: Int(size.width),
                                       height: Int(size.height),
                                       bitsPerComponent: self.cgImage!.bitsPerComponent,
                                       bytesPerRow: 0,
                                       space: self.cgImage!.colorSpace!,
                                       bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored, UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        let cgImage: CGImage = ctx.makeImage()!
        
        return UIImage(cgImage: cgImage)
    }
    
    
    
}

extension UINavigationController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
    
    open override var childForStatusBarStyle: UIViewController?{
        return topViewController
    }
    
    open override var childForStatusBarHidden: UIViewController?{
        return topViewController
    }
    
}


fileprivate extension UIScrollView {
    
    func screenshot() -> UIImage? {
        
        let savedContentOffset = contentOffset
        let savedFrame = frame
        
        UIGraphicsBeginImageContext(contentSize)
        contentOffset = .zero
        frame = CGRect(x: 0, y: 0, width: contentSize.width, height: contentSize.height)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        contentOffset = savedContentOffset
        frame = savedFrame
        
        return image
    }
    
}


extension Data {
    
    func hexString() -> String {
        let string = self.map{ String($0, radix:16) }.joined()
        return string
    }
    
}


extension Int
{
    
    static func parse(from string: String) -> Int? {
        return Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
    }
    
}

extension UITextField{
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!,NSAttributedString.Key.font:ENUM_APP_FONT.book.size(13)])
        }
    }
    
    @IBInspectable var placeHolderFont: UIFont? {
        get {
            return self.placeHolderFont
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.font:ENUM_APP_FONT.light.size(13)])
        }
    }
    
}


//extension UITextField{
//
//    override open func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if action == #selector(UIResponderStandardEditActions.paste(_:)) || action ==  #selector(UIResponderStandardEditActions.copy(_:)) || action ==  #selector(UIResponderStandardEditActions.cut(_:)) || action ==  #selector(UIResponderStandardEditActions.select(_:)) || action ==  #selector(UIResponderStandardEditActions.selectAll(_:)) {
//            return false
//        }
//        return super.canPerformAction(action, withSender: sender)
//    }
//
//}
public extension UIAlertController {
    func showW() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}

extension Bundle {
    
    static func loadView<T>(fromNib name: String, withType type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }
        
        fatalError("Could not load view with type " + String(describing: type))
    }
}

extension UINavigationController {
    func pushViewController(viewController: UIViewController, animated:
        Bool, completion: @escaping () -> ()) {
        
        pushViewController(viewController, animated: animated)
        
        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
    
    func popViewController(viewController: UIViewController? = nil,
                           animated: Bool, completion: @escaping () -> ()) {
        if let viewController = viewController {
            popToViewController(viewController, animated: animated)
        } else {
            popViewController(animated: animated)
        }
        
        if let coordinator = transitionCoordinator, animated {
            coordinator.animate(alongsideTransition: nil) { _ in
                completion()
            }
        } else {
            completion()
        }
    }
}
