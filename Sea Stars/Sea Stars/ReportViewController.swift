//
//  ReportViewController.swift
//  Sea Stars
//
//  Created by Carson Carroll on 11/17/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit
import MessageUI

class ReportViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var reportTextView: UITextView!
    @IBOutlet weak var exportButton: UIBarButtonItem!
    
    var report:[String:AnyObject] = [String:AnyObject]()
    var allSpecies:[String:Species] = [String:Species]()
    
    var piling:Int?
    var direction:Int?
    var depth:Int?
    var speciesCount:Int?
    var benthos:String?
    var size:String?
    
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

        self.navigationItem.backBarButtonItem = movedBackButton()

        let exportToCSVButton = UIBarButtonItem(title: "Export                      ", style: .Plain, target: self, action: "exportReportToCSV")
        navigationItem.rightBarButtonItem = exportToCSVButton
    
        reportTextView.text = "Observer: \(report["observer"] as! String)\n"
        reportTextView.text = reportTextView.text + "Site: \(report["site"] as! String)\n"
        reportTextView.text = reportTextView.text + "Date: \(report["date"] as! String)\n\n\n\n"
        
        self.observer = report["observer"] as? String
        self.site = report["site"] as? String
        self.date = report["date"] as? String

        
        for reportItem in report["reportItems"] as! [[String:AnyObject]] {
            self.reportTextView.text = self.reportTextView.text + "Piling: \(reportItem["piling"] as! Int)   Depth: \(reportItem["depth"] as! Int)   Direction: \(reportItem["direction"] as! Int)\n\n"
            
            self.piling = reportItem["piling"] as? Int
            self.depth = reportItem["depth"] as? Int
            self.direction = reportItem["direction"] as? Int
            
            self.species = reportItem["species"] as? String
            self.phylum = reportItem["phylum"] as? String
            self.groupName = reportItem["groupName"] as? String
            self.isMobile = reportItem["mobility"] as? String
            
            self.speciesCount = reportItem["count"] as? Int
            self.notes = reportItem["notes"] as? String
            self.health = reportItem["health"] as? String
            self.benthos = reportItem["benthos"] as? String
            self.size = reportItem["size"] as? String
            
            self.reportTextView.text = self.reportTextView.text + "Group Name: \(self.groupName!)\n"
            self.reportTextView.text = self.reportTextView.text + "Species: \(self.species!)\n"
            self.reportTextView.text = self.reportTextView.text + "Phylum: \(self.phylum!)\n"
            self.reportTextView.text = self.reportTextView.text + "Mobility: \(self.isMobile!)\n"
            
            if let count = self.speciesCount {
                self.reportTextView.text = self.reportTextView.text + "Count: \(count)\n"
            }
            if let health = self.health {
                if health != "N/A" {
                    self.reportTextView.text = self.reportTextView.text + "Health: \(health)\n"
                }
            }
            if let benthos = self.benthos {
                if benthos != "N/A" {
                    self.reportTextView.text = self.reportTextView.text + "Benthos: \(benthos)\n"
                }
            }
            if let size = self.size {
                if size != "N/A" {
                    self.reportTextView.text = self.reportTextView.text + "Size: \(size)\n"
                }
            }
            if let notes = self.notes {
                self.reportTextView.text = self.reportTextView.text + "Notes: \(notes)\n"
            }
            
            self.reportTextView.text = self.reportTextView.text + "\n---------------------------------------\n\n"
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
        emailController.setCcRecipients(["lneedles@calpoly.edu"])
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
