//
//  InitialScreenViewController.swift
//  Sea Stars
//
//  Created by Lana Hodzic on 11/11/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit
import Parse

class Report {
    var observer: String?
    var site: String?
    var species: [String]?
    var date: String?
}

class ReportTableViewCell: UITableViewCell {
    var report: Report? {
        didSet {
            if let new_report = report {
                reportDate.text = new_report.date!
                reportLocation.text = new_report.site!
                reportObserver.text = new_report.observer!
            }
        }
    }
    
    @IBOutlet weak var reportDate: UILabel!
    @IBOutlet weak var reportLocation: UILabel!
    @IBOutlet weak var reportObserver: UILabel!
}

class InitialScreenViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var latestReports: UITableView!
    var reports: [Report] = [Report]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.latestReports.dequeueReusableCellWithIdentifier("reportCell", forIndexPath: indexPath) as! ReportTableViewCell
        let report = reports[indexPath.row]
        
        cell.report = report
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
