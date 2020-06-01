//
//  DropablePin.swift
//  Pixcell City
//
//  Created by NGUYENLONGTIEN on 5/29/20.
//  Copyright © 2020 NGUYENLONGTIEN. All rights reserved.
//

import Foundation
import UIKit
import MapKit
class DropablePin: NSObject, MKAnnotation{
    var coordinate:CLLocationCoordinate2D
    var identifier:String
    init(coordinate:CLLocationCoordinate2D, identifier:String){
        self.coordinate = coordinate
        self.identifier = identifier
    }
}
