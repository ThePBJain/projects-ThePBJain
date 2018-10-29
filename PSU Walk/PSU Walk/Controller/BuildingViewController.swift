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

protocol BuildingTableViewDelegate : class {
    func dismissMe()
    func dismissMe(with indexPath:IndexPath)
    func addDirectionPins(withSource indexPathSource:IndexPath, withDestination indexPathDest:IndexPath)
    var view: UIView! {get set}
}

class BuildingViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UISearchResultsUpdating {
    
    
    weak var delegate : BuildingTableViewDelegate?
    
    
    let walkModel = WalkModel.sharedInstance
    let cellHeight : CGFloat = 100.0
    let searchController = UISearchController(searchResultsController: nil)
    var isSearching : Bool {return searchController.isActive && !searchBarIsEmpty()}
    var selectedBuilding : Int?
    var filteredBuildings = [Building]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Buildings"
        searchController.searchBar.tintColor = .white
        navigationItem.searchController = searchController
        
        //Note: I have no idea why changing color of searchbar text is so difficult!!!
        //Found solution here: https://stackoverflow.com/questions/28499701/how-can-i-change-the-uisearchbar-search-text-color
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        definesPresentationContext = true
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if isSearching {
            return 1
        }
        return walkModel.numberOfInitials
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            //return walkModel.numBuildings(in: filteredBuildings, for: section)
            return filteredBuildings.count
        }
        return walkModel.numberOfValuesForKey(atIndex: section)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isSearching {
            return nil
        }
        return walkModel.buildingIndexTitles[section]
    }
    override  func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if isSearching {
            return nil
        }
        return walkModel.buildingIndexTitles
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! BuildingViewCell
        
        if isSearching {
            cell.name.text = filteredBuildings[indexPath.row].name
            cell.code.text = "\(filteredBuildings[indexPath.row].opp_bldg_code)"
            cell.year.text = "\(filteredBuildings[indexPath.row].year_constructed)"
            cell.indexPath = walkModel.indexPath(of: filteredBuildings[indexPath.row])
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BuildingViewController.dismissByDelegate(_:)))
            cell.addGestureRecognizer(tapGesture)
            return cell
        }
        // Configure the cell...
        cell.name.text = walkModel.buildingName(at: indexPath)
        cell.code.text = "\(walkModel.buildingCode(at: indexPath) ?? 0)"
        cell.year.text = "\(walkModel.buildingYear(at: indexPath) ?? 0)"
        cell.indexPath = indexPath
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BuildingViewController.dismissByDelegate(_:)))
        cell.addGestureRecognizer(tapGesture)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
        
    }
    
    //MARK: - TableView Cell Actions
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Favorite") { (action, indexPath) in
            // delete item at indexPath
            if self.walkModel.addToFavorites(with: indexPath) {
                //remove from tableviewrowactions
            }
        }
        delete.backgroundColor = UIColor.orange
        
        let navTo = UITableViewRowAction(style: .default, title: "Navigate To") { (action, indexPath) in
            // navTo item at indexPath
            //have it pull something up (Action sheet in main map view to choose NavigateFrom
            if self.isSearching {
                let _indexPath = self.walkModel.buildingIndexToIndexPath(at: indexPath.row)
                self.addAlert(title: "Navigate From", isSource: false, _indexPath: _indexPath)
            }else{
                self.addAlert(title: "Navigate From", isSource: false, _indexPath: indexPath)
            }
            
        }
        
        
        navTo.backgroundColor = UIColor.psuBlue
        
        return [delete, navTo]
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        /*let navFrom = UITableViewRowAction(style: .default, title: "Navigate Here") { (action, indexPath) in
         // navTo item at indexPath
         //have it pull something up (Action sheet in main map view to choose NavigateFrom
         print("RowAction")
         }*/
        
        let navFrom = UIContextualAction(style: .normal, title:  "Navigate From", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            if self.isSearching {
                let _indexPath = self.walkModel.buildingIndexToIndexPath(at: indexPath.row)
                self.addAlert(title: "Navigate To", isSource: true, _indexPath: _indexPath )
            }else{
                self.addAlert(title: "Navigate To", isSource: true, _indexPath: indexPath )
            }
            
            success(true)
        })
        navFrom.backgroundColor = .purple
        
        return UISwipeActionsConfiguration(actions: [navFrom])
        
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
    
    // MARK: - Search bar methods
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredBuildings = walkModel.allBuildings.filter({( building : Building) -> Bool in
            return building.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    
    
    // MARK: - Picker View Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return walkModel.numberOfBuildings+1
    }
    
    
    // Return the title of each row in your picker ... In my case that will be the profile name or the username string
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "Current Location"
        }else{
            return walkModel.buildingName(at: row - 1)
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedBuilding = row - 1
    }
    
    func addAlert(title:String, isSource:Bool, _indexPath:IndexPath?){
        if let indexPath = _indexPath {
            // create the alert
            let message = "Choose where your starting/ending point will be."
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet);
            alert.isModalInPopover = true;
            
            let nextAction: UIAlertAction = UIAlertAction(title: "Choose", style: .default){action->Void in
                // check if passed in indexPath is source or not
                //TODO: index paths wont work with current location...
                if isSource && self.selectedBuilding != nil {
                    let sourceIndexPath = indexPath
                    let destinationIndexPath = self.walkModel.buildingIndexToIndexPath(at: self.selectedBuilding!)
                    if let destIndexPath = destinationIndexPath {
                        self.delegate?.addDirectionPins(withSource: sourceIndexPath, withDestination: destIndexPath)
                    }else{
                        //for current location
                        let destIndexPath = IndexPath(row: -1, section: -1)
                        self.delegate?.addDirectionPins(withSource: sourceIndexPath, withDestination: destIndexPath)
                    }
                    
                }else {
                    let sourceIndexPath = self.walkModel.buildingIndexToIndexPath(at: self.selectedBuilding!)
                    let destinationIndexPath = indexPath
                    
                    if let sourcePath = sourceIndexPath {
                        self.delegate?.addDirectionPins(withSource: sourcePath, withDestination: destinationIndexPath)
                    }else{
                        //for current location
                        let sourcePath = IndexPath(row: -1, section: -1)
                        self.delegate?.addDirectionPins(withSource: sourcePath, withDestination: destinationIndexPath)
                    }
                }
            }
            alert.addAction(nextAction)
            
            let containerViewWidth = alert.view.bounds.width
            let containerViewHeight = 120
            let containerFrame = CGRect(x:10, y: 70, width: CGFloat(containerViewWidth), height: CGFloat(containerViewHeight))
            let containerPicker : UIPickerView = UIPickerView(frame: containerFrame)
            containerPicker.delegate = self
            containerPicker.dataSource = self
            
            alert.view.addSubview(containerPicker)
            
            // Got constraints from online, really helped with making this look nice.
            let cons:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: containerPicker, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1.00, constant: 130)
            
            alert.view.addConstraint(cons)
            
            let cons2:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.greaterThanOrEqual, toItem: containerPicker, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1.00, constant: 20)
            
            alert.view.addConstraint(cons2)
            
            if let popoverPresentationController = alert.popoverPresentationController {
                popoverPresentationController.sourceView = delegate?.view
                let height = (delegate?.view.frame)!.height
                popoverPresentationController.sourceRect = CGRect(origin: CGPoint(x: 0, y: height), size: alert.view.frame.size)
                //alert
            }
            // present with our view controller
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}

