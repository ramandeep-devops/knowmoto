//
//  KnowmotoSearchField.swift
//  Knowmoto
//
//  Created by Dhan Guru Nanak on 8/8/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
import MapboxGeocoder
import AWSS3

class KnowmotoSearchTextField:CustomSearchTextField{
    
    open var searchType:ENUM_SEARCH_TYPE = .location
    open var blockSearchResult:((Array<Any>?,ENUM_SEARCH_TYPE)->())?
    var allowedScopes:MBPlacemarkScope = [.all]
    var getResultfor:String?{
        didSet{
            if self.blockSearchResult != nil{
                
                self.getSearchData(searchText: getResultfor ?? "", completion: { (arrayItems) in
                    
                    self.blockSearchResult?(arrayItems,self.searchType)
                    
                })
                
            }
            getResultfor = nil
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
        self.didChangeSearchField = { [weak self] (text) in // getting user search text
            
            debugPrint(text)
            if self?.blockSearchResult != nil{
                
                self?.getSearchData(searchText: text, completion: { (arrayItems) in
                    
                    self?.activityIndicator?.stopAnimating()
                    self?.blockSearchResult?(arrayItems,self?.searchType ?? .location)
                    
                })
                
            }
            
        }
    }
    
    
    //get search result of specific type set in class
    private func getSearchData(searchText:String,completion:@escaping (Array<Any>) ->()){
        
        switch searchType{
            
        case .location:
            
          MapBoxGeocodingCustom.forwarGeocode(text: searchText, completion: completion)
            
            break
        default:
            break
        }
        
    }
    
}

