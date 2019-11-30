//
//  CarBuffesViewController.swift
//  Knowmoto

//  Created by cbl16 on 02/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.

//Code by Amandeep aman.code-brew@gmai.com

import UIKit

import UIKit
import AWSS3

struct WalkThroughScreenModel{
    
    var image:UIImage?
    var title:String?
    var subtitle:String?
    
}

class WalkThroughVC: BaseVC {
    //MARK:- OUTLETS
    
    @IBOutlet var arrayIndicatorConstraint: [NSLayoutConstraint]!
    @IBOutlet var collectionTable: UICollectionView!
    @IBOutlet var arrrayIndicatorView: [UIView]!
    @IBOutlet weak var gradientView: UIView!
    
    //MARK:-PROPERTIES
    
    var HeadingCollectionViewDataSource:CollectionViewDataSource?
    
    
    var arrayWalkThroughModel = [
        
        WalkThroughScreenModel(image: UIImage(named: "Walkthrough_1"), title: "Heading One", subtitle: "It has survived not only five centuries, but also the leap into electronic typesetting unchanged."),
        WalkThroughScreenModel(image: UIImage(named: "Walkthrough_2"), title: "Heading Two", subtitle: "It has survived not only five centuries, but also the leap into electronic typesetting unchanged."),
        WalkThroughScreenModel(image: UIImage(named: "Walkthrough_3"), title: "Heading Three", subtitle: "It has survived not only five centuries, but also the leap into electronic typesetting unchanged.")
        
    ]
    var currentIndex:Int = 0
    
    deinit {
        debugPrint("Deintialized",String(describing: self))
    }
    //MARK:- LIFE CYCLE METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        
    }
    
    private func initialSetup(){
        
        headerView.headerView.didTapLeftButton = { [weak self] (sender) in
            
            self?.switchTab(tab: .home)
            self?.navigationController?.popViewController(animated: true)
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            
            self?.setIndicator(selectedIndex: 0)
            self?.setGradientColur()
            self?.configureCollectionView()
        }
    }

    
    //MARK:- Actions
    
    @IBAction func joinKnowMotoAction(_ sender: Any) {
        
        UserDefaultsManager.shared.isWalkthroughDone = true
        let vc = ENUM_STORYBOARD<PhoneInputVC>.registrationLogin.instantiateVC()
        vc.isFromWalkThrough = true
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    //MARK:-Configuring Table View
    func configureCollectionView(){ //Configuring collection View cell
        
        collectionTable.contentInset = UIEdgeInsets(top: UIDevice.isIPhoneXStyle ? -44 : -20, left: 0, bottom: 0, right: 0)
        let identifier = String(describing: WalkthroughCollectionViewCell.self)
        
        HeadingCollectionViewDataSource = CollectionViewDataSource(items: arrayWalkThroughModel, collectionView: collectionTable, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: collectionTable.bounds.height, cellWidth: UIScreen.main.bounds.width, configureCellBlock: { (cell, item, indexPath) in
            
            let _cell = cell as? WalkthroughCollectionViewCell
            _cell?.model = item
            
        }, aRowSelectedListener: nil, willDisplayCell: nil) { [weak self] (scrollView) in
            
            guard let indexPath = self?.collectionTable.getVisibleIndexOnScroll() else {return}
            
            if self?.currentIndex != indexPath.item{
                
                self?.setIndicator(selectedIndex: indexPath.item)
                
            }
            
        }
        
        collectionTable.dataSource = HeadingCollectionViewDataSource
        collectionTable.delegate = HeadingCollectionViewDataSource
        collectionTable.reloadData()
    }
    
    //MARK:- EXTRA FUNCTIONS
    
    
    func setIndicator(selectedIndex:Int){
        
        for (index,_) in self.arrayIndicatorConstraint.enumerated(){
            
            UIView.animate(withDuration: 0.2) { [weak self] in
                
                self?.arrayIndicatorConstraint[index].constant = index == selectedIndex ? 32.0 : 14.0
                self?.arrrayIndicatorView[index].backgroundColor = index == selectedIndex ? UIColor.white : UIColor.lightGray.withAlphaComponent(0.4)
                
            }
            
        }
        
        self.lblSubtitle.alpha = 0.0
        self.lblTitle.alpha = 0.0
        
        
        // *** Set Attributed String to your label ***
        self.lblSubtitle.attributedText = self.arrayWalkThroughModel[selectedIndex].subtitle?.getAttributedText(linSpacing: 4)
        self.lblTitle.text = /self.arrayWalkThroughModel[selectedIndex].title
    
        
        
        UIView.animate(withDuration: 0.5) { [weak self] in
            
            self?.lblSubtitle.alpha = 1.0
            self?.lblTitle.alpha = 1.0
            
        }
        
        self.currentIndex = selectedIndex
        
        self.view.layoutIfNeeded()
        
    }
    
    func setGradientColur() {
        
        let layer = UIView(frame: CGRect(x: 0, y: 0, width: self.gradientView.frame.size.width, height: gradientView.bounds.height))
        let gradient0 = CAGradientLayer()
        gradient0.frame = CGRect(x: 0, y: 0, width: self.gradientView.frame.size.width, height: gradientView.bounds.height)
        gradient0.colors = [    UIColor.clear.cgColor,    UIColor(red:0.21, green:0.25, blue:0.29, alpha:1).cgColor]
        gradient0.locations = [0, 1]
        gradient0.startPoint = CGPoint(x: 0.5, y: 0.62)
        gradient0.endPoint = CGPoint(x: 0.5, y: 0.98)
        layer.layer.addSublayer(gradient0)
        
        let gradient1 = CAGradientLayer()
        gradient1.frame = CGRect(x: 0, y: 0, width: self.gradientView.frame.size.width, height: gradientView.bounds.height)
        gradient1.colors = [    UIColor(red:0.07, green:0.07, blue:0.07, alpha:0.5).cgColor,    UIColor.clear.cgColor]
        gradient1.locations = [0, 1]
        gradient1.startPoint = CGPoint(x: 0.5, y: 0)
        gradient1.endPoint = CGPoint(x: 0.5, y: 0.26)
        layer.layer.addSublayer(gradient1)
        self.gradientView.addSubview(layer)
    }
    
}


