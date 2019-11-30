//
//  AddCarStep1VC.swift
//  Knowmoto
//
//  Created by Apple on 12/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

/*
 View controller used for opening diffent type of screens to open by the vctype passed
 According that calling particular api to get
 
 All defined in parent class
 */

class AddCarStep1SelectMakeVC: SelectMakeOrBrandOrModelVC {
    
    //MARK:- Properties
    
    @IBOutlet weak var btnSearch: UIButton!
    var viewModel:AddEditCarViewModel?
    

    //MARK:- View controller lifecycle
    
    override func viewDidLoad() {
        isFromSignupProcess = false
        super.viewDidLoad()
        
        
        if vcType == .brandOrSponsor{
            
            btnSearch.isUserInteractionEnabled = true
            headerView.isHidden = false
            headerView.headerView.didTapLeftButton = { [weak self] (sender) in
                
                self?.delegate?.didSelectSponsor(model: (self?.selectedData as? [Any])?.first)
                self?.dismiss(animated: true, completion: nil)
                
            }

        }
        
        setCollectionViewRowSelector()
        
    }
    
    //MARK:- button acitons
    
    @IBAction func didTapSearch(_ sender: UIButton) {
        
        if vcType == .brandOrSponsor{
            
            let vc = ENUM_STORYBOARD<AddCarStep6SponsorsVC>.car.instantiateVC()
//            vc.isFromSelectBrand = true
            vc.vcType = .selectBrandForModification
            vc.delegate = delegate
//            vc.blockDidSelectBrand = { [weak self] in
//            
//                topMostVC?.dismiss(animated: true, completion: nil)
//                
//            }
            self.present(vc, animated: true, completion: nil)
            
        }
        
    }
    
    //MARK:- Table view configuration
    
    override func setTableContentInset() {
        
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 48, right: 0)
        
    }
    
    // override row selector from parent vc
    func setCollectionViewRowSelector(){
        
        dataSourceCollections?.aRowSelectedListener = { [weak self] (indexPath,item) in
            
            //setting model with make id
            
            switch self?.vcType ?? .make {
                
            case .make:
                
                self?.actionRowSelectorCollectionView(indexPath: indexPath,selectionType:.single)
                
                self?.setMakeModel(indexPath: indexPath)
                
                //notification for update loading view
                NotificationCenter.default.post(name: .UPDATE_LOADING, object: nil)
                
                self?.pushToStep2()
                
            case .brandOrSponsor:
                
                self?.delegate?.didSelectSponsor(model: item)
                self?.dismiss(animated: true, completion: nil)
                
            case .myCars:
                
                self?.delegate?.didSelectMyCar(model: item)
                self?.dismiss(animated: true, completion: nil)
                
            default:
                break
            }
            
            
            
            debugPrint(indexPath)
            
        }
    }
    
    
    func pushToStep2(){
        
        let vc = ENUM_STORYBOARD<AddCarStep2SelectModelVC>.car.instantiateVC()
        vc.viewModel = self.viewModel
        vc.carData = self.carData
        vc.isFromEditCar = self.isFromEditCar
        vc.isMakeChangedInEditCar = self.isFromEditCar && (/vc.viewModel?.makeId?.id != /self.carData?.make?.first?.id)
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //set modal data
    
    func setMakeModel(indexPath:IndexPath){
        
        viewModel = (UserDefaultsManager.shared.addCarViewModel?.copy() as? AddEditCarViewModel) ?? AddEditCarViewModel()
        
        UserDefaultsManager.shared.addCarViewModel = nil // removing this tempory data
        viewModel?.makeId = arrayCarsOrBrands[indexPath.item] as? BrandOrCarModel
    }
    
}
