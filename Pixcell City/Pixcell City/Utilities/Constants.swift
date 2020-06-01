//
//  Constants.swift
//  Pixcell City
//
//  Created by NGUYENLONGTIEN on 5/30/20.
//  Copyright © 2020 NGUYENLONGTIEN. All rights reserved.
//

import Foundation
//
let photoCellIdentifire = "photoCell"
//
let apiKey = "08336ba4eac425523e005d502ae028fb"
func flickrUrl(forApiKey key:String, withAnnotation annotation:DropablePin, andNumberOfPhotos number:Int) -> String{
    let url =  "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
    print(url)
    return url
}


