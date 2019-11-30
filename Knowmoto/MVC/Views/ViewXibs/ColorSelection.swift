//
//  ColorSelection.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 11/16/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation

protocol ColorSelectionPopUpDelegate:class {
    func didSelectColors(colors:[BrandOrCarModel])
}

class ColorSelectionPopUp:CustomPopUp{
    
    var dataSourceCollections:CollectionViewDataSource? = nil

    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var collectionView:UICollectionView!
    
    lazy var popup:UIView = {
        
        return UINib(nibName: "ColorSelection", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView
    }()
    
    private var arrayColors:[BrandOrCarModel] = []
    weak var delegate:ColorSelectionPopUpDelegate?
    var preselectedColors:[BrandOrCarModel] = []
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.popUpView = popup
        self.popUpView.frame = frame
        
        super.initialSetup()
        
        apiGetColors()
        configureCollectionView()
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    func configureCollectionView(){ //Configuring collection View cell
        
        self.collectionView.contentInset = UIEdgeInsets(top: 8.0, left: 0, bottom: 8.0, right: 0)
        
        flowLayout?.sectionInset = UIEdgeInsets(top: 4.0, left: 16, bottom: 16, right: 16.0)
        flowLayout?.minimumLineSpacing = 16.0
        flowLayout?.minimumInteritemSpacing = 16.0
        
        
        let identifier = String(describing: TagCollectionViewCell.self)
        collectionView.registerNibCollectionCell(nibName: identifier)
        
        let cellHeight:CGFloat = 44.0
        let leftRightTotalPadding:CGFloat = 40.0
        
        let headerIdentifer = String(describing: TextCollectionViewReusableView.self)
        collectionView.register(UINib(nibName: headerIdentifer, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifer)
        
        dataSourceCollections = CollectionViewDataSource.init(items: arrayColors, collectionView: collectionView, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: cellHeight, cellWidth: 56.0, configureCellBlock: { (cell, item, indexPath) in
            
            let _cell = cell as? TagCollectionViewCell
            _cell?.model = item
            
        }, aRowSelectedListener: { [weak self] (indexPath, item) in
            
            if /self?.arrayColors[indexPath.item].isSelected{
                
                self?.unSelectTag(indexPath: indexPath)
                
            }else{
                
                self?.selectTag(indexPath: indexPath)
                
            }
            
            
            }, willDisplayCell: nil, scrollViewDelegate: nil)
        
        //header footer in section
        
        dataSourceCollections?.didSizeForItemAt = { [weak self] (indexPath) ->CGSize in
            
            let cellWidth = ((self?.arrayColors[indexPath.row])?.name?
                .widthOfString(font: ENUM_APP_FONT.bold.size(14)) ?? 0) + leftRightTotalPadding
            
            return CGSize(width: cellWidth, height: cellHeight)
        }
        
        collectionView.dataSource = dataSourceCollections
        collectionView.delegate = dataSourceCollections
        self.collectionView.reloadData()
        
    }
    
    func unSelectTag(indexPath:IndexPath){
        
        //unselect previous selected cell
        
        self.arrayColors[indexPath.item].isSelected = false
        
        let cell = (self.collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell) //accessing direct cell
        
        cell?.model = self.arrayColors[indexPath.item]
        
        self.collectionView.reloadData()

     
    }
    
    func selectTag(indexPath:IndexPath){
        
        //selecting new selected cell
        let model = self.arrayColors[indexPath.item]
        
        model.isSelected = !(/model.isSelected) // set selected
        
        let cell = (self.collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell) //accessing direct cell
        
        cell?.model = model
        
        self.collectionView.reloadData()
    }
    
    
    @IBAction func didTapDone(_ sender: UIButton) {
        
        delegate?.didSelectColors(colors: self.arrayColors.filter({$0.isSelected == true}))
        self.dismissPopUp(animation: true)
        
    }
    

    func apiGetColors(){
        
        EP_Car.colorsList().request(loaderNeeded: false, success: { [unowned self] (response) in
            
            if let colorsList = (response as? [BrandOrCarModel]){
                
                self.arrayColors = colorsList
                
                self.arrayColors.forEach({ (color) in
                    
                    color.isSelected = self.preselectedColors.contains(where: {$0.name == color.name})
                    
                })
                
                self.dataSourceCollections?.items = self.arrayColors
                self.collectionView.reloadData()
                
            }
            
        }) { (error) in
            
            
        }
        
    }
    
}
