//
//  AddSpeciesViewController.swift
//  Sea Stars
//
//  Created by Carson Carroll on 4/27/16.
//  Copyright © 2016 Cal Poly Marine Biology. All rights reserved.
//

import UIKit
import Firebase

class AddSpeciesViewController: UIViewController {

    let ref = Firebase(url:"https://sea-stars2.firebaseio.com")

    @IBOutlet weak var commonNameTextField: UITextField!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var mobilitySegmentedControl: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phylumTextField: UITextField!
    @IBOutlet weak var imageUrlTextField: UITextField!

    @IBOutlet weak var sessileStepper: UIStepper!
    @IBOutlet weak var sessileDecrementLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        mobilitySegmentedControl.selectedSegmentIndex = 0

        sessileDecrementLabel.text = NSUserDefaults.standardUserDefaults().integerForKey("sessileDecrement").description
        sessileStepper.value = Double(sessileDecrementLabel.text!)!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillDisappear(animated: Bool) {
        NSUserDefaults.standardUserDefaults().setInteger(Int(sessileDecrementLabel.text!)!, forKey: "sessileDecrement")
        super.viewWillDisappear(animated)
    }

    @IBAction func sessileStepperChanged(sender: UIStepper) {
        self.sessileDecrementLabel.text = Int(sender.value).description
    }

    @IBAction func addSpecies(sender: AnyObject) {
        let speciesRef = ref.childByAppendingPath("species")
        let newSpeciesRef = speciesRef.childByAutoId()
        var imageUrlArray:[[String:String]] = []
        
        imageUrlArray.append(["url":imageUrlTextField.text!])
        
        let newSpecies = ["commonName":commonNameTextField.text!, "groupName":groupNameTextField.text!, "images":imageUrlArray, "isMobile":mobilitySegmentedControl.selectedSegmentIndex == 0, "name":nameTextField.text!, "phylum":phylumTextField.text!]

        print(newSpecies)
        newSpeciesRef.setValue(newSpecies)

        let alert = UIAlertController(title: "Species Added", message: "The species was successfully added to the database.", preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: { (action) -> Void in
            self.commonNameTextField.text = ""
            self.groupNameTextField.text = ""
            self.nameTextField.text = ""
            self.phylumTextField.text = ""
            self.imageUrlTextField.text = ""
        })
        alert.addAction(okayAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
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
