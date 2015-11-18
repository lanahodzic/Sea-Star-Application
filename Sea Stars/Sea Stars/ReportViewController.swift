//
//  ReportViewController.swift
//  Sea Stars
//
//  Created by Carson Carroll on 11/17/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit
import Parse

class ReportViewController: UIViewController {

    @IBOutlet weak var reportTextView: UITextView!
    @IBOutlet weak var seaStarImage: UIImageView!
    
    var report:[String:AnyObject] = [String:AnyObject]()
    var piling:Int?
    var rotation:Int?
    var depth:Int?
    var species:String?
    var phylum:String?
    var groupName:String?
    var isMobile:String?
    var count:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reportTextView.text = "Observer: \(report["observer"]!)\n"
        reportTextView.text = reportTextView.text + "Site: \(report["site"]!)\n"
        reportTextView.text = reportTextView.text + "Date: \(report["date"]!)\n\n\n\n"
        
        for reportItem in report["reportItems"] as! [PFObject] {
            reportTextView.text = reportTextView.text + "Piling: \(reportItem["piling"]!)   Depth: \(reportItem["depth"]!)   Rotation: \(reportItem["rotation"]!)\n\n"
            
            let speciesQuery = PFQuery(className: "Species")
            speciesQuery.whereKey("objectId", equalTo: reportItem["speciesID"])
            do {
                let objects = try speciesQuery.findObjects()
                
                species = objects[0]["name"] as? String
                phylum = objects[0]["phylum"] as? String
                groupName = objects[0]["groupName"] as? String
                if objects[0]["isMobile"] as! Bool {
                    isMobile = "Yes"
                }
                else {
                    isMobile = "No"
                }
                phylum = objects[0]["phylum"] as? String
                
                reportTextView.text = reportTextView.text + "Group Name: \(groupName!)\nSpecies: \(species!)\nPhylum: \(phylum!)\nisMobile: \(isMobile!)\n"
            }
            catch {
                print("Error: \(error)")
            }
            
            reportTextView.text = reportTextView.text + "Count: \(reportItem["count"]!)\n"
            reportTextView.text = reportTextView.text + "Health: \(reportItem["health"]!)\n"
            reportTextView.text = reportTextView.text + "Notes: \(reportItem["notes"]!)\n\n"
            reportTextView.text = reportTextView.text + "---------------------------------------\n\n"
        }
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
