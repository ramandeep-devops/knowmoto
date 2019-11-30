
//  BeaconDetailVC.swift
//  Knowmoto

//  Created by cbl16 on 12/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.


import UIKit

class BeaconLinkDetailVC: UIViewController {

    //MARK:- OUTLETS
    
    @IBOutlet weak var viewLinked: UIView!
    @IBOutlet weak var viewUnlinked: UIView!
    @IBOutlet weak var lblBeaconId: UILabel!
    @IBOutlet weak var lblBeaconName: UILabel!
    @IBOutlet weak var imgBeacon: KnowmotoUIImageView!
    @IBOutlet weak var lblCanModel: UILabel!
    
    //MARK:- PROPERTIES
    
    var Linked:Bool?
    
    //MARK:- LIFE CYCLE METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Linked or not
        checklinkedOrNot()
        
    }
    
    //MARK:- EXTRA FUNCTION
    func checklinkedOrNot(){
        // checked for beacin is linked or not
        if Linked == true {
            self.viewUnlinked.isHidden = true
        }else {
            self.viewLinked.isHidden = true
        }
    }
    
    //MARK:- Actions
    
    // unlike action
    @IBAction func didTapUnlike(_ sender: Any) {
    }
    
    // link car action
    @IBAction func didTapLinkCar(_ sender: Any) {
    }
}
