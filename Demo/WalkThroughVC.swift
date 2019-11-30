//
//  CarBuffesViewController.swift
//  Knowmoto

//  Created by cbl16 on 02/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.

import UIKit

import UIKit
import AWSS3

class CarBuffesViewController: UIViewController {

    //MARK:- OUTLETS
   
    @IBOutlet var arrayIndicatorConstraint: [NSLayoutConstraint]!
    @IBOutlet var collectionTable: UICollectionView!
    @IBOutlet var arrrayIndicatorView: [UIView]!
    @IBOutlet weak var gradientView: UIView!
    
    //MARK:-PROPERTIES
    
    var HeadingCollectionViewDataSource:CollectionViewDataSource?
    var imagesArray = [UIImage(named: "car33"),UIImage(named: "car33"),UIImage(named: "car33")]
    var HeadingArray = ["Heading One","Heading Two","Heading Three"]
    
    
    //MARK:- LIFE CYCLE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        collectionTable.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //self.setGradientBackground(colorTop: .clear, colorBottom: .blue)
        self.setGradientColur(gradientView: self.gradientView)

    }
    
    //MARK:- Actions
    
    @IBAction func joinKnowMotoAction(_ sender: Any) {
    }
        
    //MARK:-Configuring Table View
    func configureCollectionView(){ //Configuring collection View cell
        
        let identifier = String(describing: HeadingCollectionCell.self)
                //UIScreen.main.bounds.width
        HeadingCollectionViewDataSource = CollectionViewDataSource(items: ["","",""], collectionView: collectionTable, cellIdentifier: identifier, headerIdentifier: nil, cellHeight: collectionTable.frame.height, cellWidth: collectionTable.frame.width, configureCellBlock: { (_cell, item, indexPath) in
            
            let cell = _cell as? HeadingCollectionCell
            cell?.headingLbl.text = self.HeadingArray[indexPath.row]
            cell?.carImg.image = self.imagesArray[indexPath.row]
            
        }, aRowSelectedListener: { (indexPath, item) in
            
            
        }, willDisplayCell:{ (indexPath) in
            
            if indexPath.item == 0 {
            
            self.setIndicatorWidth(indicator1: 40, indicator2: 20, indicator3: 20)
            self.setPageScrollerColour(view1Colour: UIColor.white, view2Colour: UIColor.lightGray, view3Colour: UIColor.lightGray)
                
            }else if indexPath.item == 1 {
                 self.setIndicatorWidth(indicator1: 20, indicator2: 40, indicator3: 20)
                self.setPageScrollerColour(view1Colour: UIColor.lightGray, view2Colour: UIColor.white, view3Colour: UIColor.lightGray)
                
            }else {
                self.setIndicatorWidth(indicator1: 20, indicator2: 20, indicator3: 40)
                self.setPageScrollerColour(view1Colour: UIColor.gray, view2Colour: UIColor.lightGray, view3Colour: UIColor.white)
            }
            
        }, scrollViewDelegate: nil)
        
        collectionTable.dataSource = HeadingCollectionViewDataSource
        collectionTable.delegate = HeadingCollectionViewDataSource
        collectionTable.reloadData()
    }
    
    //MARK:- EXTRA FUNCTIONS
    
    func setPageScrollerColour(view1Colour:UIColor,view2Colour:UIColor,view3Colour:UIColor){
            arrrayIndicatorView[0].backgroundColor = view1Colour
            arrrayIndicatorView[1].backgroundColor = view2Colour
            arrrayIndicatorView[2].backgroundColor = view3Colour
        }
    
    func setIndicatorWidth(indicator1:CGFloat,indicator2:CGFloat,indicator3:CGFloat){
        
        self.arrayIndicatorConstraint[0].constant =  indicator1
        self.arrayIndicatorConstraint[1].constant =  indicator2
        self.arrayIndicatorConstraint[2].constant =  indicator3
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func setGradientColur(gradientView:UIView) {
//        let dimAlphaRedColor =  UIColor.red.withAlphaComponent(0.7)
//        gradientView.backgroundColor =  dimAlphaRedColor
        
        
        let colorTop =  UIColor.clear.cgColor
        let colorBottom = UIColor(red: 41.0/255.0, green: 47.0/255.0, blue: 56.0/255.0, alpha: 1.0).cgColor
        let gradientLayer = CAGradientLayer()
        //UIColor.BackgroundRustColor
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 2.0]
        gradientLayer.frame = self.view.bounds

        self.gradientView.layer.insertSublayer(gradientLayer, at:0)
    }
    
//    func downloadImage(){
//
//        var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
//
//        let S3BucketName: String = "bucketName"
//        let S3DownloadKeyName: String = "public/testImage.jpg"
//
//        let expression = AWSS3TransferUtilityDownloadExpression()
//
//
//
//
//
//        expression.download(downloadRequest).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask<AnyObject>) -> Any? in
//
//            if let error = task.error as? NSError {
//                if error.domain == AWSS3TransferManagerErrorDomain, let code = AWSS3TransferManagerErrorType(rawValue: error.code) {
//                    switch code {
//                    case .cancelled, .paused:
//                        break
//                    default:
//                        print("Error downloading: \(downloadRequest.key) Error: \(error)")
//                    }
//                } else {
//                    print("Error downloading: \(downloadRequest.key) Error: \(error)")
//                }
//                return nil
//            }
//            print("Download complete for: \(downloadRequest.key)")
//            let downloadOutput = task.result
//            return nil
//        })
//    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor) {
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [colorTop, colorBottom]
//        gradientLayer.frame = gradientView.bounds
//        self.gradientView.layer.insertSublayer(gradientLayer, at: 0)
//
//    }
    
}

