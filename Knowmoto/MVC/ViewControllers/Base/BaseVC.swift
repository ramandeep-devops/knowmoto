//
//  BaseVC.swift
//  Knowmoto
//
//  Created by Apple on 29/07/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import IQKeyboardManagerSwift
import UIKit

var lastSelectedTab:ENUM_HOME_TAB = .home

class BaseVC: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var stackViewPermission: UIStackView!
    
    @IBOutlet weak var btnNext: KnomotButton!
    @IBOutlet weak var searchField: KnowmotoSearchTextField!
    @IBOutlet weak var btnCity: UIButton!
    @IBOutlet weak var btnUserName: UIButton!
    @IBOutlet weak var imageViewUser: KnowmotoUIImageView!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var bottomConstraintSubmitButton: NSLayoutConstraint!
    @IBOutlet weak var headerView: KnowmotoHeaderView!
    
    //MARK:- Properties
    
    var dataSourcePickerViewYear:PickerViewCustomDataSource?
    let pickerViewYear = UIPickerView()
    var arrayYears = [Int]()
    
    var lastBottomConstraint:CGFloat = 0.0
    var keyboardDoneButtonText:String = "Done"{
        didSet{
            IQKeyboardManager.shared.toolbarDoneBarButtonItemText = keyboardDoneButtonText
        }
    }
    var userData = UserDefaultsManager.shared.loggedInUser
    var isScreenOpeningFirstTime:Bool = true
    var isFirstTime:Bool = true
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
    }
    
    //MARK: -  View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = keyboardDoneButtonText
        setCommonViewControllerProperties()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        userData = UserDefaultsManager.shared.loggedInUser
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if isFirstTime{
            isFirstTime = false
        }
    }
    
    func setCommonViewControllerProperties(){
        
        self.view.backgroundColor = UIColor.BackgroundRustColor
    }
    
    
    //MARK:- Button actions
    @IBAction func didTapEnablePermission(_ sender: Any) {
        
        self.openSettings()
    }
    
    @IBAction func didTapDismiss(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func setLoggedInUser(){
        
        userData = UserDefaultsManager.shared.loggedInUser
        
        if !UserDefaultsManager.isGuestUser{
            
            btnUserName?.setTitle("Hi, " + /userData?.name, for: .normal)

            imageViewUser?.loadImage(nameInitial: nil, key: /userData?.image?.thumb, isLoadWithSignedUrl: true, cacheKey: /userData?.image?.thumb, placeholder: #imageLiteral(resourceName: "userplaceholder_small"))
            checkInterestedBrands() // checking interest brands are selected or not
            
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//
       
        self.btnCity.setTitle(UserDefaultsManager.shared.location?.selectedLocation?.name ?? "Select Location".localized, for: .normal)

//        }
        
        
    }
    
    
    //MARK:-Keyboard handling
    func addKeyboardObservers(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyBoardWillShow(notification: NSNotification) {
        
        //handle appearing of keyboard here
        if let keyboardFrame: NSValue = notification.userInfo! [UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let keyboardRectangle = keyboardFrame.cgRectValue
            
            let keyboardHeight = keyboardRectangle.height
            
            lastBottomConstraint = bottomConstraintSubmitButton.constant
            //            bottomConstraintSubmitButton?.constant = 16 + keyboardHeight
            
            UIView.animate(withDuration: 0.2) {
                
                self.view.layoutIfNeeded()
                
            }
        }
        
        
    }
    
    
    @objc func keyBoardWillHide(notification: NSNotification) {
        
        //handle dismiss of keyboard here
        //bottomConstraintSubmitButton?.constant = lastBottomConstraint
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func reInstantiateWindow(){
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.reInstantiateWindow()
    }
    
    
    func handleGuestUser(){
        
        if UserDefaultsManager.isGuestUser{
            
            if UserDefaultsManager.shared.isWalkthroughDone{
                
                let vc = ENUM_STORYBOARD<PhoneInputVC>.registrationLogin.instantiateVC()
                self.navigationController?.pushViewController(vc, animated: true)
                
            }else{
                
                let vc = ENUM_STORYBOARD<WalkThroughVC>.registrationLogin.instantiateVC()
                self.navigationController?.pushViewController(vc, animated: true)
                
            }
        }
    }
    
    func checkInterestedBrands(){
        
        if userData?.interestedMakes == nil || (userData?.interestedMakes?.isEmpty ?? true){
            
            redirectToSelectInterest(isFromSignupProcess: true)
            
        }
        
    }
    
    func redirectToSelectInterest(isFromSignupProcess:Bool){
        
        
        let vc = ENUM_STORYBOARD<SelectMakeOrBrandOrModelVC>.car.instantiateVC()
        vc.vcType = ENUM_CAR_SELECTION_TYPE.make
        vc.isFromSignupProcess = isFromSignupProcess
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
  
    
}

extension BaseVC:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTextField = self.view.viewWithTag(textField.tag+1);
        
        if (nextTextField is UITextField ){
            nextTextField?.becomeFirstResponder()
        } else  {
            textField.resignFirstResponder()
        }
        return true
    }
}

//MARK:- API
extension BaseVC{
    
    func apiEndLiveCar(liveCar:CarListDataModel?,completion:(()->())? = nil){
        
        if !UserDefaultsManager.shared.isLive{
            return
        }
        
//        let liveCar = UserDefaultsManager.shared.liveCar
        
        EP_Car.add_edit_car(id: liveCar?.id, name: nil, makeId: nil, year: nil, country: nil, nickName: nil, beaconId: nil, modificationType: nil, image: nil, featureId: nil, sponsorId: nil, sponsors: nil, location: nil, features: nil, isLiveExpiry: 0).request(loaderMessage:"Ending session...".localized,success:{ [weak self] (response) in

//            liveCarTimers[/liveCar?.id]?.invalidate()
            
//            liveTimer?.invalidate()

            var liveVehicles = UserDefaultsManager.shared.liveCar
            liveVehicles?.liveCars?.removeAll(where: {$0.id == /liveCar?.id})
            
            UserDefaultsManager.shared.liveCar = liveVehicles //end live

            if /self?.topMostVC?.isKind(of: MBMapVC.self){
                
                if /liveVehicles?.liveCars?.isEmpty{
                    
                    (self?.topMostVC as? MBMapVC)?.reloadMapOnCarEndSession()
                    
                    self?.topMostVC?.dismiss(animated: true, completion: {
                        
                        self?.alertOfEndLiveCar(carData: liveCar)
                        
                    })
                    
                }else{
                    
                    (self?.topMostVC as? MBMapVC)?.reloadMapOnCarEndSession()
                    
                    self?.alertOfEndLiveCar(carData: liveCar)
                    
                }
                
                completion?()
                
            }else if let vc = self?.topMostVC as? HomeSegmentedTabVC{
                
                self?.alertOfEndLiveCar(carData: liveCar)
                vc.setGoLiveButtonEnable(enable: true)
                
            }else{
                
                self?.alertOfEndLiveCar(carData: liveCar)
                
            }

        })
        
    }
    
    func alertOfEndLiveCar(carData:CarListDataModel?){
        
        self.alertBoxOk(message: "Your live session of \(/carData?.displayAppName) has ended", title: "Live Session".localized, ok: {})
        
    }
    
}
