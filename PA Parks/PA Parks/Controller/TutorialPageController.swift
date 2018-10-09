//
//  TutorialPageController.swift
//  PA Parks
//
//  Created by Pranav Jain on 10/8/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit

class TutorialPageController: UIViewController {
    
    
    @IBOutlet weak var tutorialImageView: UIImageView!
    
    
    var tutorialImage : UIImage?
    var imageIndex : Int?
    var completionBlock : (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    //MARK: - Auto Layout
    override func viewDidLayoutSubviews() {
        //setup image in container
        tutorialImageView.image = tutorialImage
        tutorialImageView.contentMode = .scaleAspectFit
        
    }
    
    func configure (with image:UIImage?, index:Int){
        self.tutorialImage = image;
        self.imageIndex = index;
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
