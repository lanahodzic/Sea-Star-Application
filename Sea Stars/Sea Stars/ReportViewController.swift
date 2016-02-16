//
//  ReportViewController.swift
//  Sea Stars
//
//  Created by Carson Carroll on 11/17/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit
import Firebase

class ReportViewController: UIViewController {
    
    let ref = Firebase(url:"https://sea-stars2.firebaseio.com")

    @IBOutlet weak var reportTextView: UITextView!
    @IBOutlet weak var seaStarImage: UIImageView!
    
    var report:[String:AnyObject] = [String:AnyObject]()
    var speciesInfo:[String:AnyObject] = [String:AnyObject]()
    var piling:Int?
    var rotation:Int?
    var depth:Int?
    var species:String?
    var phylum:String?
    var groupName:String?
    var isMobile:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reportTextView.text = "Observer: \(report["observer"] as! String)\n"
        reportTextView.text = reportTextView.text + "Site: \(report["site"] as! String)\n"
        reportTextView.text = reportTextView.text + "Date: \(report["date"] as! String)\n\n\n\n"
        
        for reportItem in report["reportItems"] as! [[String:AnyObject]] {
            let speciesRef = ref.childByAppendingPath("species")
            speciesRef.queryOrderedByChild("name").queryEqualToValue("\(reportItem["speciesID"] as! String)").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if snapshot.childrenCount == 1 {
                    for child in snapshot.children.allObjects as! [FDataSnapshot] {
                        self.reportTextView.text = self.reportTextView.text + "Piling: \(reportItem["piling"] as! Int)   Depth: \(reportItem["depth"] as! Int)   Rotation: \(reportItem["rotation"] as! Int)\n\n"
                        
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
