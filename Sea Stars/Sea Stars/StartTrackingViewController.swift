//
//  StartTrackingViewController.swift
//  Sea Stars
//
//  Created by Lana Hodzic on 11/2/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit

class StartTrackingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var site: UIPickerView!
    @IBOutlet weak var observer_name: UIPickerView!
    
    var siteData: [String] = [String] ()
    var names: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.site.delegate = self
        self.site.dataSource = self
        self.observer_name.delegate = self
        self.observer_name.dataSource = self
        
        siteData = ["Morro Bay", "Monetery", "Santa Barbara", "Bodega Bay", "Humboldt Bay", "San Diego Bay"]
    
        names = ["Maggie Jenkins", "Carly Banks", "Grant Waltz", "Lisa Needles"]
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
