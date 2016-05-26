//
//  ShelfTableViewController.swift
//  BookList
//
//  Created by chino on 2016/05/26.
//  Copyright © 2016年 chino. All rights reserved.
//

import UIKit
import CoreData

class ShelfTableViewController: UITableViewController {
    
    var context: NSManagedObjectContext!    //メインとは別のコンテキスト
    var shelfs = [Shelf]()
    
    //フェッチリクエスト
    var fetchRequest: NSFetchRequest = {
        let request = NSFetchRequest(entityName: "Shelf")
        let sortDescriptor = NSSortDescriptor(key: "displayOrder", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        return request
    }()
    
    // MARK: - Core Data Private Method
    private func fetchShefs() {
        do {
            shelfs = try context.executeFetchRequest(fetchRequest) as! [Shelf]
        } catch let error as NSError {
            fatalError("\(error)")
        }
        
        let indexSet = NSIndexSet(index: 0)
        tableView.reloadSections(indexSet, withRowAnimation: .Fade)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchShefs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shelfs.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ShelfCell", forIndexPath: indexPath)

        let shelf = shelfs[indexPath.row]
        cell.textLabel?.text = shelf.name

        return cell
    }

    /*
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
