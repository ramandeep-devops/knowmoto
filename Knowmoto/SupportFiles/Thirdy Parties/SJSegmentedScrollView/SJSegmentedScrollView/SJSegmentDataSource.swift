//
//  SJSegmentDataSource.swift
//  Bagant
//
//  Created by MAC_MINI_6 on 10/03/18.
//  Copyright © 2018 OSX. All rights reserved.
//

import UIKit
typealias TabChanged = (_ index : Int) -> ()
typealias Success = () -> ()

class SJSegmentDataSource: SJSegmentedViewControllerDelegate {
    
    var segmentVC: SJSegmentedViewController?
    var selectedSegment: SJSegmentTab?
    var tabChanged: TabChanged?
    var success: Success?
    var view1:UIView?
    var fontSize:CGFloat = 14.0
    var selectedTitleColor:UIColor?
    
    init(selectedTitleColor:UIColor = UIColor.HighlightSkyBlueColor!,segmentBackgroundColor:UIColor = UIColor.BackgroundRustColor!,backgrounColor:UIColor = UIColor.BackgroundRustColor!,headerViewBackgroundColor:UIColor = UIColor.BackgroundRustColor!,segmentVC: SJSegmentedViewController?, containerView: UIView, vc: UIViewController, titles: [String], segmentViewHeight: CGFloat = 48.0, selectedHeight: CGFloat = 1.0, headerHeight: CGFloat = 0.0,fontSize:CGFloat = 14.0,scrollingEnabled: Bool? = true, tabChanged: TabChanged? = nil, success: Success? = nil) {
        
        
        self.selectedTitleColor = selectedTitleColor
        self.segmentVC = segmentVC
        self.tabChanged = tabChanged
        self.success = success
    
//        segmentVC?.view.backgroundColor = backgrounColor
        segmentVC?.headerViewController?.view.backgroundColor = headerViewBackgroundColor
        segmentVC?.headerViewOffsetHeight = 0
        segmentVC?.selectedSegmentViewHeight = selectedHeight
        segmentVC?.segmentTitleFont = ENUM_APP_FONT.book.size(fontSize)
        segmentVC?.selectedSegmentViewColor = UIColor.HighlightSkyBlueColor!
        segmentVC?.headerViewHeight = headerHeight
        segmentVC?.segmentBackgroundColor = segmentBackgroundColor
        segmentVC?.segmentViewHeight = segmentViewHeight
        segmentVC?.segmentTitleColor = UIColor.white
        segmentVC?.delegate = self
        segmentVC?.segmentedScrollView.backgroundColor = backgrounColor
        segmentVC?.segmentBounces = false
        segmentVC?.segmentedScrollView.segmentBounces = false
        segmentVC?.segmentedScrollView.alwaysBounceHorizontal = false
        segmentVC?.segmentedScrollView.bounces = false
        segmentVC?.segmentedScrollView.showsVerticalScrollIndicator = false
        
        
        self.fontSize = fontSize
        for (index, element) in (segmentVC?.segmentControllers ?? []).enumerated() {
            element.title = titles.isEmpty ? "" : titles[index]
        }
        vc.addChild(segmentVC!)
        containerView.addSubview((segmentVC?.view)!)
        vc.view.bringSubviewToFront(containerView)
        
        segmentVC?.view.frame =  CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height + 24) // containerView.frame
        
      
        
        segmentVC?.didMove(toParent: vc)
        
        let headerView = segmentVC?.headerViewController?.view.bounds ?? CGRect.zero
        view1 = UIView(frame: CGRect(x: headerView.origin.x, y: headerView.origin.y, width: headerView.width, height: headerHeight))
        
//        view1?.backgroundColor = UIColor.BlueColor!
        
        
//        segmentVC?.segmentedScrollView.subviews.first?.addSubview(view1!)
//        
//        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 56, height: 32))
//        button.addTarget(self, action: #selector(self.select), for: .touchUpInside)
//        button.center = view1?.center ?? .zero
//        button.center.y = /view1?.center.y + 56
//        button.setTitle("sadsad", for: .normal)
//        segmentVC?.headerViewController?.view.isUserInteractionEnabled = false
//        
//        view1?.addSubview(button)

        if let block = success {
            block()
        }
    }
    
    @objc func select(){
        
        debugPrint("tap on button")
        
    }
    
    func didMoveToPage(_ controller: UIViewController, segment: SJSegmentTab?, index: Int) {
        
        if selectedSegment != nil {

            selectedSegment?.titleColor(UIColor.white)
            selectedSegment?.titleFont(ENUM_APP_FONT.book.size(fontSize))
            
        }
        
        if /segmentVC?.segments.count > 0 {
            
            selectedSegment = segmentVC?.segments[index]
            selectedSegment?.titleColor(selectedTitleColor ?? UIColor.white)
            selectedSegment?.titleFont(ENUM_APP_FONT.xbold.size(fontSize))
            
        }
        if let block = tabChanged {
            block(index)
        }
    }
}
