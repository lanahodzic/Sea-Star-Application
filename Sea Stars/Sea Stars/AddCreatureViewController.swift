//
//  AddCreatureViewController.swift
//  Sea Stars
//
//  Created by Carson Carroll on 11/8/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit
import CoreData

class Checkbox: UIButton {
    let checkedImage = UIImage(named: "checked")! as UIImage
    let uncheckedImage = UIImage(named: "unchecked")! as UIImage
    
    // Bool property
    var isChecked: Bool = false {
        didSet{
            if isChecked == true {
                self.setImage(checkedImage, forState: .Normal)
            } else {
                self.setImage(uncheckedImage, forState: .Normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: "buttonClicked:", forControlEvents: UIControlEvents.TouchUpInside)
        self.isChecked = false
    }
    
    func buttonClicked(sender: UIButton) {
        if sender == self {
            if isChecked == true {
                isChecked = false
            } else {
                isChecked = true
            }
        }
    }
}

protocol SaveSessileDelegate: class {
    func decrementSessileDepth(reset:Bool)
}

class AddCreatureViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var checkboxLabel: UILabel!
    @IBOutlet weak var benthosCheckbox: Checkbox!
    @IBOutlet weak var healthLabel: UILabel!
    @IBOutlet weak var healthTextBox: KSTokenView!
    @IBOutlet weak var speciesLabel: UILabel!
    @IBOutlet weak var countTextBox: UITextField!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var sizeTextBox: UITextField!
    
    var healthData: [String] = ["Healthy: no symptons of disease", "Mild: few lesions, deflated appearance, extreme twisting of rays", "Severe: many lesions, arm loss, disintegration"]
    
    var selectedSpecies: String = ""
    var observer_name: String?
    var site_location: String?
    var report_date: String?
    var piling:Int?
    var direction:Int?
    var depth:Int?
    
    var imagePicker: UIImagePickerController!
    var images:[UIImage] = []
    
    @IBOutlet weak var imageView: UIImageView!

    var benthosChecked: Bool = false
    var seaStarSelected: Bool = false
    var mobileSpecies: Bool = false

    weak var delegate: SaveSessileDelegate? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (seaStarSelected) {
            self.countTextBox.hidden = true
            self.speciesLabel.text = self.selectedSpecies
            self.countLabel.hidden = true
            
            self.sizeLabel.frame = CGRectMake(self.countLabel.frame.minX, self.countLabel.frame.minY, self.sizeLabel.frame.width, self.sizeLabel.frame.height)
            self.sizeTextBox.frame = CGRectMake(self.countTextBox.frame.minX, self.countTextBox.frame.minY, self.sizeTextBox.frame.width, self.sizeTextBox.frame.height)
            
            
            self.healthTextBox.delegate = self
            self.healthTextBox.promptText = ""
            self.healthTextBox.backgroundColor = UIColor(red: 0.00784314, green: 0.8, blue: 0.721569, alpha: 0.202571)
            self.healthTextBox.maxTokenLimit = 1
            self.healthTextBox.style = .Squared
            self.healthTextBox.searchResultSize = CGSize(width: self.healthTextBox.frame.width, height: 160)
            self.healthTextBox.font = UIFont.systemFontOfSize(26)
            self.healthTextBox.direction = .Horizontal
            
            self.countLabel.translatesAutoresizingMaskIntoConstraints = true
            self.countTextBox.translatesAutoresizingMaskIntoConstraints = true
            self.sizeTextBox.translatesAutoresizingMaskIntoConstraints = true
            self.sizeLabel.translatesAutoresizingMaskIntoConstraints = true
            
            
        }
        else {
        
            if (mobileSpecies) {
                self.countLabel.hidden = true
                self.countTextBox.hidden = true
                
                self.countLabel.translatesAutoresizingMaskIntoConstraints = true
                self.countTextBox.translatesAutoresizingMaskIntoConstraints = true
            }
            else {
                self.countTextBox.delegate = self
                self.countTextBox.keyboardType = .NumberPad
                
                self.benthosCheckbox.hidden = true
                self.checkboxLabel.hidden = true
                
                self.benthosCheckbox.translatesAutoresizingMaskIntoConstraints = true
                self.checkboxLabel.translatesAutoresizingMaskIntoConstraints = true
                
            }

            self.speciesLabel.text = self.selectedSpecies
            
            self.notesLabel.frame = CGRectMake(self.healthLabel.frame.minX, self.healthLabel.frame.minY, self.notesLabel.frame.width, self.notesLabel.frame.height)
            self.notesTextView.frame = CGRectMake(self.healthTextBox.frame.minX, self.healthTextBox.frame.minY, self.notesTextView.frame.width, self.notesTextView.frame.height)
            

            self.notesLabel.translatesAutoresizingMaskIntoConstraints = true
            self.notesTextView.translatesAutoresizingMaskIntoConstraints = true
            self.healthLabel.translatesAutoresizingMaskIntoConstraints = true
            self.healthTextBox.translatesAutoresizingMaskIntoConstraints = true
            
            self.healthLabel.hidden = true
            self.healthTextBox.hidden = true
            self.sizeLabel.hidden = true
            self.sizeTextBox.hidden = true
        }
        
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
    
    @IBAction func takePhoto(sender: AnyObject) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        
        // TODO: See why image gets rendered sideways
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            images.append(image)
            let imageData = UIImagePNGRepresentation(image)
            let dataString = imageData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
            let data = NSData(base64EncodedString: dataString!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            let creatureImage = UIImage(data: data!)
            imageView.image = creatureImage
        }
    }
    
