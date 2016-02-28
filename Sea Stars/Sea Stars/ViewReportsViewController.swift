//
//  ViewReportsViewController.swift
//  Sea Stars
//
//  Created by Christopher Wu on 2/11/16.
//  Copyright © 2016 Cal Poly Marine Biology. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet
import MessageUI

class ReportTableViewCell: UITableViewCell {
    @IBOutlet weak var reportDate: UILabel!
    @IBOutlet weak var reportLocation: UILabel!
    @IBOutlet weak var reportObserver: UILabel!
}

class ViewReportsViewController: UITableViewController, MFMailComposeViewControllerDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    let ref = Firebase(url:"https://sea-stars2.firebaseio.com")

    @IBOutlet weak var exportToCSVButton: UIBarButtonItem!
    @IBOutlet weak var latestReports: UITableView!
    var reportDictionary:[[String:AnyObject]] = [[String:AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let exportToCSVButton = UIBarButtonItem(title: "Export", style: .Plain, target: self, action: "exportAllReports")
        navigationItem.rightBarButtonItem = exportToCSVButton
        
        latestReports.dataSource = self
        latestReports.delegate = self
        
        // A little trick for removing the cell separators for the empty table view.
        latestReports.tableFooterView = UIView()
        
        latestReports.emptyDataSetDelegate = self
        latestReports.emptyDataSetSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view.
        
        reportDictionary.removeAll()
        
        let reportsRef = ref.childByAppendingPath("reports")
        reportsRef.queryOrderedByChild("date").observeSingleEventOfType(.Value, withBlock: {(reportSnapshot) in
            for child in reportSnapshot.children.allObjects as! [FDataSnapshot] {
                let reportXSpeciesRef = self.ref.childByAppendingPath("reportXSpecies")
                reportXSpeciesRef.queryOrderedByChild("reportID").queryEqualToValue(child.key/*, childKey: "reportID"*/).observeSingleEventOfType(.Value, withBlock: {(reportXSpeciesSnapshot) in
                    var dictionary = [String:AnyObject]()
                    dictionary["observer"] = child.value["observer"] as! String
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    dictionary["date"] = dateFormatter.stringFromDate(NSDate(timeIntervalSince1970: child.value["date"] as! Double))
                    dictionary["site"] = child.value["site"] as! String
                    var reportItemsArray:[[String:AnyObject]] = []
                    for children in reportXSpeciesSnapshot.children.allObjects as! [FDataSnapshot] {
                        var reportItemsDictionary = [String:AnyObject]()
                        reportItemsDictionary["piling"] = children.value["piling"] as! Int
                        reportItemsDictionary["depth"] = children.value["depth"] as! Int
                        reportItemsDictionary["rotation"] = children.value["rotation"] as! Int
                        reportItemsDictionary["speciesID"] = children.value["speciesID"] as! String
                        reportItemsDictionary["count"] = children.value["count"] as! Int
                        reportItemsDictionary["health"] = children.value["health"] as! String
                        reportItemsDictionary["notes"] = children.value["notes"] as! String
                        reportItemsArray.append(reportItemsDictionary)
                    }
                    dictionary["reportItems"] = reportItemsArray
                    self.reportDictionary.append(dictionary)
                    self.latestReports.reloadData()
                })
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportDictionary.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Recent Reports"
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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

    // MARK: Exporting
    
    func exportAllReports() {
        if(reportDictionary.isEmpty) {
            let alert = UIAlertController(title: "Export", message: "There are no reports in the database to export.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        } else {
            print("user requested .csv export")
            
            let dataString: NSMutableString = ""
            let dataArr: NSMutableArray = []
            let currentReporter: NSMutableArray = []
            var currentReportNumber = 0
            
            // Get initial keys, "observer,site,date"
            for value in reportDictionary[0] {
                print(value)
                if value.0 == "reportItems" {
                    continue
                }
                dataArr.addObject(value.0)
            }
            
            // get keys from reportitems, count,depth,...,speciesID
            for reportItem in reportDictionary[0]["reportItems"] as! [[String : AnyObject]] {
                for (key, _) in reportItem { // god fucking damnit, get the keys
                    if dataArr.containsObject(key) {
                        continue
                    }
                    dataArr.addObject(key)
                }
            }
            
            // Make the first character of each string of header in the .csv to uppercase, prettier
            for val in dataArr {
                var value: String = String(val)
                
                value.replaceRange(value.startIndex...value.startIndex, with: String(value[value.startIndex]).capitalizedString)
                dataString.appendString(value + ",")
            }
            
            dataString.appendString("\n")
            
            // Start iterating through the reports and build the mutablestring, ie to be .csv
            for i in 0..<reportDictionary.count {
                for value in reportDictionary[i] {
                    if value.0 == "reportItems" {
                        continue
                    }
                    
                    currentReporter.addObject(value.1)
                    dataString.appendString(String(value.1) + ",")
                }
                
                // Grab data from the current report
                for reportItem in reportDictionary[i]["reportItems"] as! [[String : AnyObject]] {
                    ++currentReportNumber
                    for (_, val) in reportItem {
                        dataString.appendString(String(val) + ",")
                    }
                    dataString.appendString("\n")
                    
                    // Handle multiple reportitems logic
                    if reportDictionary[i]["reportItems"]?.count > 1 && reportDictionary[i]["reportItems"]?.count != (currentReportNumber - 1) {
                        for val in currentReporter {
                            dataString.appendString(String(val) + ",")
                        }
                        ++currentReportNumber
                    }
                }
                // Get ready for the next report
                currentReporter.removeAllObjects()
                currentReportNumber = 0
            }
            
            // Setup data for mail attachment
            let data = dataString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
            let emailViewController = configuredMailComposeViewController(data!)
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(emailViewController, animated: true, completion: nil)
            }
            
        }
    }
    
    // MARK: Share, TODO?
    @IBAction func shareDoc(sender: AnyObject) {
        print("test share file")
        
     //   docController.UTI = "public.comma-separated-values-text"
       // docController.delegate = self//delegate
      //  docController.name = "Export Data"
      //  docController.presentOptionsMenuFromBarButtonItem(sender as! UIBarButtonItem, animated: true)
        
        //}
    }
    
    // MARK: Mail
    func configuredMailComposeViewController(data: NSData) -> MFMailComposeViewController {
        let emailController = MFMailComposeViewController()
        emailController.mailComposeDelegate = self
        emailController.setSubject("CSV File of Report")
        emailController.setMessageBody("Here are the reports, they should be attached!", isHTML: false)
        
        // Attaching the .CSV file to the email.
        emailController.addAttachmentData(data, mimeType: "text/csv", fileName: "Reports.csv")

        return emailController
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            print("Mail cancelled")
        case MFMailComposeResultSaved.rawValue:
            print("Mail saved")
        case MFMailComposeResultSent.rawValue:
            print("Mail sent")
        case MFMailComposeResultFailed.rawValue:
            print("Mail sent failure: \(error!.localizedDescription)")
        default:
            break
        }
        
        controller.dismissViewControllerAnimated(true, completion: nil)
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
    
    // DZNEmptyDataSetDataSource.
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "sea-star-black")
    }
    
    func imageAnimationForEmptyDataSet(scrollView: UIScrollView!) -> CAAnimation! {
        let animation = CABasicAnimation(keyPath: "transform")
        
        animation.fromValue = NSValue(CATransform3D: CATransform3DMakeRotation(CGFloat(M_PI_2), 0.0, 0.0, 1.0))
        animation.duration = 0.25;
        animation.cumulative = true;
        animation.repeatCount = MAXFLOAT;
        
        return animation
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "Reports", attributes: nil)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let message = "There are no reports to view."
        
        return NSAttributedString(string: message, attributes: nil)
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.whiteColor()
    }
}