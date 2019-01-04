//
//  ViewController.swift
//  lightbox
//
//  Created by Aaron Spitalny on 12/4/18.
//  Copyright © 2018 Aaron Spitalny. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextViewDelegate, FrameExtractorDelegate {

    var frameExtractor: FrameExtractor!
    let loadingIndicator = UIActivityIndicatorView()
    @IBOutlet weak var captureImageBtn: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var rect: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //set border color and width of rectangle
        self.rect.layer.borderWidth = 3
        self.rect.layer.borderColor = UIColor(red:0/255, green:191/255, blue:254/255, alpha: 1).cgColor
//        print (self.rect.frame.origin.x)
//        print (self.rect.frame.origin.y)
//        print (self.rect.frame.size.width)
//        print (self.rect.frame.size.height)
//        print("image view")
//        print (self.imageView.frame.origin.x)
//        print (self.imageView.frame.origin.y)
//        print (self.imageView.frame.size.width)
//        print (self.imageView.frame.size.height)
        //create loader
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.whiteLarge
        loadingIndicator.startAnimating();
        loadingIndicator.center = CGPoint(x: imageView.center.x+20,
                                          y: imageView.center.y-30)
        //apply round corners to button
        self.applyRoundCorner(captureImageBtn)
        frameExtractor = FrameExtractor()
        frameExtractor.delegate = self
    }
    
    //this function sets the image view to the captured image
    func captured(image: UIImage, flag: Bool) {
        if flag {
            loadingIndicator.removeFromSuperview()
        }
        imageView.image = image
    }
    //this function is called be the captureImage button is pressed
    @IBAction func captureImageBtnAction(_ sender: Any) {
        let myGroup = DispatchGroup()
        myGroup.enter()
        self.rect.isHidden =  !self.rect.isHidden
        myGroup.leave()
        myGroup.notify(queue: DispatchQueue.main) {
            if !self.imageView.subviews.contains(self.loadingIndicator) && self.rect.isHidden{
                print("1")
                self.imageView.addSubview(self.loadingIndicator)
            }
             self.frameExtractor.toggleCaptureSession()
            
        }
    }

    func applyRoundCorner(_ object:AnyObject){
        object.layer.cornerRadius = object.frame.size.width / 2
        object.layer.masksToBounds = true
    }
    
}

