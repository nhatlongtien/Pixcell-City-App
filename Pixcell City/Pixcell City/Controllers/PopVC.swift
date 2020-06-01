//
//  PopVC.swift
//  Pixcell City
//
//  Created by NGUYENLONGTIEN on 5/31/20.
//  Copyright © 2020 NGUYENLONGTIEN. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {
    // MARK: - UI Element
    @IBOutlet weak var imageView: UIImageView!
    // MARK: - UI Model
    var imageSelected:UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        guard let photo = imageSelected else {return}
        imageView.contentMode = .scaleAspectFill
        imageView.image = imageSelected
        //
        addDoubleTap()
    }
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
    
}
