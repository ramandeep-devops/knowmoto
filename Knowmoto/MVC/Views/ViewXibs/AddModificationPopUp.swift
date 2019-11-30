//
//  AddModificationPopUp.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/17/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
protocol AddModificationPopUpDelegate{
    
    func didDoneWithModificationModel(model:Any?)
    func didSelectForBrand(model:Any?)
    
}



class AddModificationPopUp:CustomPopUp{
    
    @IBOutlet weak var textFieldPart: KnowMotoTextField!
    @IBOutlet weak var textFieldPartNo: KnowMotoTextField!
    @IBOutlet weak var textFieldCategory: KnowMotoTextField!
    @IBOutlet weak var textFieldBrand: KnowMotoTextField!
    
    //Category pickerView
    
    var dataSourcePickerViewCategory:PickerViewCustomDataSource?
    let pickerViewCategory = UIPickerView()
    var arrayCategory = [FeaturesListModel](){
        didSet{
            self.dataSourcePickerViewCategory?.pickerData = arrayCategory
            self.pickerViewCategory.reloadAllComponents()
        }
    }

    var model:ModificationType? = ModificationType()
    var delegate:AddModificationPopUpDelegate?
    
    lazy var popup:UIView = {
        
        return UINib(nibName: "AddModificationPopUp", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.popUpView = popup
        self.popUpView.frame = frame
        
        super.initialSetup()

        
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func didSelectBrand(_ sender: Any) {
        
        self.endEditing(true)
        
        setModelData()
        
        delegate?.didSelectForBrand(model: model)
        
        self.dismissPopUp(animation:false)
        
    }
    
    
    @IBAction func didSelectCategory(_ sender: UIButton) {
        
        if arrayCategory.isEmpty{
            
            getCategoryList()
            
        }else{
            
            textFieldCategory.becomeFirstResponder()
            
        }
        
    }
    
    
    @IBAction func didTapDone(_ sender: UIButton) {
        
        self.endEditing(true)
        
        setModelData() // setting model data
        
        let valid = Validations.sharedInstance.validateAddModification(brand: /model?.brandData?.name, category: /model?.modificationData?.category, partNo: /model?.partNumber, part: /model?.part)
        
        switch valid {
            
        case .success:
        
            self.delegate?.didDoneWithModificationModel(model: model)
            self.dismissPopUp()
            
        case .failure(let error):
            
            Toast.show(text: error, type: .error)
            
        }
  
        
    }
    
    func setModelData(){
        
       model?.modificationId = model?.modificationData?.id
       model?.brandId = model?.brandData?.id
       model?.customBrandName = model?.brandData?.id == nil ? model?.brandData?.name : nil
       model?.part = textFieldPart.text
       model?.partNumber = textFieldPartNo.text
        
    }
    
    
}

//MARK:- Configuring picker views

extension AddModificationPopUp{

    func configureCategoryPickerView(textField:UITextField){

        textField.inputView = pickerViewCategory
        textField.tintColor = UIColor.clear
        pickerViewCategory.backgroundColor = UIColor.backGroundHeaderColor!

        dataSourcePickerViewCategory = PickerViewCustomDataSource(textField: textField, picker: pickerViewCategory, items: arrayCategory, columns: 1) { [weak self] (selectedRow, item) in

            debugPrint(item)
            self?.endEditing(true)
            self?.model?.modificationData = item as? FeaturesListModel
            textField.text = /(item as? FeaturesListModel)?.category

        }

        dataSourcePickerViewCategory?.titleForRowAt = { [weak self] (row,component)-> String in

            return /self?.arrayCategory[row].category

        }

    }

}

//MARK:- API
extension AddModificationPopUp{
    
    func getCategoryList(){
        
        EP_Car.get_modification_category(search: nil, limit: 1000, skip: 0).request(success: { [weak self] (response) in
            
            let _response = (response as? [FeaturesListModel]) ?? []
            self?.arrayCategory = _response
            self?.configureCategoryPickerView(textField: (self?.textFieldCategory)!)
            self?.textFieldCategory.becomeFirstResponder()
            
        })
        
    }
    
}
