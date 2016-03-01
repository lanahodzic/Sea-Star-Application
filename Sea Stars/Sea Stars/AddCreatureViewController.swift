//
//  AddCreatureViewController.swift
//  Sea Stars
//
//  Created by Carson Carroll on 11/8/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit
import CoreData

class AddCreatureViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var healthTextBox: KSTokenView!
    @IBOutlet weak var speciesLabel: UILabel!
    @IBOutlet weak var countTextBox: UITextField!
//    @IBOutlet weak var healthTextBox: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    
    var healthData: [String] = ["Healthy: no symptons of disease", "Mild: few lesions, deflated appearance, extreme twisting of rays", "Severe: many lesions, arm loss, disintegration"]
    
    var selectedSpecies: String = ""
    var observer_name: String?
    var site_location: String?
    var report_date: String?
    var piling:Int?
    var rotation:Int?
    var depth:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.countTextBox.delegate = self
        self.countTextBox.keyboardType = .NumberPad

        self.speciesLabel.text = self.selectedSpecies
        
        self.healthTextBox.delegate = self
        self.healthTextBox.promptText = ""
        self.healthTextBox.backgroundColor = UIColor(red: 0.00784314, green: 0.8, blue: 0.721569, alpha: 0.202571)
        self.healthTextBox.maxTokenLimit = 1
        self.healthTextBox.style = .Squared
        self.healthTextBox.searchResultSize = CGSize(width: self.healthTextBox.frame.width, height: self.healthTextBox.frame.height * 3)
        self.healthTextBox.font = UIFont.systemFontOfSize(17)
        
        decorateSaveButton()
    }
    
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        })
        alert.addAction(okayAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        var reportDate:NSDate?
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        reportDate = dateFormatter.dateFromString(report_date!)
        
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext
        
        if countTextBox.text != "" && (healthTextBox.hasTokens() || !healthTextBox.text.isEmpty) {
            if let _ = Int(countTextBox.text!) {
                let reportRequest = NSFetchRequest(entityName: "Reports")
                reportRequest.returnsObjectsAsFaults = false
                let predicate = NSPredicate(format: "site = %@ AND date = %@ AND observer = %@", site_location!, reportDate!, observer_name!)
                reportRequest.predicate = predicate
                
                do {
                    let results = try context.executeFetchRequest(reportRequest)
                    
                    if results.count == 0 {
                        let newReport = NSEntityDescription.insertNewObjectForEntityForName("Reports", inManagedObjectContext: context)
                        newReport.setValue(site_location!, forKey: "site")
                        newReport.setValue(reportDate!, forKey: "date")
                        newReport.setValue(observer_name!, forKey: "observer")
                        do {
                            try context.save()
                        }
                        catch {
                            print("Error while saving report")
                        }
                    }
                }
                catch {
                    print("There was an error with the request!")
                }
                
                let newReportXSpecies = NSEntityDescription.insertNewObjectForEntityForName("ReportXSpecies", inManagedObjectContext: context)
                newReportXSpecies.setValue(piling, forKey: "piling")
                newReportXSpecies.setValue(rotation, forKey: "rotation")
                newReportXSpecies.setValue(depth, forKey: "depth")
                newReportXSpecies.setValue(Int(countTextBox.text!), forKey: "count")
                newReportXSpecies.setValue(healthTextBox.hasTokens() ? healthTextBox.tokens()![0].title : healthTextBox.text, forKey: "health")
                newReportXSpecies.setValue(notesTextView.text, forKey: "notes")
                newReportXSpecies.setValue(selectedSpecies, forKey: "species")
                do {
                    try context.save()
                }
                catch {
                    print("Error while saving reportXSpecies")
                }
                
                self.navigationController?.popViewControllerAnimated(true)
            }
            else {
                showAlert("Incorrect Format", message: "The count must be an integer.")
            }
        }
        else {
            showAlert("Incorrect Format", message: "The count and health must be entered.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 1 {
            let invalidCharacters = NSCharacterSet(charactersInString: "0123456789").invertedSet
            if let _ = string.rangeOfCharacterFromSet(invalidCharacters, options: [], range:Range<String.Index>(start: string.startIndex, end: string.endIndex)) {
                return false
            }

            return true
        }

        return false
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func decorateSaveButton(){
        let borderColor = UIColor(red: 2/255, green: 204/255, blue: 184/255, alpha: 1).CGColor
        saveButton.layer.cornerRadius = 5
        saveButton.layer.borderColor = borderColor
        saveButton.layer.borderWidth = 2
    }
}

extension AddCreatureViewController: KSTokenViewDelegate {
    func tokenView(token: KSTokenView, performSearchWithString string: String, completion: ((results: Array<AnyObject>) -> Void)?) {
        var matches: Array<String> = []
        let data = self.healthData
        
        for value: String in data {
            if value.lowercaseString.rangeOfString(string.lowercaseString) != nil {
               matches.append(value)
            }
        }
        
        completion!(results: matches)
    }
    
    func tokenView(token: KSTokenView, displayTitleForObject object: AnyObject) -> String {
        return object as! String
    }
    
    func tokenView(token: KSTokenView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
    }
}
