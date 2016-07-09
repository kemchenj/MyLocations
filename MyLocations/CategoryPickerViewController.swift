//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by kemchenj on 6/19/16.
//  Copyright © 2016 kemchenj. All rights reserved.
//

import UIKit



class CategoryPickerViewController: UITableViewController {
    
    var selectedCategoryName = ""
    var selectedIndexPath = NSIndexPath()
    
    let categories = ["No Category",
                      "Apple Store",
                      "Bar", "Bookstore",
                      "Club",
                      "Grocery Store",
                      "Historic Building",
                      "House",
                      "Icecream Vendor",
                      "Landmark",
                      "Park"]
    
}



// MARK: - View

extension CategoryPickerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorColor = UIColor(white: 1, alpha: 0.2)
        tableView.indicatorStyle = .White
        
        for i in 0 ..< categories.count {
            if categories[i] == selectedCategoryName {
                selectedIndexPath = NSIndexPath(forItem: i, inSection: 0)
                break
            }
        }
    }
}



// MARK: - Segue

extension CategoryPickerViewController {

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPathForCell(cell) {
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }
}



// MARK: - Table View

extension CategoryPickerViewController {
    
    // MARK: - Data Source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        
        if categoryName == selectedCategoryName {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        
        return cell
    }
    
    
    // MARK: - Delegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row != selectedIndexPath.row {
            if let newCell = tableView.cellForRowAtIndexPath(indexPath) {
                newCell.accessoryType = .Checkmark
            }
            
            if let oldCell = tableView.cellForRowAtIndexPath(selectedIndexPath) {
                oldCell.accessoryType = .None
            }
            
            selectedIndexPath = indexPath
        }
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {

        cell.backgroundColor = UIColor.blackColor()

        if let textLabel = cell.textLabel {
            textLabel.textColor = UIColor.whiteColor()
            textLabel.highlightedTextColor = textLabel.textColor
        }

        let selectionView = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = UIColor(white: 1, alpha: 0.2)
        cell.selectedBackgroundView = selectionView
    }
}
