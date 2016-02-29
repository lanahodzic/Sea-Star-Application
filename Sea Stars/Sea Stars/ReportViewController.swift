//
//  ReportViewController.swift
//  Sea Stars
//
//  Created by Carson Carroll on 11/17/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

class ReportViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    let ref = Firebase(url:"https://sea-stars2.firebaseio.com")

    @IBOutlet weak var reportTextView: UITextView!
    @IBOutlet weak var seaStarImage: UIImageView!
    @IBOutlet weak var exportButton: UIBarButtonItem!
    
    var report:[String:AnyObject] = [String:AnyObject]()
    var speciesInfo:[String:AnyObject] = [String:AnyObject]()
    
    var piling:Int?
    var rotation:Int?
    var depth:Int?
    var speciesCount:Int?
    
    var health:String?
    var notes:String?
    var observer:String?
    var site:String?
    var date:String?
    
    var species:String?
    var phylum:String?
    var groupName:String?
    var isMobile:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let exportToCSVButton = UIBarButtonItem(title: "Export", style: .Plain, target: self, action: "exportReportToCSV")
        navigationItem.rightBarButtonItem = exportToCSVButton
    
        reportTextView.text = "Observer: \(report["observer"] as! String)\n"
        reportTextView.text = reportTextView.text + "Site: \(report["site"] as! String)\n"
        reportTextView.text = reportTextView.text + "Date: \(report["date"] as! String)\n\n\n\n"
        
        self.observer = report["observer"] as? String
        self.site = report["site"] as? String
        self.date = report["date"] as? String

        
        for reportItem in report["reportItems"] as! [[String:AnyObject]] {
            let speciesRef = ref.childByAppendingPath("species")
            speciesRef.queryOrderedByChild("name").queryEqualToValue("\(reportItem["speciesID"] as! String)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if snapshot.childrenCount == 1 {
                    for child in snapshot.children.allObjects as! [FDataSnapshot] {
                        // make properties and assign these values that
                        self.reportTextView.text = self.reportTextView.text + "Piling: \(reportItem["piling"] as! Int)   Depth: \(reportItem["depth"] as! Int)   Rotation: \(reportItem["rotation"] as! Int)\n\n"
                        
                        self.piling = reportItem["piling"] as? Int
                        self.depth = reportItem["depth"] as? Int
                        self.rotation = reportItem["rortation"] as? Int
                        
                        self.species = child.value["name"] as? String
                        self.phylum = child.value["phylum"] as? String
                        self.groupName = child.value["groupName"] as? String
                        if child.value["isMobile"] as! Bool {
                            self.isMobile = "Yes"
                        }
                        else {
                            self.isMobile = "No"
                        }
                        self.reportTextView.text = self.reportTextView.text + "Group Name: \(self.groupName!)\nSpecies: \(self.species!)\nPhylum: \(self.phylum!)\nisMobile: \(self.isMobile!)\n"
                        self.reportTextView.text = self.reportTextView.text + "Count: \(reportItem["count"] as! Int)\n"
                        self.reportTextView.text = self.reportTextView.text + "Health: \(reportItem["health"] as! String)\n"
                        self.reportTextView.text = self.reportTextView.text + "Notes: \(reportItem["notes"] as! String)\n\n"
                        self.reportTextView.text = self.reportTextView.text + "---------------------------------------\n\n"
                        
                    }
                }
                else {
                    print("Query returned too many objects.")
                }
            })
        }
    }

    // MARK: Export
    
    func exportReportToCSV() {
        print("user requested .csv export")
        print(self.reportTextView.text)
        
        let dataString: NSMutableString = ""
        
        for (kind, _) in report {
            if(kind != "reportItems") {
                var value = String(kind)
                value.replaceRange(value.startIndex...value.startIndex, with: String(value[value.startIndex]).capitalizedString)
                dataString.appendString(value + ",")
            }
        }
        
        for reportItem in report["reportItems"] as! [[String: AnyObject]] {
            for (kind, _) in reportItem {
                var value = String(kind)
                value.replaceRange(value.startIndex...value.startIndex, with: String(value[value.startIndex]).capitalizedString)
                dataString.appendString(value + ",")
            }
            
            if reportItem.count > 1 {
                dataString.appendString("\n")
                break
            }
        }
        
        // current reporter
        for reportItem in report["reportItems"] as! [[String: AnyObject]] {
            dataString.appendString(self.observer! + "," + self.site! + "," + self.date! + ",")
            
            for (kind, val) in reportItem {
                if kind == "health" || kind == "notes" {
                    dataString.appendString("\"" + String(val) + "\"" + ",")
                } else {
                    dataString.appendString(String(val) + ",")
                }
                
            }
            
            dataString.appendString("\n")
        }

        print(dataString.description)
        
        // Setup data for mail attachment
        let data = dataString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        
        let emailViewController = configuredMailComposeViewController(data!)
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(emailViewController, animated: true, completion: nil)
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
