//
//  AddmoreButtonView.swift
//  Knowmoto
//
//  Created by cbl16 on 10/08/19.
//  Copyright © 2019 Codebbewlabs. All rights reserved.
//

import Foundation
class AddMoreButtonCollectionReusableView : UICollectionReusableView {
    
    //Instanstiate nib
    class func instanceFromNib() -> AddMoreButtonCollectionReusableView {
        return UINib(nibName: "AddMoreButtonCollectionReusableView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView as! AddMoreButtonCollectionReusableView
    }
}

class TextCollectionViewReusableView : UICollectionReusableView {
    
    //Instanstiate nib
    class func instanceFromNib() -> TextCollectionReusableView {
        return UINib(nibName: "TextCollectionReusableView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as! UIView as! TextCollectionReusableView
    }
}
