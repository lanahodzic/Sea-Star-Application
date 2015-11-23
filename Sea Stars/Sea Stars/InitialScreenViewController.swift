//
//  InitialScreenViewController.swift
//  Sea Stars
//
//  Created by Lana Hodzic on 11/11/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit
import Parse

class ReportTableViewCell: UITableViewCell {
    @IBOutlet weak var reportDate: UILabel!
    @IBOutlet weak var reportLocation: UILabel!
    @IBOutlet weak var reportObserver: UILabel!
}

class InitialScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var latestReports: UITableView!
    var reportDictionary:[[String:AnyObject]] = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view.
        
        latestReports.dataSource = self
        latestReports.delegate = self
        
        reportDictionary.removeAll()
        
        let reportQuery = PFQuery(className: "Reports")
        reportQuery.orderByDescending("date")
        reportQuery.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                for object in objects! as [PFObject] {
                    var dictionary = [String:AnyObject]()
                    dictionary["observer"] = object["observer"] as? String
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    dictionary["date"] = dateFormatter.stringFromDate((object["date"] as? NSDate)!)
                    dictionary["site"] = object["site"] as? String
                    
                    let reportXSpeciesQuery = PFQuery(className: "ReportXSpecies")
                    reportXSpeciesQuery.whereKey("reportID", equalTo: object.objectId!)
                    reportXSpeciesQuery.orderByAscending("piling")
                    reportXSpeciesQuery.addAscendingOrder("depth")
                    reportXSpeciesQuery.addAscendingOrder("rotation")
                    
                    do {
                        dictionary["reportItems"] = try reportXSpeciesQuery.findObjects()
                        
                    }
                    catch {
                        print("Error: \(error)")
                    }
                    
                    self.reportDictionary.append(dictionary)
                }
                
                self.latestReports.reloadData()
            }
            else {
                print("Error: \(error) \(error!.userInfo)")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportDictionary.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.latestReports.dequeueReusableCellWithIdentifier("reportCell", forIndexPath: indexPath) as! ReportTableViewCell
        print("\(cell) \n")
        print("\(indexPath.row) \n")
        let report = reportDictionary[indexPath.row]
        print("\(report) \n")
        
        cell.reportLocation.text = (report["site"] as! String)
        cell.reportDate.text = (report["date"] as! String)
        cell.reportObserver.text = (report["observer"] as! String)
        /*
        //set the cell info to the report info
        if let site = report.site {
            cell.site = site
        }
        
        if let observer = report.observer {
            cell.observer = observer
        }
        
        if let date = report.date {
            cell.date = date
        }*/
        
        return cell
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if  segue.identifier == "reportview" {
            let reportVC = segue.destinationViewController as! ReportViewController
            reportVC.report = reportDictionary[latestReports.indexPathForSelectedRow!.row]
        }
    }
    

}
