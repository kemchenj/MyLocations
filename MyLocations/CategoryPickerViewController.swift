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
    var selectedIndexPath = IndexPath()
    
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
        
        for i in 0 ..< categories.count {
            if categories[i] == selectedCategoryName {
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            }
        }
    }
}



// MARK: - Segue

extension CategoryPickerViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickedCategory" {
            let cell = sender as! UITableViewCell
            if let indexPath = tableView.indexPath(for: cell) {
                selectedCategoryName = categories[indexPath.row]
            }
        }
    }
}



// MARK: - Table View

extension CategoryPickerViewController {
    
    // MARK: - Data Source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let categoryName = categories[indexPath.row]
        cell.textLabel!.text = categoryName
        
        if categoryName == selectedCategoryName {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}



// MARK: - Segue

extension CategoryPickerViewController {
    
    
}
