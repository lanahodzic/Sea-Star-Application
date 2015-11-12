//
//  StartTrackingViewController.swift
//  Sea Stars
//
//  Created by Lana Hodzic on 11/2/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit
import Parse

class StartTrackingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var site: UIPickerView!
    @IBOutlet weak var observer_name: UIPickerView!
    @IBOutlet weak var report_date: UIDatePicker!
    
    
    var siteData: [String] = [String]()
    var names: [String] = [String]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.site.delegate = self
        self.site.dataSource = self
        self.observer_name.delegate = self
        self.observer_name.dataSource = self
        
        let site_query = PFQuery(className: "Sites")
        site_query.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    let name:String? = (object as PFObject)["name"] as? String
                    if name != nil {
                        print("\(name!)")
                        self.siteData.append(name!)
                    }
                }
                
                print("Size of siteData: \(self.siteData.count)")
                print("Successfully retrieved: \(objects)")
                self.site.reloadAllComponents()
            } else {
                print("Error: \(error) \(error!.userInfo)")
            }
        }
        
       let name_query = PFQuery(className: "Observer")
        name_query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    let first_name:String? = (object as PFObject)["firstName"] as? String
                    let last_name:String? = (object as PFObject)["lastName"] as? String
                    let name = first_name! + " " + last_name!
                    self.names.append(name)
                }
                self.observer_name.reloadAllComponents()
            } else {
                print("Error: \(error) \(error!.userInfo)")
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 0){
            return siteData.count
        }
        else {
            return names.count
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 0){
            return siteData[row]
        }
        else {
            return names[row]
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       let vc = segue.destinationViewController as! MainScreenViewController
        let observer_row = self.observer_name.selectedRowInComponent(0)
        vc.observer_name = self.names[observer_row]
        
        let site_row = self.site.selectedRowInComponent(0)
        vc.site_location = self.siteData[site_row]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let date = dateFormatter.stringFromDate(self.report_date.date)
        vc.report_date = date
        
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
