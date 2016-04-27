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
    @IBOutlet weak var isMobileSwitch: UISwitch!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phylumTextField: UITextField!
    @IBOutlet weak var imageUrlTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addSpecies(sender: AnyObject) {
        let speciesRef = ref.childByAppendingPath("species")
        let newSpeciesRef = speciesRef.childByAutoId()
        var imageUrlArray:[[String:String]] = []
        
        imageUrlArray.append(["url":imageUrlTextField.text!])
        
        let newSpecies = ["commonName":commonNameTextField.text!, "groupName":groupNameTextField.text!, "images":imageUrlArray, "isMobile":isMobileSwitch.on, "name":nameTextField.text!, "phylum":phylumTextField.text!]
        
        newSpeciesRef.setValue(newSpecies)
        
        showAlert("Species Added", message: "The species was successfully added to the database.")
    }
    
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: "Okay", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
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
