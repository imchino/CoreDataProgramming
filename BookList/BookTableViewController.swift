//
//  BookTableViewController.swift
//  BookList
//
//  Created by chino on 2016/04/18.
//  Copyright © 2016年 chino. All rights reserved.
//

import UIKit
import CoreData

class BookTableViewController: UITableViewController {
    
    let coreDataStack = CoreDataStack() //CoreDataパッケージ
    var books = [Book]()                 //データソース

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 56.0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //新規ブック追加
    @IBAction func addBook(sender: UIBarButtonItem) {
    }
    
    //全書籍 <-> 欲しいものリスト
    @IBAction func segmentChanged(sender: UISegmentedControl) {
    }

    // MARK: - Table view data source
    //セクション数
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //セクション内の行数
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BookCell", forIndexPath: indexPath) as! BookTableViewCell

        let book = books[indexPath.row]
        cell.configureWithBook(book)

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
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
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
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

//セル
class BookTableViewCell: UITableViewCell {
    
    //セルの表示項目
    @IBOutlet weak var titleLabel:  UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var wishLabel:   UILabel!
    @IBOutlet weak var dateLabel:   UILabel!
    
    //日付形式を初期化
    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .MediumStyle
        return dateFormatter
    }()
    
    //セルの表示内容
    func configureWithBook(book: Book) {
        titleLabel.text = book.title
        authorLabel.text = book.author
        wishLabel.hidden = !(book.wish!.boolValue)
        dateLabel.text = dateFormatter.stringFromDate(book.registeredDate!)
    }
    
    
}
