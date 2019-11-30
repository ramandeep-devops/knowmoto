//
//  GalleryPageViewController.swift
//  Knowmoto
//
//  Created by Apple on 03/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class GalleryPageViewController: UIPageViewController,UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
   
    var index = 0
    var arrayViewControllers: [UIViewController] = [ENUM_STORYBOARD<PhotosVC>.post.instantiateVC(), ENUM_STORYBOARD<CameraVC>.post.instantiateVC()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        if let scrollView = self.view.subviews.filter({$0.isKind(of: UIScrollView.self)}).first as? UIScrollView {
            scrollView.isScrollEnabled = false
        }
       
        let startingViewController = self.viewControllerAtIndex(index: self.index)
        let viewControllers: [UIViewController] = [startingViewController!]
        self.setViewControllers(viewControllers, direction: UIPageViewController.NavigationDirection.forward, animated: false, completion: nil)
    }
    
    func viewControllerAtIndex(index: Int) -> UIViewController? {
        
        //first view controller = firstViewControllers navigation controller
        return arrayViewControllers[index]
       
    }
    
    func setViewController(ofIndex:Int){
        
        if self.index == ofIndex{
            return
        }
        
        self.index = ofIndex
      
        self.setViewControllers([arrayViewControllers[ofIndex]], direction: self.index == 1 ? UIPageViewController.NavigationDirection.forward : UIPageViewController.NavigationDirection.reverse, animated: true){ [weak self] (_) in
            
//            self?.topMostVC?.view.isUserInteractionEnabled = true
            
        }
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
   
        //if the index is 0, return nil since we dont want a view controller before the first one
        if index == 0 {
            
            return nil
        }
        
        //decrement the index to get the viewController before the current one
        self.index = self.index - 1
        return self.viewControllerAtIndex(index: self.index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
      
        //if the index is the end of the array, return nil since we dont want a view controller after the last one
        if index == arrayViewControllers.count - 1 {
            
            return nil
        }
        
        //increment the index to get the viewController after the current index
        self.index = self.index + 1
        return self.viewControllerAtIndex(index: self.index)
        
    }
 
 
}
