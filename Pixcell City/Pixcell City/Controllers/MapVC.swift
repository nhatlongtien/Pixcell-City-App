//
//  ViewController.swift
//  Pixcell City
//
//  Created by NGUYENLONGTIEN on 5/21/20.
//  Copyright © 2020 NGUYENLONGTIEN. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Alamofire
import AlamofireImage
class MapVC: UIViewController, UIGestureRecognizerDelegate {
    // MARK: UI elements
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var heightPullUpView: NSLayoutConstraint!
    
    var spiner:UIActivityIndicatorView?
    var progressLbl:UILabel?
    var collectionView:UICollectionView?
    var flowLayout = UICollectionViewFlowLayout()
    
    // MARK: Model
    var locationManager = CLLocationManager()
    let authorization = CLLocationManager.authorizationStatus()
    let regionRadious:Double = 1000
    var imageUrlArray = [String]()
    var imageArray = [UIImage]()
    //
    var photoIdScrect = [Photo]()
    var photoIdSecretOfImageSelected:Photo?
    var imageSelected:UIImage?
    // MARK: - UI viewController
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        //
        configureLocationSevice()
        //
        addDoubleTap()
        //
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: photoCellIdentifire)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        pullUpView.addSubview(collectionView!)
    }
    // MARK: - UI events

    @IBAction func centerMapButton(_ sender: Any) {
        self.centerMapOnUserLocation()
    }
    // MARK: Helper Method
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(MapVC.dropPin(sender:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }
    func addSwipe(){
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(hidePullUpView))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func addSpiner(){
        spiner = UIActivityIndicatorView()
        spiner?.center = CGPoint(x: view.bounds.size.width/2 - (spiner?.frame.size.width)!/2, y: 150)
        spiner?.style = .large
        spiner?.color = UIColor.lightGray
        spiner?.startAnimating()
        pullUpView.addSubview(spiner!)
    }
    func removeSpiner(){
        if spiner != nil{
            spiner?.removeFromSuperview()
        }
    }
    func addProgressLbl(){
        progressLbl = UILabel()
        progressLbl?.frame = CGRect(x: view.bounds.size.width/2 - 100, y: 175, width: 200, height: 40)
        progressLbl?.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        progressLbl?.textAlignment = .center
        //progressLbl?.text = "12/40 PHOTO LOADED"
        pullUpView.addSubview(progressLbl!)
    }
    func removeProgressLbl(){
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
    }
    func retrieveUrls(forAnnotation annotation:DropablePin, completionHandler: @escaping (_ status:Bool)->()){
        imageUrlArray = []
        AF.request(flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 200)).validate().responseJSON { (respone) in
            if respone.error == nil {
                guard let json = respone.value as? Dictionary<String,AnyObject> else {return}
                let photosDict = json["photos"] as! Dictionary<String, AnyObject>
                let photoDictArray = photosDict["photo"] as! [Dictionary<String,AnyObject>]
                for photo in photoDictArray{
                    let farm = photo["farm"]
                    let id = photo["id"] as! String
                    let sever = photo["server"] as! String
                    let secret = photo["secret"] as! String
                    //
                    let postUrl = "https://farm\(farm!).staticflickr.com/\(sever)/\(id)_\(secret)_w_d.jpg"
                    self.imageUrlArray.append(postUrl)
                    //
                    let postPhotoIdSecret = Photo(phtoId: id, phtoSecret: secret)
                    self.photoIdScrect.append(postPhotoIdSecret)
                }
                print(self.imageUrlArray)
                completionHandler(true)
            }else{
                debugPrint(respone.error as Any)
                completionHandler(false)
            }
        }
    }
    func retrieveImage(withUrl url:String, completionHandle: @escaping (_ status:Bool) -> ()){
        imageArray = []
        AF.request(url).validate().responseImage { (response) in
            if response.error == nil{
                let image = response.value
                self.imageArray.append(image!)
                completionHandle(true)
            }else{
                debugPrint(response.error as Any)
                completionHandle(false)
            }
        }
    }
    func alamofireStopAllRequest(){
        Alamofire.Session.default.session.getTasksWithCompletionHandler { (DataTask, UploadTask, DowloadloadTask) in
            DataTask.forEach({$0.cancel()})
            UploadTask.forEach({$0.cancel()})
            DowloadloadTask.forEach({$0.cancel()})
        }
    }
    
}
// MARK: UI MapView Delegate
extension MapVC: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DropablePin")
        pinAnnotation.tintColor = UIColor.orange
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    func centerMapOnUserLocation(){
        guard let coordinate = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadious * 2.0, longitudinalMeters: regionRadious * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    @objc func dropPin(sender:UITapGestureRecognizer){
        //
        alamofireStopAllRequest()
        //
        removeAnnotation()
        //
        removeSpiner()
        //
        removeProgressLbl()
        //
        imageUrlArray = []
        //
        imageArray = []
        //
        self.collectionView?.reloadData()
        //
        
        showPullUpView()
        //
        addSwipe()
        //
        addSpiner()
        //
        addProgressLbl()
        //
        addDoubleTap()
        let senderLocation = sender.location(in: mapView)
        let coordinateSender = mapView.convert(senderLocation, toCoordinateFrom: mapView)
        let annotation = DropablePin(coordinate: coordinateSender, identifier: "DropablePin")
        mapView.addAnnotation(annotation)
        //
        //flickrUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)
        //
        let coordinateRegion = MKCoordinateRegion(center: coordinateSender, latitudinalMeters: regionRadious * 2.0, longitudinalMeters: regionRadious * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        //
        retrieveUrls(forAnnotation: annotation) { (success) in
            if success{
                print("retrieve All photo url from annnotation successfull")
                for url in self.imageUrlArray{
                    self.retrieveImage(withUrl: url) { (success) in
                        if success {
                            // update progess Lable
                            self.progressLbl?.text = "\(self.imageArray.count)/\(self.imageUrlArray.count) PHOTO LOADED"
                            // stop spiner
                            if self.imageArray.count == self.imageUrlArray.count {
                                self.removeSpiner()
                                self.removeProgressLbl()
                            }
                            // reload collectionView
                            self.collectionView?.reloadData()
                        }else{
                            print("Cant not dowload photo from url")
                        }
                    }
                }
            }else{
                print("Can not retrieve url image from the API")
            }
        }
    }
    //
    func removeAnnotation(){
        for annotation in mapView.annotations{
            mapView.removeAnnotation(annotation)
        }
    }
    //
    func showPullUpView(){
        heightPullUpView.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    //
    @objc func hidePullUpView(){
        //
        alamofireStopAllRequest()
        //
        heightPullUpView.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
// MARK: - Location Manager Delegate
extension MapVC:CLLocationManagerDelegate{
    func configureLocationSevice(){
        if authorization == .notDetermined{
            locationManager.requestAlwaysAuthorization()
        }else{
            return
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.centerMapOnUserLocation()
    }
}
// MARK: UICollectionView Delegate & dataSource
extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifire, for: indexPath) as? PhotoCell{
            //
            cell.imageView.image = self.imageArray[indexPath.row]
//            let imageView = UIImageView(image: self.imageArray[indexPath.row])
//            cell.addSubview(imageView)
            return cell
        }else{
            return UICollectionViewCell()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imageSelected = imageArray[indexPath.row]
        //
        photoIdSecretOfImageSelected = Photo(phtoId: photoIdScrect[indexPath.row].phtoId, phtoSecret: photoIdScrect[indexPath.row].phtoSecret)
        performSegue(withIdentifier: "toPopVC", sender: nil)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var numberOfColumns:CGFloat = 4
        if UIScreen.main.bounds.width > 320 {
            numberOfColumns = 5
        }
        var padding:CGFloat = 10
        var spaceBetweenCell:CGFloat = 10
        let cellDimension = ((collectionView.bounds.width - padding) - (numberOfColumns - 1)*spaceBetweenCell)/numberOfColumns
        return CGSize(width: cellDimension, height: cellDimension)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPopVC"{
            let dest = segue.destination as! PopVC
            dest.imageSelected = imageSelected
            dest.photoId = photoIdSecretOfImageSelected?.phtoId
            dest.photoSecret = photoIdSecretOfImageSelected?.phtoSecret
        }
    }
}

