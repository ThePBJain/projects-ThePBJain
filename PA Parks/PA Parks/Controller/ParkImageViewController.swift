//
//  ParkImageViewController.swift
//  PA Parks
//
//  Created by Pranav Jain on 10/2/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit

class ParkImageViewController: UIViewController, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    
    @IBOutlet weak var imageScrollView: UIScrollView!
    @IBOutlet weak var parkImageView: UIImageView!
    
    var parkImage : UIImage?
    var completionBlock : (() -> Void)?
    
    let minZoomScale: CGFloat = 1.0
    let maxZoomScale: CGFloat = 5.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.7)
        //self.view.backgroundColor?.withAlphaComponent(0.7)
        //self.view.isOpaque = false
        //self.view.alpha = 0.7
        parkImageView.backgroundColor = .clear
        parkImageView.isUserInteractionEnabled = true
        imageScrollView.backgroundColor = .clear
        imageScrollView.isOpaque = false
        // Do any additional setup after loading the view.
        imageScrollView.minimumZoomScale = minZoomScale
        imageScrollView.maximumZoomScale = maxZoomScale
        imageScrollView.delegate = self
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
    func configure(with image:UIImage?) {
        self.parkImage = image
    }
    
    @objc func dismissByCompletionBlock(_ sender: Any) {
        if imageScrollView.zoomScale == 1.0 {
            if let completionBlock = completionBlock {
                completionBlock()
            }
        }
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
