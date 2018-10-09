//
//  ParkImageViewController.swift
//  PA Parks
//
//  Created by Pranav Jain on 10/2/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit

protocol ParkImageDelegate : class {
    func dismissMe()
}

class ParkImageViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var parkImageView: UIImageView!
    
    weak var delegate : ParkImageDelegate?
    
    var parkImage : UIImage?
    var parkTitle : String?
    var imageIndex : Int?
    var completionBlock : (() -> Void)?
    
    let minZoomScale: CGFloat = 1.0
    let maxZoomScale: CGFloat = 5.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.backgroundColor?.withAlphaComponent(0.7)
        //self.view.isOpaque = false
        //self.view.alpha = 0.7
        parkImageView.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
        imageScrollView.minimumZoomScale = minZoomScale
        imageScrollView.maximumZoomScale = maxZoomScale
        imageScrollView.delegate = self
        self.title = parkTitle
        
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
    }
    
    //MARK: - Auto Layout
    override func viewDidLayoutSubviews() {
        //setup image in container
        parkImageView.image = parkImage
        parkImageView.contentMode = .scaleAspectFit
        parkImageView.backgroundColor = UIColor.clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(ParkImageViewController.dismissByCompletionBlock(_:)))
        parkImageView.addGestureRecognizer(tap)
        
        //self.navigationController?.isNavigationBarHidden = true
        //self.tabBarController?.tabBar.isHidden = true
    }
    
    //from Dr. Hannan's Squares App
    func configure(with image:UIImage?, title:String) {
        self.parkImage = image
        self.parkTitle = title
    }
    
    @objc func dismissByCompletionBlock(_ sender: Any) {
        if imageScrollView.zoomScale == 1.0 {
            if let completionBlock = completionBlock {
                completionBlock()
            }
        }
    }
    
    @objc func dismissByDelegate(_ sender: Any) {
        delegate?.dismissMe()
    }
    
    
    //MARK: - ScrollView Delegate Methods
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        //find imageView needed to scale
        return parkImageView
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
