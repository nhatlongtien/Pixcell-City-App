//
//  PhotoCell.swift
//  Pixcell City
//
//  Created by NGUYENLONGTIEN on 5/30/20.
//  Copyright © 2020 NGUYENLONGTIEN. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.image = #imageLiteral(resourceName: "noImage")
        image.layer.cornerRadius = 10
        image.clipsToBounds = true
        
        return image
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        //
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
