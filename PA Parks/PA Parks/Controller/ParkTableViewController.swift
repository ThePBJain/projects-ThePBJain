//
//  ParkTableViewController.swift
//  PA Parks
//
//  Created by Pranav Jain on 10/1/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ParkCell"

class ParkTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate, ParkImageDelegate {
    
    let cellHeight : CGFloat = 95.0
    let parkModel = ParkModel.sharedInstance
    
    var collapsedHeaders : [Bool]!
    var openedImage : UIImageView?
    var openedIndex : IndexPath?
    var openedBounds: CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collapsedHeaders = Array(repeating: false, count: parkModel.numberOfParks)
        
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.sectionIndexColor = UIColor.darkTan
        tableView.sectionIndexBackgroundColor = UIColor.lightTan
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return parkModel.numberOfParks
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return parkModel.parkImageCount(index: section)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ParkTableViewCell

        // Configure the cell...
        cell.captionLabel.text = parkModel.parkImageCaption(at: indexPath)
        let imageName = parkModel.parkImageName(at: indexPath)
        let image = UIImage(named: imageName)
        cell.parkImageView.contentMode = .scaleAspectFit
        cell.parkImageView.image = image
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return parkModel.parkNames(index: section)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = UIColor.darkTan
            headerView.textLabel?.textColor = UIColor.lightTan
            headerView.tag = section
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ParkTableViewController.headerWasTouched(_:)))
            headerView.addGestureRecognizer(tapGesture)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !collapsedHeaders[indexPath.section]{
            return cellHeight
        }else{
            return 0
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Custom Methods
    
    @objc func headerWasTouched(_ sender: UITapGestureRecognizer){
        let header = sender.view as! UITableViewHeaderFooterView
        let section = header.tag
        collapsedHeaders[section] = !collapsedHeaders[section]
        tableView.reloadSections(IndexSet(arrayLiteral: section), with: .automatic)
        
    }
    
    //gotten from Move Views that Dr. Hannan made
    func moveView(_ view:UIView, toSuperview superView: UIView) {
        let newCenter = superView.convert(view.center, from: view.superview)
        view.center = newCenter
        superView.addSubview(view)
    }
    
    func convertBounds(_ bounds:CGRect, fromSubview subView: UIView) -> CGRect {
        let newOrigin = subView.convert(bounds.origin, to: self.view)
        let newBounds = CGRect(origin: newOrigin, size: bounds.size)
        return newBounds
    }
    
    
    //Disabled because it looks ugly
    func animateOpenImage(imageView: UIImageView, at indexPath : IndexPath){
        self.openedImage = imageView
        self.openedIndex = indexPath
        self.openedBounds = CGRect(origin: imageView.frame.origin, size: imageView.frame.size)
        moveView(imageView, toSuperview: self.view)
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            //create a transform matrix to apply to pieceView
            imageView.frame.size = self.view.bounds.size
            imageView.frame.origin = self.view.bounds.origin
        })
    }
    //Disabled because it looks ugly
    func animateCloseImage(imageView: UIImageView, at indexPath : IndexPath){
        let cell = tableView.cellForRow(at: indexPath)
        UIView.animate(withDuration: 0.5, animations: {
            imageView.frame = self.convertBounds(self.openedBounds!, fromSubview: cell!)
        }) { (finished: Bool) in
            self.moveView(imageView, toSuperview: cell!)
            self.openedImage = nil
            self.openedIndex = nil
            self.openedBounds = nil
        }
    }
    
    // MARK: - Park Image Delegate Methods
    //Disabled because it looks ugly
    func dismissMe() {
        self.dismiss(animated: true, completion: nil)
        tableView.deselectRow(at: self.openedIndex!, animated: true)
        animateCloseImage(imageView: self.openedImage!, at: self.openedIndex!)
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let indexPath = tableView.indexPathForSelectedRow!
        //Disabled because it looks ugly
        /*if let cell = sender as? ParkTableViewCell {
            animateOpenImage(imageView: cell.parkImageView, at: indexPath)
        }*/
        let parkImageViewController = segue.destination as! ParkImageViewController
        parkImageViewController.modalPresentationStyle = .overCurrentContext
        let selectedImage = UIImage(named: parkModel.parkImageName(at: indexPath))
        parkImageViewController.configure(with: selectedImage)
        parkImageViewController.delegate = self
        parkImageViewController.completionBlock = {
            self.dismiss(animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    

}
