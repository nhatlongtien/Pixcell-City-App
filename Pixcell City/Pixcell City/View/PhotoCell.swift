//
//  PhotoCell.swift
//  Pixcell City
//
//  Created by NGUYENLONGTIEN on 5/30/20.
//  Copyright © 2020 NGUYENLONGTIEN. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    var imageView:UIImageView?
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
