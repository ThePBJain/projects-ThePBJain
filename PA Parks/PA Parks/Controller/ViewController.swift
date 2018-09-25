//
//  ViewController.swift
//  PA Parks
//
//  Created by Pranav Jain on 9/23/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit

extension CGPoint{
    static func -(left:CGPoint, right:CGPoint) -> CGPoint{
        return CGPoint(x: left.x-right.x, y: left.y-right.y)
    }
    static func +(left:CGPoint, right:CGPoint) -> CGPoint{
        return CGPoint(x: left.x+right.x, y: left.y+right.y)
    }
}

class ViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var parksScrollView: UIScrollView!
    let parkModel = ParkModel()
    let standardRotation = CGFloat.pi/2
    let invisibleAlpha: CGFloat = 0.0
    let visibleAlpha: CGFloat = 1.0
    let animationTime = 0.5
    let animationDelay = 1.0
    var buttons = [UIButton]()
    var parks = [UIView]()
    var parkGallery : [String:[(UIScrollView, UIImageView)]]
    var parkNumber = 0
    var currentParkImage = 0
    
    //MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        //this is actually insane
        var _parkGallery = [String:[(UIScrollView, UIImageView)]]()
        for i in 0..<parkModel.numParks {
            let name = parkModel.parkNames(index: i)
            let images = parkModel.parkImages(park: name)
            var _imgViews = [(UIScrollView, UIImageView)]()
            for image in images {
                let imageView = UIImageView(image: UIImage(named: image))
                imageView.isUserInteractionEnabled = true
                let scrollImg = UIScrollView(frame: CGRect.zero)
                scrollImg.minimumZoomScale = 1.0
                scrollImg.maximumZoomScale = 5.0
                _imgViews.append((scrollImg, imageView))
            }
            _parkGallery[name] = _imgViews
        }
        parkGallery = _parkGallery
        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //configurePageControl()
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Auto Layout
    override func viewDidLayoutSubviews() {
        //rotate button images
        //downButton.transform = CGAffineTransform(rotationAngle: standardRotation)
        downButton.isEnabled = true
        downButton.alpha = invisibleAlpha
        buttons.append(downButton)
        leftButton.transform = CGAffineTransform(rotationAngle: standardRotation)
        leftButton.isEnabled = false
        leftButton.alpha = invisibleAlpha
        buttons.append(leftButton)
        upButton.transform = CGAffineTransform(rotationAngle: standardRotation*2.0)
        upButton.isEnabled = false
        upButton.alpha = invisibleAlpha
        buttons.append(upButton)
        rightButton.transform = CGAffineTransform(rotationAngle: standardRotation*3.0)
        rightButton.isEnabled = true
        rightButton.alpha = invisibleAlpha
        buttons.append(rightButton)
        configureScrollView()
    }
    
    //MARK: - Configuration functions
    func configureScrollView() {
        parksScrollView.isPagingEnabled = true

        for i in 0..<parkModel.numParks {
            let name = parkModel.parkNames(index: i)
            let label = UILabel(frame: CGRect.zero)
            label.text = name
            label.textAlignment = .center
            label.frame.size = CGSize(width: parksScrollView.bounds.size.width, height: 20)
            label.center = CGPoint(x: Int(self.view.center.x), y: 40)
            let size = parksScrollView.bounds.size
            //found enumerated in swift docs
            for (index, (scrollView, imageView)) in parkGallery[name]!.enumerated(){
                scrollView.frame.size = size
                scrollView.frame.origin = CGPoint(x: CGFloat(i)*size.width, y: CGFloat(index)*size.height)
                scrollView.delegate = self
                imageView.frame.size = size
                imageView.contentMode = .scaleAspectFit
                
                if(index == 0){
                    imageView.addSubview(label)
                    parks.append(imageView)
                }
                scrollView.addSubview(imageView)
                parksScrollView.addSubview(scrollView)
                
            }
            parksScrollView.contentSize = CGSize(width: size.width*CGFloat(parkModel.numParks), height: size.height*CGFloat(parkModel.parkImageCount(index: 0)))
        }
        for button in buttons {
            self.view.bringSubview(toFront: button)
        }
    }
    
    fileprivate func updateValues(_ scrollView: UIScrollView) {
        if scrollView == parksScrollView {
            parkNumber = Int(scrollView.contentOffset.x / scrollView.bounds.width)
            scrollView.contentSize.height = CGFloat(parkModel.parkImageCount(index: parkNumber)) * scrollView.bounds.height
            currentParkImage = Int(scrollView.contentOffset.y/scrollView.bounds.height)
            
            //set buttons
            if currentParkImage == 0 {
                upButton.isEnabled = false
                upButton.alpha = invisibleAlpha
                downButton.isEnabled = true
                downButton.alpha = visibleAlpha
                
                if parkNumber == 0 {
                    leftButton.isEnabled = false
                    leftButton.alpha = invisibleAlpha
                }else{
                    leftButton.isEnabled = true
                    leftButton.alpha = visibleAlpha
                }
                if parkNumber == parkModel.numParks - 1 {
                    rightButton.isEnabled = false
                    rightButton.alpha = invisibleAlpha
                }else{
                    rightButton.isEnabled = true
                    rightButton.alpha = visibleAlpha
                }
            }else{
                leftButton.isEnabled = false
                leftButton.alpha = invisibleAlpha
                rightButton.isEnabled = false
                rightButton.alpha = invisibleAlpha
                
                upButton.isEnabled = true
                upButton.alpha = visibleAlpha
                if currentParkImage == parkModel.parkImageCount(index: parkNumber) - 1 {
                    downButton.isEnabled = false
                    downButton.alpha = invisibleAlpha
                }else{
                    downButton.isEnabled = true
                    downButton.alpha = visibleAlpha
                }
            }
            
        }
    }
    
    //MARK: - ScrollView Delegate Methods
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == parksScrollView {
            let currentPark = parkModel.parkNames(index: parkNumber)
            let currentScrollView = parkGallery[currentPark]?[currentParkImage].0
            currentScrollView?.setZoomScale(0.0, animated: true)
            UIButton.animate(withDuration: animationTime) {
                for button in self.buttons {
                    if button.isEnabled {
                        button.alpha = self.visibleAlpha
                    }
                }
            }
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == parksScrollView {
            if(scrollView.contentOffset.y > 0.0){
                scrollView.contentOffset.x = CGFloat(parkNumber) * scrollView.bounds.size.width
                scrollView.contentSize.width = scrollView.bounds.size.width
            }else{
                scrollView.contentSize.width = scrollView.bounds.size.width * CGFloat(parkModel.numParks)
            }
        }
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == parksScrollView {
            updateValues(scrollView)
            UIView.animate(withDuration: animationTime, delay: animationDelay, options: .transitionCrossDissolve, animations: {
                for button in self.buttons {
                    button.alpha = self.invisibleAlpha
                }
            }){ (completed) in
            }
        }
        
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateValues(scrollView)
        UIView.animate(withDuration: animationTime, delay: animationDelay, options: .transitionCrossDissolve, animations: {
            for button in self.buttons {
                button.alpha = self.invisibleAlpha
            }
        }){ (completed) in
            
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        //find imageView needed to scale
        let currentPark = parkModel.parkNames(index: parkNumber)
        let currentView = parkGallery[currentPark]?[currentParkImage].1
        return currentView
    }
    
    
    // MARK: Button Action Methods
    
    @IBAction func moveScrollView(_ sender: UIButton) {
        
        //0 down, 1 left, 2 right, 3 up
        let direction = sender.tag
        let _x = Int(parksScrollView.contentOffset.x/parksScrollView.bounds.size.width)*Int(parksScrollView.bounds.size.width)
        let _y = Int(parksScrollView.contentOffset.y/parksScrollView.bounds.size.height)*Int(parksScrollView.bounds.size.height)
        let currentLocation = CGPoint(x: _x, y: _y)
        let offset: CGPoint!
        switch direction {
        case 0:
            //down
            offset = CGPoint(x: 0.0, y: parksScrollView.bounds.height)
        case 1:
            //left
            offset = CGPoint(x: -parksScrollView.bounds.width, y: 0.0)
        case 2:
            //right
            offset = CGPoint(x: parksScrollView.bounds.width, y: 0.0)
        case 3:
            //up
            offset = CGPoint(x: 0.0, y: -parksScrollView.bounds.height)
        default:
            offset = CGPoint(x: 0.0, y: 0.0)
        }
        parksScrollView.setContentOffset(currentLocation + offset, animated: true)
        
    }
}

