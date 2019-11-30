//
//  PickerViewCustomDataSource.swift
//  Grintafy
//
//  Created by Sierra 4 on 20/07/17.
//  Copyright © 2017 com.example. All rights reserved.
//

import Foundation
import UIKit

typealias  TitleForRowAt = (_ row: Int , _ component: Int) -> (String)
typealias  SelectedRowBlock = (_ selectedRow: Int , _ item: Any) -> ()
class PickerViewCustomDataSource: NSObject{
  
  var picker: UIPickerView?
  var pickerData:[Any] = []
  var aSelectedBlock: SelectedRowBlock?
  var columns: Int?
  let toolBar = UIToolbar()
  var titleForRowAt:TitleForRowAt?
  var titleColor:UIColor = UIColor.white
  
  
  init(textField:UITextField? = nil,picker: UIPickerView? , items: [Any], columns: Int? , aSelectedStringBlock: SelectedRowBlock?) {
    
    super.init()
    
    self.picker = picker
    self.pickerData = items
    self.aSelectedBlock = aSelectedStringBlock
    self.picker?.delegate = self
    self.picker?.dataSource = self
    self.columns = columns
    textField?.addDoneOnKeyboardWithTarget(self, action: #selector(self.didSelectRowOnDone))
  }
  
  override init() {
    super.init()
  }
  
  @objc func didSelectRowOnDone(sender:UITextField){
    
    topMostVC?.view.endEditing(true)
    picker?.endEditing(true)
   
    if let block = self.aSelectedBlock{
        let selectedRow = /self.picker?.selectedRow(inComponent: 0)
        if !(/pickerData.isEmpty){
            block(selectedRow , pickerData[selectedRow]  as Any )
        }else{
          topMostVC?.view.endEditing(true)
        }
    }
  }
}

extension PickerViewCustomDataSource:UIPickerViewDelegate , UIPickerViewDataSource{
    
  @available(iOS 2.0, *)
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return columns ?? 0
  }
  
  
  // The number of columns of data
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return columns ?? 0
  }
  
  // The number of rows of data
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    
    return pickerData.count
  }
  
//  // The data to return for the row and component (column) that's being passed in
//  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//
//    if titleForRowAt != nil{
//        return titleForRowAt?(row, component)
//    }
//
//    let safeData = /String(describing: self.pickerData[row])
//    return safeData
//
//  }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        if titleForRowAt != nil{
            
            let attributedString = NSAttributedString(string: /titleForRowAt?(row, component), attributes: [NSAttributedString.Key.foregroundColor : titleColor])
            
            return attributedString
        }
        
        let safeData = /String(describing: self.pickerData[row])
        let attributedString = NSAttributedString(string: safeData, attributes: [NSAttributedString.Key.foregroundColor : titleColor])
        
        return attributedString
        
    }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    
//            if let block = self.aSelectedBlock{
//                block(row , pickerData[row]  as Any )
//            }
  }
  
}

