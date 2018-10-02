//
//  ParkCollectionViewController.swift
//  PA Parks
//
//  Created by Pranav Jain on 10/2/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ParkCollectionViewCell"

class ParkCollectionViewController: UICollectionViewController {

    let parkModel = ParkModel.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView?.backgroundColor = UIColor.lightTan
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if let cell = sender as? ParkCollectionViewCell {
            let parkImageViewController = segue.destination as! ParkImageViewController
            parkImageViewController.modalPresentationStyle = .overCurrentContext
            let indexPath = collectionView?.indexPath(for: cell)
            let selectedImage = UIImage(named: parkModel.parkImageName(at: indexPath ?? IndexPath(row: 0, section: 0)))
            parkImageViewController.configure(with: selectedImage)
            parkImageViewController.completionBlock = {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return parkModel.numberOfParks
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return parkModel.parkImageCount(index: section)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ParkCollectionViewCell
    
        // Configure the cell
        let imageName = parkModel.parkImageName(at: indexPath)
        let image = UIImage(named: imageName)
        cell.parkImageView.contentMode = .scaleAspectFit
        cell.parkImageView.image = image
        return cell
    }
    
    //layout taken from Dr. Hannan's US States app
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ParkHeader", for: indexPath) as! ParkCollectionReusableView
            headerView.backgroundColor = UIColor.darkTan
            headerView.ParkName.text = parkModel.parkNames(index: indexPath.section)
            headerView.ParkName.textColor = UIColor.lightTan
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
