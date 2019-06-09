//
//  iBeaconTableViewController.swift
//  iBeacon Tracker
//
//  Created by Joe Chen on 2019/6/6.
//  Copyright © 2019 Joe Chen. All rights reserved.
//

import UIKit
import CoreData


protocol FetchTextDelegate {
    
    func fetchText(_ text: String)
    
}

class iBeaconCell: UITableViewCell {
    
    @IBOutlet weak var uuidText: UILabel!
    
    @IBOutlet weak var nameText: UILabel!
    @IBOutlet weak var visualView: UIVisualEffectView!
    
}

class iBeaconTableViewController: UITableViewController {

    let moc = RecordContext.shared()
    var ibeaconDBinfo = [UUIDRecord]()
    var delegate : FetchTextDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .light))
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UUIDRecord")
        request.sortDescriptors = [NSSortDescriptor(key: "index", ascending: false)]
        
        do{
            self.ibeaconDBinfo = try moc.fetch(request) as! [UUIDRecord]
        }catch{
            fatalError("\(error)")
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.ibeaconDBinfo.count
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "infoCell", for: indexPath) as! iBeaconCell

        // Configure the cell...
        let info : UUIDRecord = self.ibeaconDBinfo[indexPath.row]
        cell.nameText.text = info.name
        cell.uuidText.text = info.uuid

        return cell
    }
 

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item : UUIDRecord = self.ibeaconDBinfo[indexPath.row]
        self.delegate?.fetchText(item.uuid!)
        
        self.dismiss(animated: true, completion: nil)
        
        
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "UUIDRecord")
            request.predicate = NSPredicate(format: "index == %@", argumentArray: [self.ibeaconDBinfo[indexPath.row]])
            do {
                let deleteItem =  try moc.fetch(request) as! [UUIDRecord]
                for item in deleteItem {
                    moc.delete(item)
                }
                self.ibeaconDBinfo.remove(at: indexPath.row)
                try moc.save()
                
            } catch {
                fatalError("\(error)")
                
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            
        }
    }
 

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
