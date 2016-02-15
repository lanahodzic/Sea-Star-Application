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

    @IBOutlet weak var pilingTextBox: UITextField!
    @IBOutlet weak var rotationTextBox: UITextField!
    @IBOutlet weak var depthTextBox: UITextField!

    @IBOutlet weak var speciesScrollView: UIScrollView!

    var seaStarImages:[UIImage?] = [UIImage?]()
    var allSpecies:[String] = [String]()
    var species:[String] = [String]()

    var observer_name: String?
    var site_location: String?
    var report_date: String?
    
    var sessile: Bool = false
    var selectedSpeciesType: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pilingTextBox.delegate = self
        self.rotationTextBox.delegate = self
        self.depthTextBox.delegate = self

        self.pilingTextBox.keyboardType = .NumberPad
        self.rotationTextBox.keyboardType = .NumberPad
        self.depthTextBox.keyboardType = .NumberPad

        let allSpeciesQuery = PFQuery(className: "Species")
        allSpeciesQuery.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    self.convertFirstElementToImage(object)
                    let speciesName:String = (object as PFObject)["name"] as! String
                    self.allSpecies.append(speciesName)
                }

                self.refreshTable()
            }
            else {
                print("Error: \(error) \(error!.userInfo)")
            }
        }

        let scrollView = colorButtonsView(CGSizeMake(100.0,50.0), buttonCount: 10)
        speciesScrollView.addSubview(scrollView)
        speciesScrollView.showsHorizontalScrollIndicator = true
        speciesScrollView.indicatorStyle = .Default
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        pilingTextBox.text = ""
        rotationTextBox.text = ""
        depthTextBox.text = ""
        
        refreshTable()
    }

    override func viewDidLayoutSubviews() {
        self.speciesScrollView.contentSize = self.speciesScrollView.subviews[0].frame.size
    }

    func refreshTable() -> Void {
        self.tableView.reloadData()
    }
    
    func convertFirstElementToImage(object:AnyObject) -> Void {
        let imagesArray:[PFFile] = (object as! PFObject)["images"] as! [PFFile]
        if self.seaStarImages.count < 7 && imagesArray.count > 0 {
            let imageFile:PFFile = imagesArray[0]
            do {
                let imageData = try imageFile.getData()
                let seaStarImage:UIImage = UIImage(data: imageData)!
                self.seaStarImages.append(seaStarImage)
            }
            catch {
                print(error)
            }
        }
        else {
            self.seaStarImages.append(nil)
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
        return allSpecies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reportCell", forIndexPath: indexPath) as! ObserverReportTableViewCell
    
        cell.titleLabel.text = allSpecies[indexPath.row]
        if self.sessile {
            cell.seaStarImage.image = nil
        }
        else if let img = seaStarImages[indexPath.row] {
            cell.seaStarImage.image = img
        }
        else {
            cell.seaStarImage.image = nil
        }

        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Species"
    }

    @IBAction func speciesSwitch(switchState: UISwitch) {
        self.speciesScrollView.subviews.forEach({ $0.removeFromSuperview() })
        self.sessile = switchState.on

        let scrollView = colorButtonsView(CGSizeMake(100.0,50.0), buttonCount: 10)
        self.speciesScrollView.addSubview(scrollView)

        self.refreshTable()
    }


    func colorButtonsView(buttonSize:CGSize, buttonCount:Int) -> UIView {
        let buttonView = UIView()
        buttonView.backgroundColor = UIColor.blackColor()
        buttonView.frame.origin = CGPointMake(0,0)

        let padding = CGSizeMake(10, 10)
        buttonView.frame.size.width = (buttonSize.width + padding.width) * CGFloat(buttonCount)
        buttonView.frame.size.height = (buttonSize.height +  2.0 * padding.height)

        var selectedButton: String? = nil

        var buttonPosition = CGPointMake(padding.width * 0.5, padding.height)
        let buttonIncrement = buttonSize.width + padding.width
        let hueIncrement = 1.0 / CGFloat(buttonCount)
        var newHue = hueIncrement
        for i in 0...(buttonCount - 1)  {
            let button = UIButton(type: .Custom)
            button.frame.size = buttonSize
            button.frame.origin = buttonPosition
            buttonPosition.x = buttonPosition.x + buttonIncrement
            button.backgroundColor = UIColor(hue: newHue, saturation: 1.0, brightness: 1.0, alpha: 1.0)
            button.setTitle((self.sessile ? "Sessile " : "Mobile ") + String(i), forState: .Normal)
            newHue = newHue + hueIncrement
            button.addTarget(self, action: "colorButtonPressed:", forControlEvents: .TouchUpInside)
            buttonView.addSubview(button)

            if selectedButton == nil {
                selectedButton = button.titleLabel?.text
            }
        }

        let selectedButtonView = UILabel()
        selectedButtonView.tag = 1
        selectedButtonView.text = selectedButton
        selectedButtonView.frame.size.width = self.speciesScrollView.frame.size.width
        selectedButtonView.frame.size.height = 22
        selectedButtonView.frame.origin = CGPointMake(0, self.speciesScrollView.frame.height * 0.65)
        selectedButtonView.textAlignment = .Center
        buttonView.addSubview(selectedButtonView)

        return buttonView
    }

    func colorButtonPressed(sender: UIButton){
        self.speciesScrollView.backgroundColor = sender.backgroundColor
        self.speciesScrollView.subviews[0].subviews.forEach({
            if $0.tag == 1 {
                let view = $0 as! UILabel
                view.text = sender.titleLabel?.text
                self.selectedSpeciesType = view.text!
            }
        })
        self.refreshTable()
    }

    // MARK: - Navigation

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier != "viewReportsSegue" {
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
        
        if segue.identifier != "viewReportsSegue" {
            let addCreatureVC = segue.destinationViewController as! AddCreatureViewController
            
            addCreatureVC.selectedSpecies = self.allSpecies[self.tableView.indexPathForSelectedRow!.row]

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
