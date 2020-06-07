//
//  PopVC.swift
//  Pixcell City
//
//  Created by NGUYENLONGTIEN on 5/31/20.
//  Copyright © 2020 NGUYENLONGTIEN. All rights reserved.
//

import UIKit
import Alamofire
import MapKit
class PopVC: UIViewController, UIGestureRecognizerDelegate {
    // MARK: - UI Element
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleImageLable: UILabel!
    @IBOutlet weak var descriptionImageLable: UILabel!
    @IBOutlet weak var dateLable: UILabel!
    @IBOutlet weak var heightDesciptionLbl: NSLayoutConstraint!
    //
    
    
    // MARK: - UI Model
    var imageSelected:UIImage?
    var photoId:String?
    var photoSecret:String?
    //
    let regionRadious:Double = 500
    //
    var photoInfomation:PhotoInfo?
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        guard let photo = imageSelected else {return}
        imageView.contentMode = .scaleAspectFill
        imageView.image = imageSelected
        //
        addDoubleTap()
        //
        retrieveInfomationOfImage(withPhotoId: photoId!, withPhotoSecret: photoSecret!) { (success) in
            if success {
                print("Get du lieu thanh cong")
            }else{
                print("Get du lieu khong thanh cong")
            }
        }
        //
        mapView.delegate = self
        //
    }
    //
   
    // MARK: Helper Method
    func addDoubleTap(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        tap.numberOfTapsRequired = 2
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    @objc func handleDoubleTap(){
        self.dismiss(animated: true, completion: nil)
    }
    func retrieveInfomationOfImage(withPhotoId Id:String, withPhotoSecret secret:String, completionHandler: @escaping (_ status:Bool)->()){
        AF.request(urlToGetDetailInfo(forApiKey: apiKey, withPhotoId: Id, withPhotoSecret: secret)).validate().responseJSON { (response) in
            if response.error == nil{
                // lay du lieu ra
                guard let json = response.value as? Dictionary<String, AnyObject> else {return}
                let photoInfo = json["photo"] as! Dictionary<String, AnyObject>
                
                let photoInfoTitle = photoInfo["title"] as! Dictionary<String, AnyObject>
                var title = photoInfoTitle["_content"] as! String
                //
                let photoInfoDescription = photoInfo["description"] as! Dictionary<String, AnyObject>
                var description = photoInfoDescription["_content"] as! String
                //
                let photoInfoDates = photoInfo["dates"] as! Dictionary<String, AnyObject>
                var postDate = photoInfoDates["taken"] as! String
                //
                let photoInfoLocation = photoInfo["location"] as! Dictionary<String, AnyObject>
                var latitude = photoInfoLocation["latitude"] as! String
                var longitude = photoInfoLocation["longitude"] as! String
                
                var coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(Float(latitude)!), longitude: CLLocationDegrees(Float(longitude)!))
                self.photoInfomation = PhotoInfo(coordinate: coordinate, title: title, description: description, postDay: postDate)
                //
                self.updateUI(withPhotoDescription: self.photoInfomation!)
                self.centerMapOnUerLocation(withPhotoCooordiate: (self.photoInfomation?.coordinate)!)
                completionHandler(true)
            }else{
                completionHandler(false)
            }
        }
    }
    //
    func updateUI(withPhotoDescription photoInfo:PhotoInfo){
        
        let formatter = DateFormatter()
        //2018-08-20 21:18:06
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatter.date(from: photoInfo.postDay!)
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        let postDate = formatter.string(from: date!)
        //
        if photoInfo.title == ""{
            titleImageLable.text = "No Titile"
        }else{
            titleImageLable.text = photoInfo.title
        }
        if photoInfo.description == "" {
            descriptionImageLable.text = "No Description"
            let height = estimateHeightOfText(withText: "No Description", withFontName: "Helvetica Neue", withFontSize: 15)
            heightDesciptionLbl.constant = height
        }else{
            descriptionImageLable.text = photoInfo.description
            let height = estimateHeightOfText(withText: photoInfo.description!, withFontName: "Helvetica Neue", withFontSize: 15)
            heightDesciptionLbl.constant = height
        }
        dateLable.text = postDate
        
    }
    //
    func estimateHeightOfText(withText text:String, withFontName font:String, withFontSize fontsize:CGFloat) -> CGFloat {
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimateFrame = NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont(name: font, size: fontsize)], context: nil)
        return estimateFrame.height
    }
    
}
// MARK: -UI MapView Delegate
extension PopVC: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DropablePin")
        pinAnnotation.tintColor = .orange
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    func centerMapOnUerLocation(withPhotoCooordiate coordinate: CLLocationCoordinate2D){
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadious * 2.0, longitudinalMeters: regionRadious * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        let annotation = DropablePin(coordinate: coordinate, identifier: "DropablePin")
        mapView.addAnnotation(annotation)
    }
}
