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
    
    var speciesData:[String] = [String]()
    var selectedSpecies:String = ""
    
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
                self.speciesPicker.selectRow(self.speciesData.indexOf(self.selectedSpecies)!, inComponent: 0, animated: true)
            }
            else {
                print("Error: \(error) \(error!.userInfo)")
            }
        }
    }
    
    @IBAction func save(sender: AnyObject) {
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
