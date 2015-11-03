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
    
    var siteData: [String] = [String] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.site.delegate = self
        self.site.dataSource = self
        
        siteData = ["Morro Bay", "Pismo Beach", "Avila"]
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return siteData.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return siteData[row]
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
