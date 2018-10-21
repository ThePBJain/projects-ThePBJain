//
//  BuildingViewController.swift
//  PSU Walk
//
//  Created by Pranav Jain on 10/15/18.
//  Copyright © 2018 Pranav Jain. All rights reserved.
//

import UIKit
import MapKit

private let reuseIdentifier = "BuildingCell"

class FavoriteViewController: UITableViewController {
    
    
    weak var delegate : BuildingTableViewDelegate?
    
    
    let walkModel = WalkModel.sharedInstance
    let cellHeight : CGFloat = 100.0
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return walkModel.numberOfFavoriteInitials
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return walkModel.numberOfFavoritesForKey(atIndex: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return walkModel.favoriteIndexTitles[section]
    }
    override  func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return walkModel.favoriteIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.tableView.beginUpdates()
            if walkModel.removeFromFavorites(with: indexPath) {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            //tableView.headerView(forSection: indexPath.section)?.textLabel
            //tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return nil
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! BuildingViewCell
        
        
        // Configure the cell...
        cell.name.text = walkModel.favoriteBuildingName(at: indexPath)
        cell.code.text = "\(walkModel.favoriteBuildingCode(at: indexPath))"
        cell.year.text = "\(walkModel.favoriteBuildingYear(at: indexPath))"
        cell.indexPath = indexPath
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FavoriteViewController.dismissByDelegate(_:)))
        cell.addGestureRecognizer(tapGesture)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
        
    }
    
    
    @IBAction func doneWithView(_ sender: Any) {
        delegate?.dismissMe()
    }
    
    // MARK: - Navigation
    
    @objc func dismissByDelegate(_ sender: UITapGestureRecognizer) {
        if let cell = sender.view as? BuildingViewCell {
            if let indexPath = cell.indexPath {
                delegate?.dismissMe(with: indexPath)
            }
        }
    }
    
    
    /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
