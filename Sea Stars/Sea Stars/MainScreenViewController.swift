//
//  MainScreenViewController.swift
//  Sea Stars
//
//  Created by Carson Carroll on 11/8/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit
import Parse
import SystemConfiguration
import CoreData

class MainScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellSubtitleLabel: UILabel!
    
    @IBOutlet weak var pilingTextBox: UITextField!
    @IBOutlet weak var rotationTextBox: UITextField!
    @IBOutlet weak var depthTextBox: UITextField!
    
    @IBOutlet weak var imageButton1: UIButton!
    @IBOutlet weak var imageButton2: UIButton!
    @IBOutlet weak var imageButton3: UIButton!
    @IBOutlet weak var imageButton4: UIButton!
    @IBOutlet weak var imageButton5: UIButton!
    
    @IBOutlet weak var speciesLabel1: UILabel!
    @IBOutlet weak var speciesLabel2: UILabel!
    @IBOutlet weak var speciesLabel3: UILabel!
    @IBOutlet weak var speciesLabel4: UILabel!
    @IBOutlet weak var speciesLabel5: UILabel!
    
    var seaStarImages:[UIImage] = [UIImage]()
    var allSpecies:[String] = [String]()
    var species:[String] = [String]()
    var reports:[[String:AnyObject]] = [[String:AnyObject]]()

    var observer_name: String?
    var site_location: String?
    var report_date: String?
    
    var imageButtonCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addCreature")

        self.pilingTextBox.delegate = self
        self.rotationTextBox.delegate = self
        self.depthTextBox.delegate = self

        self.pilingTextBox.keyboardType = .NumberPad
        self.rotationTextBox.keyboardType = .NumberPad
        self.depthTextBox.keyboardType = .NumberPad
        
        let speciesQuery = PFQuery(className: "Species")
        speciesQuery.limit = 5
        speciesQuery.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    self.convertFirstElementToImage(object)
                    let speciesName:String = (object as PFObject)["name"] as! String
                    self.species.append(speciesName)
                    
                    switch (self.imageButtonCounter++) {
                        case 0:
                            self.speciesLabel1.text = self.species[0]
                        case 1:
                            self.speciesLabel2.text = self.species[1]
                        case 2:
                            self.speciesLabel3.text = self.species[2]
                        case 3:
                            self.speciesLabel4.text = self.species[3]
                        case 4:
                            self.speciesLabel5.text = self.species[4]
                        default:
                            break
                    }
                }
            }
            else {
                print("Error: \(error) \(error!.userInfo)")
            }
        }
        
        let allSpeciesQuery = PFQuery(className: "Species")
        allSpeciesQuery.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    let speciesName:String = (object as PFObject)["name"] as! String
                    self.allSpecies.append(speciesName)
                }
            }
            else {
                print("Error: \(error) \(error!.userInfo)")
            }
        }
    }

    override func viewWillAppear(animated: Bool) {
        pilingTextBox.text = ""
        rotationTextBox.text = ""
        depthTextBox.text = ""
        
        refreshTable()
    }
    
    func refreshTable() -> Void {
        reports.removeAll()
        
        let reportQuery = PFQuery(className: "Reports")
        reportQuery.whereKey("observer", equalTo: observer_name!)
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
                    
                    self.reports.append(dictionary)
                }
                self.tableView.reloadData()
            }
            else {
                print("Error: \(error) \(error!.userInfo)")
            }
        }
    }
    
    func convertFirstElementToImage(object:AnyObject) -> Void {
        let imagesArray:[PFFile] = (object as! PFObject)["images"] as! [PFFile]
        let imageFile:PFFile = imagesArray[0]
        
        do {
            let imageData = try imageFile.getData()
            let seaStarImage:UIImage = UIImage(data: imageData)!
            self.seaStarImages.append(seaStarImage)
            
            switch (self.imageButtonCounter) {
                case 0:
                    self.imageButton1.setBackgroundImage(self.seaStarImages[self.imageButtonCounter], forState: .Normal)
                case 1:
                    self.imageButton2.setBackgroundImage(self.seaStarImages[self.imageButtonCounter], forState: .Normal)
                case 2:
                    self.imageButton3.setBackgroundImage(self.seaStarImages[self.imageButtonCounter], forState: .Normal)
                case 3:
                    self.imageButton4.setBackgroundImage(self.seaStarImages[self.imageButtonCounter], forState: .Normal)
                case 4:
                    self.imageButton5.setBackgroundImage(self.seaStarImages[self.imageButtonCounter], forState: .Normal)
                default:
                    break
            }
        }
        catch {
            print(error)
        }
    }
    
    @IBAction func saveFinalReport(sender: AnyObject) {
        if Reachability.isConnectedToNetwork() {
            var site:String?
            var observer:String?
            var reportID:String?
            var speciesID:String?
            
            var reportDate:NSDate?
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
            let context = appDel.managedObjectContext
            
            let reportRequest = NSFetchRequest(entityName: "Reports")
            reportRequest.returnsObjectsAsFaults = false
            do {
                let reportResults = try context.executeFetchRequest(reportRequest) as! [NSManagedObject]
                if reportResults.count == 1 {
                    reportDate = reportResults[0].valueForKey("date") as? NSDate
                    site = reportResults[0].valueForKey("site") as? String
                    observer = reportResults[0].valueForKey("observer") as? String
                    
                    let reportQuery = PFQuery(className: "Reports")
                    reportQuery.whereKey("site", equalTo: site!)
                    reportQuery.whereKey("date", equalTo: reportDate!)
                    reportQuery.whereKey("observer", equalTo: observer!)
                    
                    do {
                        let results = try reportQuery.findObjects()
                        if results.count == 0 {
                            let saveReport = PFObject(className: "Reports")
                            saveReport["site"] = site!
                            saveReport["date"] = reportDate!
                            saveReport["observer"] = observer!
                            do {
                                try saveReport.save()
                            }
                            catch {
                                print("Could not save report to Parse")
                            }
                        }
                    }
                    catch {
                        
                    }
                }
                else {
                    print("Too many reports. There should only be one!")
                }
            }
            catch {
                print("No reports were found in core data")
            }
            
            let reportXSpeciesRequest = NSFetchRequest(entityName: "ReportXSpecies")
            reportXSpeciesRequest.returnsObjectsAsFaults = false
            do {
                let reportXSpeciesResults = try context.executeFetchRequest(reportXSpeciesRequest)
                
                for result in reportXSpeciesResults as! [NSManagedObject] {
                    let saveReportXSpecies = PFObject(className: "ReportXSpecies")
                    saveReportXSpecies["piling"] = result.valueForKey("piling") as! Int
                    saveReportXSpecies["rotation"] = result.valueForKey("rotation") as! Int
                    saveReportXSpecies["depth"] = result.valueForKey("depth") as! Int
                    saveReportXSpecies["count"] = result.valueForKey("count") as! Int
                    saveReportXSpecies["health"] = result.valueForKey("health") as! String
                    saveReportXSpecies["notes"] = result.valueForKey("notes") as! String
                    
                    let getReportIDQuery = PFQuery(className: "Reports")
                    getReportIDQuery.whereKey("site", equalTo: site!)
                    getReportIDQuery.whereKey("date", equalTo: reportDate!)
                    getReportIDQuery.whereKey("observer", equalTo: observer!)
                    
                    do {
                        var objects = try getReportIDQuery.findObjects()
    
                        if objects.count > 0 {
                            reportID = objects[0].objectId!
                        }
                    }
                    catch {
                        print("Error: \(error)")
                    }
                    
                    saveReportXSpecies["reportID"] = reportID
                    
                    let getSpeciesIDQuery = PFQuery(className: "Species")
                    getSpeciesIDQuery.whereKey("name", equalTo: result.valueForKey("species") as! String)
    
                    do {
                        var objects = try getSpeciesIDQuery.findObjects()
    
                        if objects.count > 0 {
                            speciesID = objects[0].objectId!
                        }
                    }
                    catch {
                        print("Error: \(error)")
                    }
                    
                    saveReportXSpecies["speciesID"] = speciesID
                    
                    saveReportXSpecies.saveInBackground()
                }
            }
            catch {
                print("No reportXSpecies were found in core data")
            }
            
            let reportDeleteRequest = NSBatchDeleteRequest(fetchRequest: reportRequest)
            let reportXSpeciesDeleteRequest = NSBatchDeleteRequest(fetchRequest: reportXSpeciesRequest)
            do {
                try context.executeRequest(reportDeleteRequest)
                try context.executeRequest(reportXSpeciesDeleteRequest)
            }
            catch {
                print("Error deleting all rows from entities")
            }
            
            refreshTable()
            
            showAlert("Success", message: "The report has been saved to the database!")
        }
        else {
            showAlert("Internet Connection", message: "You must be connected to a wifi network or have a cellular data connection to save a final report.")
        }
    }
    
    func addCreature() -> Void {
        if pilingTextBox.text! == "" || rotationTextBox.text! == "" || depthTextBox.text! == "" {
            showAlert("Missing Information", message: "Please make sure to enter a piling number, a rotation angle, and depth before proceeding.")
        }
        else {
            performSegueWithIdentifier("addCreatureSegue1", sender: self.navigationItem.rightBarButtonItem)
        }
    }
    
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
        alert.addAction(okayAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reportCell", forIndexPath: indexPath) as! ObserverReportTableViewCell
    
        cell.titleLabel.text = "\(reports[indexPath.row]["site"]!) \(reports[indexPath.row]["date"]!)"
        cell.subtitleLabel.text = "\(reports[indexPath.row]["observer"]!)"

        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(observer_name!)'s Reports"
    }
    

    // MARK: - Navigation
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier != "reportSegue" {
            if pilingTextBox.text! == "" || rotationTextBox.text! == "" || depthTextBox.text! == "" {
                showAlert("Missing Information", message: "Please make sure to enter a piling number, a rotation angle, and depth before proceeding.")
                
                return false
            }
            else {
                return true
            }
        }
        
        return true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "reportSegue" {
            let reportVC = segue.destinationViewController as! ReportViewController
            reportVC.report = reports[tableView.indexPathForSelectedRow!.row]
        }
        else {
            let addCreatureVC = segue.destinationViewController as! AddCreatureViewController
            
            if let _ = sender as? UIBarButtonItem? {
                addCreatureVC.selectedSpecies = ""
            }
            else {
                switch (NSArray(array:seaStarImages).indexOfObject(((sender as? UIButton)?.backgroundImageForState(.Normal))!)) {
                case 0:
                    addCreatureVC.selectedSpecies = species[0]
                case 1:
                    addCreatureVC.selectedSpecies = species[1]
                case 2:
                    addCreatureVC.selectedSpecies = species[2]
                case 3:
                    addCreatureVC.selectedSpecies = species[3]
                case 4:
                    addCreatureVC.selectedSpecies = species[4]
                default:
                    break
                }
            }
            
            if let p = Int(pilingTextBox.text!) {
                if let r = Int(rotationTextBox.text!) {
                    if let d = Int(depthTextBox.text!) {
                        addCreatureVC.piling = p
                        addCreatureVC.rotation = r
                        addCreatureVC.depth = d
                    }
                    else {
                        showAlert("Incorrect Format", message: "The depth must be an integer.")
                    }
                }
                else {
                    showAlert("Incorrect Format", message: "The rotation must be an integer.")
                }
            }
            else {
                showAlert("Incorrect Format", message: "The piling must be an integer.")
            }
            
            addCreatureVC.observer_name = observer_name
            addCreatureVC.report_date = report_date
            addCreatureVC.site_location = site_location
            addCreatureVC.speciesData = allSpecies
        }
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = NSCharacterSet(charactersInString: "0123456789.").invertedSet
        if let _ = string.rangeOfCharacterFromSet(invalidCharacters, options: [], range:Range<String.Index>(start: string.startIndex, end: string.endIndex)) {
            return false
        }

        return true
    }
}

public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}
