//
//  MainScreenViewController.swift
//  Sea Stars
//
//  Created by Carson Carroll on 11/8/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit
import Firebase
import DZNEmptyDataSet
import SystemConfiguration
import AFNetworking
import CoreData

class MainScreenViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    let ref = Firebase(url:"https://sea-stars2.firebaseio.com")

    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var pilingTextBox: UITextField!
    @IBOutlet weak var rotationTextBox: UITextField!
    @IBOutlet weak var depthTextBox: UITextField!
    @IBOutlet weak var mobilitySegmentedControl: UISegmentedControl!

    @IBOutlet weak var speciesScrollView: UIScrollView!
    @IBOutlet weak var selectedSpeciesLabel: UILabel!

    @IBOutlet weak var saveButton: UIButton!
    
    var allSpecies:[Species] = [Species]()
    var speciesInTable:[Species] = [Species]()

    var observer_name: String?
    var site_location: String?
    var report_date: String?
    
    var selectedSpeciesType: String = ""
    var mobility = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.pilingTextBox.delegate = self
        self.rotationTextBox.delegate = self
        self.depthTextBox.delegate = self

        self.pilingTextBox.keyboardType = .NumberPad
        self.rotationTextBox.keyboardType = .NumberPad
        self.depthTextBox.keyboardType = .NumberPad
        
        let speciesRef = ref.childByAppendingPath("species")
        speciesRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            for child in snapshot.children.allObjects as! [FDataSnapshot] {
                let species = Species(fromSnapshot: child)
                self.allSpecies.append(species)
            }
            
            for species in self.allSpecies {
                if species.isMobile == self.mobility {
                    self.speciesInTable.append(species)
                }
            }
            
            self.refreshTable()
        })

        let scrollView = groupNameButtonsView(CGSizeMake(150.0,50.0), buttonCount: 10)
        speciesScrollView.addSubview(scrollView)
        speciesScrollView.showsHorizontalScrollIndicator = true
        speciesScrollView.indicatorStyle = .Default
        
        decorateSaveButton()
        
        // A little trick for removing the cell separators for the empty table view.
        tableView.tableFooterView = UIView()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.endEditing(true)
        
        refreshTable()
    }

    override func viewDidLayoutSubviews() {
        self.speciesScrollView.contentSize = self.speciesScrollView.subviews[0].frame.size
    }

    func refreshTable() -> Void {
        self.tableView.reloadData()
    }
    
    @IBAction func saveFinalReport(sender: AnyObject) {
        if Reachability.isConnectedToNetwork() {
            var site:String?
            var observer:String?
            var reportID:String?
            
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
                    
                    let reportsRef = ref.childByAppendingPath("reports")
                    let newReportRef = reportsRef.childByAutoId()
                    reportID = newReportRef.key
                    newReportRef.setValue(["site":site!, "date":reportDate!.timeIntervalSince1970, "observer":observer!])
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
                    let saveReportXSpecies = createReportXSpeciesJSON(result, reportID: reportID!)
                    let reportXSpeciesRef = ref.childByAppendingPath("reportXSpecies")
                    let newReportXSpeciesRef = reportXSpeciesRef.childByAutoId()
                    newReportXSpeciesRef.setValue(saveReportXSpecies)
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
            
            showSaveFinalReportAlert("Success", message: "The report has been saved to the database!")
        }
        else {
            showAlert("Internet Connection", message: "You must be connected to a wifi network or have a cellular data connection to save a final report.")
        }
    }
    
    func createReportXSpeciesJSON(object:NSManagedObject, reportID:String) -> [String:AnyObject] {
        return ["piling":object.valueForKey("piling") as! Int, "rotation":object.valueForKey("rotation") as! Int, "depth":object.valueForKey("depth") as! Int, "count":object.valueForKey("count") as! Int, "health":object.valueForKey("health") as! String, "notes":object.valueForKey("notes") as! String, "reportID":reportID, "speciesID":object.valueForKey("species") as! String]
    }
    
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
        alert.addAction(okayAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showSaveFinalReportAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: { (action) -> Void in
            let storyboard = UIStoryboard(name: "SeaStar", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("beginNav")
            self.presentViewController(vc, animated: true, completion: nil)
        })
        alert.addAction(okayAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return speciesInTable.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("speciesCell", forIndexPath: indexPath) as! ObserverReportTableViewCell
        
        let species = speciesInTable[indexPath.row]
        cell.titleLabel.text = species.name
        
        if let url = NSURL(string: species.imageURL) {
            if let placeholder = UIImage(named: "sea-star-black") {
                let urlRequest = NSURLRequest(URL: url)
                cell.seaStarImage.setImageWithURLRequest(urlRequest, placeholderImage: placeholder, success: {
                    (request: NSURLRequest, response: NSHTTPURLResponse?, image: UIImage) -> Void in
                    cell.seaStarImage.image = image
                    }, failure: {
                        (request: NSURLRequest, response: NSHTTPURLResponse?, error: NSError) -> Void in
                })
            }
        }

        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Species"
    }
    
    @IBAction func speciesMobilityChanged(sender: AnyObject) {
        if mobilitySegmentedControl.selectedSegmentIndex == 0 {
            mobility = true
        }
        else {
            mobility = false
        }
        
        speciesInTable.removeAll()
        
        if selectedSpeciesType == "" {
            for species in allSpecies {
                if species.isMobile == mobility {
                    speciesInTable.append(species)
                }
            }
        }
        else {
            findSpeciesForTableView()
        }
        
        self.speciesScrollView.subviews.forEach({ $0.removeFromSuperview() })
        
        let scrollView = groupNameButtonsView(CGSizeMake(150.0,50.0), buttonCount: 10)
        self.speciesScrollView.addSubview(scrollView)
        
        refreshTable()
    }

    func groupNameButtonsView(buttonSize:CGSize, buttonCount:Int) -> UIView {
        let titleArray = ["Sea Stars", "Crabs", "Anemones", "Bivalves", "Barnacles", "Bryozoans", "Sea Squirts", "Sea Cucumbers", "Chitons", "Sea Urchins"]
        
        let buttonView = UIView()
        buttonView.backgroundColor = UIColor.blackColor()
        buttonView.frame.origin = CGPointMake(0,0)

        let padding = CGSizeMake(10, 10)
        buttonView.frame.size.width = (buttonSize.width + padding.width) * CGFloat(buttonCount)
        buttonView.frame.size.height = (buttonSize.height +  2.0 * padding.height)

        var selectedButton: String? = nil

        var buttonPosition = CGPointMake(padding.width * 0.5, padding.height)
        let buttonIncrement = buttonSize.width + padding.width

        for i in 0...(buttonCount - 1)  {
            let button = UIButton(type: .Custom)
            button.frame.size = buttonSize
            button.frame.origin = buttonPosition
            buttonPosition.x = buttonPosition.x + buttonIncrement
            button.backgroundColor = UIColor(red: 2/255, green: 204/255, blue: 184/255, alpha: 1)
            button.setTitle(titleArray[i], forState: .Normal)
            button.addTarget(self, action: "groupNameButtonPressed:", forControlEvents: .TouchUpInside)
            buttonView.addSubview(button)

            if selectedButton == nil {
                selectedButton = button.titleLabel?.text
            }
        }

        return buttonView
    }

    func groupNameButtonPressed(sender: UIButton){
        self.selectedSpeciesType = (sender.titleLabel?.text)!
        selectedSpeciesLabel.text = self.selectedSpeciesType
        
        self.speciesInTable.removeAll()
        
        findSpeciesForTableView()
        
        self.refreshTable()
    }
    
    func findSpeciesForTableView() {
        for species in allSpecies {
            if species.groupName == selectedSpeciesType && species.isMobile == mobility {
                speciesInTable.append(species)
            }
        }
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
            
            addCreatureVC.selectedSpecies = self.speciesInTable[self.tableView.indexPathForSelectedRow!.row].name

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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }

    func decorateSaveButton() {
        let borderColor = UIColor(red: 2/255, green: 204/255, blue: 184/255, alpha: 1).CGColor
        saveButton.layer.borderWidth = 2
        saveButton.layer.borderColor = borderColor
        saveButton.layer.cornerRadius = 5
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
        return NSAttributedString(string: "Species", attributes: nil)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let message = "There is no species that matches the mobility and species type you selected."
        
        return NSAttributedString(string: message, attributes: nil)
    }
    
    func backgroundColorForEmptyDataSet(scrollView: UIScrollView!) -> UIColor! {
        return UIColor.whiteColor()
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
