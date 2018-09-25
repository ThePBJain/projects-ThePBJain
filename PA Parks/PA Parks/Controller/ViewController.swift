//
//  ViewController.swift
//  PA Parks
//
//  Created by Pranav Jain on 9/23/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var parksScrollView: UIScrollView!
    let parkModel = ParkModel()
    
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
            parksScrollView.contentSize = CGSize(width: size.width*CGFloat(parkModel.numParks), height: size.height*CGFloat(parkModel.parkCount(index: 0)))
            //parksScrollView.addSubview(view)
        }
    }
    
    //MARK: - ScrollView Delegate Methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == parksScrollView {
            print("didScroll: \(scrollView.contentOffset.y)")
            if(scrollView.contentOffset.y >= scrollView.bounds.size.height){
                scrollView.contentOffset.x = CGFloat(parkNumber) * scrollView.bounds.size.width
                scrollView.contentSize.width = scrollView.bounds.size.width
            }else{
                scrollView.contentSize.width = scrollView.bounds.size.width * CGFloat(parkModel.numParks)
                //scrollView.contentOffset.x = CGFloat(parkNumber) * scrollView.bounds.size.width
            }
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //TODO: make sure user didn't hold it in place
        print("didDecelerate")
        if scrollView == parksScrollView {
            parkNumber = Int(scrollView.contentOffset.x / scrollView.bounds.width)
            scrollView.contentSize.height = CGFloat(parkModel.parkCount(index: parkNumber)) * scrollView.bounds.height
            currentParkImage = Int(scrollView.contentOffset.y/scrollView.bounds.height)
            print("\(parkNumber), \(scrollView.contentSize.height) = \(scrollView.bounds.height) * \(CGFloat(parkModel.parkCount(index: parkNumber)))")
        }
    }
}

