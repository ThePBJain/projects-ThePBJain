//
//  ParkTableViewController.swift
//  PA Parks
//
//  Created by Pranav Jain on 10/1/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ParkCell"

class ParkTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UIGestureRecognizerDelegate {
    
    let cellHeight : CGFloat = 95.0
    let parkModel = ParkModel.sharedInstance
    
    var collapsedHeaders : [Bool]!
    
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


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        let parkImageViewController = segue.destination as! ParkImageViewController
        parkImageViewController.modalPresentationStyle = .overCurrentContext
        let indexPath = tableView.indexPathForSelectedRow!
        let selectedImage = UIImage(named: parkModel.parkImageName(at: indexPath))
        parkImageViewController.configure(with: selectedImage)
        parkImageViewController.completionBlock = {
            self.dismiss(animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    

}
