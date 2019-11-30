//
//  VehiclesCollectionLayoutListVC.swift
//  Knowmoto
//
//  Created by Apple on 18/09/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import UIKit

class VehiclesCollectionLayoutListVC: BaseVC {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var arrayPostsOrCars:[PostList] = []{
        didSet{
            
            arrayPostsOrCars.isEmpty ? self.setCollectionViewBackgroundView(collectionView: collectionView) :  (self.collectionView.backgroundView = nil)
            self.collectionView.reloadData()
        }
    }
    let identifier = String(describing: ImageCollectionViewCell.self)
    var searchData:SearchDataModel?
    var totalPosts:Int?
    
    var limit:Int = 20
    var skip:Int = 0
    var isLoadingNextData:Bool = true
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        intialSetup()
        
    }
    
    func intialSetup(){
        
        //type 3 == color
        
        headerView.headerView.lblTitle?.text = searchData?.type == 3 ? /searchData?.color?.first : /searchData?.feature
        
        self.apiGetList()
//        self.configureCollectionHeaderFooterRefresh()
        loadNextData()
        collectionView.registerNibCollectionCell(nibName: identifier)
        collectionView.reloadData()
    }
    
    func loadNextData(){

        self.collectionView.es.addInfiniteScrolling { [weak self] in
        
            self?.skip += /self?.limit
            self?.collectionView.es.stopLoadingMore()
            self?.apiGetList()
        }
        
    }
    
}

extension VehiclesCollectionLayoutListVC:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayPostsOrCars.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! ImageCollectionViewCell
        cell.imageViewPhoto.loadImage(key: /self.arrayPostsOrCars[indexPath.row].image?.first?.original, cacheKey: /self.arrayPostsOrCars[indexPath.row].image?.first?.originalImageKey)
        return cell        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let vc = ENUM_STORYBOARD<CarDetailSegmentedVC>.car.instantiateVC()
        
        vc.vehicleId = self.arrayPostsOrCars[indexPath.row].id
        vc.isFromCarDetail = true
        
        self.topMostVC?.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
      debugPrint("size",self.collectionView.contentSize.height)
      debugPrint("offset",scrollView.contentOffset.y)
        
        if scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height{
            
            if !isLoadingNextData{
                
//                self.loadNextData()
                self.isLoadingNextData = true
                
            }
            
            debugPrint("load next")
        }
//        scrollView.conte
        
    }
    
}

//MARK:- API
extension VehiclesCollectionLayoutListVC{
    
    func apiGetList(){
        
        //searchiong cars by color name basis and features tag basis (these propeties adding while adding car in a system)
        
        //type 3 == color
        
        EP_Post.get_main_search_data(search: searchData?.type == 3 ? searchData?.color?.first : nil, id: searchData?.id, type: searchData?.type, limit: limit, skip: skip, loggedInUserId: userData?.id).request(loaderNeeded: isFirstTime, successMessage: nil, success: { [weak self] (response) in
            
            self?.isFirstTime = false
            
            let list = (response as? RootListModel<PostList>)?.list ?? []
            
            if /self?.skip == 0{
                
                self?.arrayPostsOrCars = list
                
            }else if !(list.isEmpty){
                
                self?.arrayPostsOrCars += list
                
            }
            
            self?.isLoadingNextData = false

        }) { [weak self] (error) in
            
            self?.isLoadingNextData = false
            
        }
        
    }
    
}
