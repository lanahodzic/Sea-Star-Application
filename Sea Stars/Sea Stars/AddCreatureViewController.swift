//
//  AddCreatureViewController.swift
//  Sea Stars
//
//  Created by Carson Carroll on 11/8/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit
import Parse

class AddCreatureViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var speciesPicker: UIPickerView!
    @IBOutlet weak var countTextBox: UITextField!
    @IBOutlet weak var healthTextBox: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    var speciesData:[String] = [String]()
    var selectedSpecies:String = ""
    var observer_name: String?
    var site_location: String?
    var report_date: String?
    var piling:Int?
    var rotation:Int?
    var depth:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        speciesPicker.dataSource = self
        speciesPicker.delegate = self
        
        let speciesQuery = PFQuery(className: "Species")
        speciesQuery.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    let speciesName:String = (object as PFObject)["name"] as! String
                    self.speciesData.append(speciesName)
                }
                
                self.speciesPicker.reloadAllComponents()
                
                if self.selectedSpecies != "" {
                    self.speciesPicker.selectRow(self.speciesData.indexOf(self.selectedSpecies)!, inComponent: 0, animated: true)
                }
            }
            else {
                print("Error: \(error) \(error!.userInfo)")
            }
        }
    }
    
    @IBAction func save(sender: AnyObject) {
        let saveReport = PFObject(className: "Reports")
        let saveReportXSpecies = PFObject(className: "ReportXSpecies")
        var reportDate:NSDate?
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        reportDate = dateFormatter.dateFromString(report_date!)
        var reportID = ""
        var speciesID = ""
        
        let getReportIDQuery = PFQuery(className: "Reports")
        getReportIDQuery.whereKey("site", equalTo: site_location!)
        getReportIDQuery.whereKey("date", equalTo: reportDate!)
        getReportIDQuery.whereKey("observer", equalTo: observer_name!)
        
        do {
            var objects = try getReportIDQuery.findObjects()
            
            if objects.count > 0 {
                reportID = objects[0].objectId!
            }
            else {
                saveReport["site"] = site_location
                saveReport["date"] = reportDate
                saveReport["observer"] = observer_name
                
                do {
                    try saveReport.save()
                    var objects = try getReportIDQuery.findObjects()
                    if objects.count > 0 {
                        reportID = objects[0].objectId!
                    }
                }
                catch {
                    print("Error: \(error)")
                }
            }
        }
        catch {
            print("Error: \(error)")
        }
        
        let getSpeciesIDQuery = PFQuery(className: "Species")
        getSpeciesIDQuery.whereKey("name", equalTo: selectedSpecies)
        
        do {
            var objects = try getSpeciesIDQuery.findObjects()
            
            if objects.count > 0 {
                speciesID = objects[0].objectId!
            }
        }
        catch {
            print("Error: \(error)")
        }
        
        saveReportXSpecies["piling"] = piling
        saveReportXSpecies["rotation"] = rotation
        saveReportXSpecies["depth"] = depth
        saveReportXSpecies["count"] = Int(countTextBox.text!)
        saveReportXSpecies["health"] = healthTextBox.text!
        saveReportXSpecies["notes"] = notesTextView.text
        saveReportXSpecies["reportID"] = reportID
        saveReportXSpecies["speciesID"] = speciesID
        
        do {
            try saveReportXSpecies.save()
        }
        catch {
            print("Error: \(error)")
        }
        
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return speciesData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return speciesData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedSpecies = speciesData[row]
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