    // true indicates the save was successful, false unsuccessful
    func saveReportToCoreData() -> Bool {
        var reportDate:NSDate?
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        reportDate = dateFormatter.dateFromString(report_date!)
        
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext
        
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
                    return false
                }
            }
        }
        catch {
            print("There was an error with the request!")
            return false
        }
        
        return true
    }
    
    func saveSeaStarToCoreData() {
        let reportResult = saveReportToCoreData()
        
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext
        
        if reportResult {
            let newReportXSpecies = NSEntityDescription.insertNewObjectForEntityForName("ReportXSpecies", inManagedObjectContext: context)
            newReportXSpecies.setValue(piling, forKey: "piling")
            newReportXSpecies.setValue(direction, forKey: "direction")
            newReportXSpecies.setValue(depth, forKey: "depth")
            newReportXSpecies.setValue(notesTextView.text, forKey: "notes")
            newReportXSpecies.setValue(selectedSpecies, forKey: "species")
            
            newReportXSpecies.setValue(benthosCheckbox.isChecked, forKey: "benthos")
            newReportXSpecies.setValue(healthTextBox.hasTokens() ? healthTextBox.tokens()![0].title : healthTextBox.text, forKey: "health")
            
            if let inputtedSize = Double(sizeTextBox.text!) {
                if inputtedSize < 2.5 {
                    newReportXSpecies.setValue("X-Small", forKey: "size")
                }
                else if inputtedSize >= 2.5 && inputtedSize < 6 {
                    newReportXSpecies.setValue("Small", forKey: "size")
                }
                else if inputtedSize >= 6 && inputtedSize < 11 {
                    newReportXSpecies.setValue("Medium", forKey: "size")
                }
                else if inputtedSize >= 11 && inputtedSize < 15 {
                    newReportXSpecies.setValue("Large", forKey: "size")
                }
                else if inputtedSize >= 15 {
                    newReportXSpecies.setValue("X-Large", forKey: "size")
                }
                
                do {
                    try context.save()
                }
                catch {
                    print("Error while saving reportXSpecies")
                }
                
                self.navigationController?.popViewControllerAnimated(true)
            }
            else {
                self.showAlert("Size", message: "The size must be a number.")
            }
        }
    }
    
    func saveMobileToCoreData() {
        let reportResult = saveReportToCoreData()
        
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext
        
        if reportResult {
            let newReportXSpecies = NSEntityDescription.insertNewObjectForEntityForName("ReportXSpecies", inManagedObjectContext: context)
            newReportXSpecies.setValue(piling, forKey: "piling")
            newReportXSpecies.setValue(direction, forKey: "direction")
            newReportXSpecies.setValue(depth, forKey: "depth")
            newReportXSpecies.setValue(notesTextView.text, forKey: "notes")
            newReportXSpecies.setValue(selectedSpecies, forKey: "species")
            
            newReportXSpecies.setValue(benthosCheckbox.isChecked, forKey: "benthos")

            do {
                try context.save()
            }
            catch {
                print("Error while saving reportXSpecies")
            }
            
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func saveSessileToCoreData(countOne: Bool = false) {
        let reportResult = saveReportToCoreData()
        
        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext
        
        if reportResult {
            if let count = (countOne ? 1 : Int(countTextBox.text!)) {
                if count <= 0 {
                    self.showAlert("Count Value", message: "The value of count must be greater than zero.")
                }
                else {
                    let newReportXSpecies = NSEntityDescription.insertNewObjectForEntityForName("ReportXSpecies", inManagedObjectContext: context)
                    newReportXSpecies.setValue(piling, forKey: "piling")
                    newReportXSpecies.setValue(direction, forKey: "direction")
                    newReportXSpecies.setValue(depth, forKey: "depth")
                    newReportXSpecies.setValue(countOne ? "" : notesTextView.text, forKey: "notes")
                    newReportXSpecies.setValue(selectedSpecies, forKey: "species")

                    newReportXSpecies.setValue(count, forKey: "count")
                    
                    do {
                        try context.save()
                    }
                    catch {
                        print("Error while saving reportXSpecies")
                    }

                    delegate?.decrementSessileDepth(false)
                    self.navigationController?.popViewControllerAnimated(true)
                }
            }
            else {
                self.showAlert("Count", message: "The count field must be specified.")
            }
        }
    }
    
    @IBAction func save(sender: AnyObject) {
        //TODO: need to get info from size and turn into XS, S, M, L, XL in report/database
        
        let health = self.healthTextBox.hasTokens() ? self.healthTextBox.tokens()![0].title : self.healthTextBox.text
        if seaStarSelected {
            if health != "" && sizeLabel.text != "" {
                saveSeaStarToCoreData()
            }
            else {
                self.showAlert("Fields Missing", message: "An entry for health and size must be provided.")
            }
        }
        else {
            if mobileSpecies {
                saveMobileToCoreData()
            }
            else {
                saveSessileToCoreData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
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
