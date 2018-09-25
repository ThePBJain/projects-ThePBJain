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
    var buttons = [UIButton]()
    var parks = [UIView]()
    
    var parkGallery : [String:[UIImageView]]
    
    var parkNumber = 0
    var currentParkImage = 0
    
    //MARK: - Initialization
    required init?(coder aDecoder: NSCoder) {
        var _parkGallery = [String:[UIImageView]]()
        for i in 0..<parkModel.numParks {
            let name = parkModel.parkNames(index: i)
            let images = parkModel.parkImages(park: name)
            var _imgViews = [UIImageView]()
            for image in images {
                let imageView = UIImageView(image: UIImage(named: image))
                _imgViews.append(imageView)
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
        downButton.isHidden = false
        buttons.append(downButton)
        leftButton.transform = CGAffineTransform(rotationAngle: standardRotation)
        leftButton.isEnabled = false
        leftButton.isHidden = true
        buttons.append(leftButton)
        upButton.transform = CGAffineTransform(rotationAngle: standardRotation*2.0)
        upButton.isEnabled = false
        upButton.isHidden = true
        buttons.append(upButton)
        rightButton.transform = CGAffineTransform(rotationAngle: standardRotation*3.0)
        rightButton.isEnabled = true
        rightButton.isHidden = false
        buttons.append(rightButton)
        configureScrollView()
    }
    
    //MARK: - Configuration functions
    func configureScrollView() {
        parksScrollView.isPagingEnabled = true
        
        // create colored pages, each with a title label
        for i in 0..<parkModel.numParks {
            let name = parkModel.parkNames(index: i)
            let label = UILabel(frame: CGRect.zero)
            label.text = name
            label.textAlignment = .center
            label.frame.size = CGSize(width: parksScrollView.bounds.size.width, height: 20)
            label.center = CGPoint(x: Int(self.view.center.x), y: 40)
            let size = parksScrollView.bounds.size
            //found enumerated in swift docs
            for (index, imageView) in parkGallery[name]!.enumerated(){
                
                imageView.frame.size = size
                imageView.contentMode = .scaleAspectFit
                imageView.frame.origin = CGPoint(x: CGFloat(i)*size.width, y: CGFloat(index)*size.height)
                if(index == 0){
                    imageView.addSubview(label)
                    parks.append(imageView)
                }
                parksScrollView.addSubview(imageView)
                
            }
            parksScrollView.contentSize = CGSize(width: size.width*CGFloat(parkModel.numParks), height: size.height*CGFloat(parkModel.parkImageCount(index: 0)))
            //parksScrollView.addSubview(view)
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
                upButton.isHidden = true
                downButton.isEnabled = true
                downButton.isHidden = false
                
                if parkNumber == 0 {
                    leftButton.isEnabled = false
                    leftButton.isHidden = true
                }else{
                    leftButton.isEnabled = true
                    leftButton.isHidden = false
                }
                if parkNumber == parkModel.numParks - 1 {
                    rightButton.isEnabled = false
                    rightButton.isHidden = true
                }else{
                    rightButton.isEnabled = true
                    rightButton.isHidden = false
                }
            }else{
                leftButton.isEnabled = false
                leftButton.isHidden = true
                rightButton.isEnabled = false
                rightButton.isHidden = true
                
                upButton.isEnabled = true
                upButton.isHidden = false
                if currentParkImage == parkModel.parkImageCount(index: parkNumber) - 1 {
                    downButton.isEnabled = false
                    downButton.isHidden = true
                }else{
                    downButton.isEnabled = true
                    downButton.isHidden = false
                }
            }
            
        }
    }
    
    //MARK: - ScrollView Delegate Methods
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIButton.animate(withDuration: 0.5) {
            for button in self.buttons {
                if button.isEnabled {
                    button.isHidden = false
                    button.isHighlighted = true
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
        print("didDecelerate")
        updateValues(scrollView)
        
        UIButton.animate(withDuration: 0.5) {
            for button in self.buttons {
                button.isHidden = true
            }
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        print("test")
        updateValues(scrollView)
        UIButton.animate(withDuration: 0.5) {
            for button in self.buttons {
                button.isHidden = true
            }
        }
    }
    
    // MARK: Button Action Methods
    
    @IBAction func moveScrollView(_ sender: UIButton) {
        for button in buttons {
            button.isEnabled = false
        }
        //0 down, 1 left, 2 right, 3 up
        let direction = sender.tag
        let currentLocation = parksScrollView.contentOffset
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

