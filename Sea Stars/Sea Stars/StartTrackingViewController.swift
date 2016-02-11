//
//  StartTrackingViewController.swift
//  Sea Stars
//
//  Created by Lana Hodzic on 11/2/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit
import Parse

class StartTrackingViewController: UIViewController {

    @IBOutlet weak var site: KSTokenView!
    @IBOutlet weak var observer_name: KSTokenView!
    @IBOutlet weak var report_date: UIDatePicker!


    var siteData: [String] = [String]()
    var names: [String] = [String]()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.site.delegate = self
        self.site.promptText = "Site: "
        self.site.maxTokenLimit = 1
        self.site.style = .Squared
        self.site.searchResultSize = CGSize(width: self.site.frame.width, height: 120)
        self.site.font = UIFont.systemFontOfSize(17)

        self.observer_name.delegate = self
        self.observer_name.promptText = "Name: "
        self.observer_name.maxTokenLimit = 1
        self.observer_name.style = .Squared
        self.observer_name.searchResultSize = CGSize(width: self.site.frame.width, height: 120)
        self.observer_name.font = UIFont.systemFontOfSize(17)

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
            } else {
                print("Error: \(error) \(error!.userInfo)")
            }

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if self.observer_name.tokens() == nil || self.observer_name.tokens()!.isEmpty {
            return false
        }

        if self.site.tokens() == nil || self.site.tokens()!.isEmpty {
            return false
        }

        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! MainScreenViewController
        vc.observer_name = self.observer_name.tokens()![0].title
        print("*** NAME: " + vc.observer_name!)

        vc.site_location = self.site.tokens()![0].title
        print("*** SITE: " + vc.site_location!)

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
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

extension StartTrackingViewController: KSTokenViewDelegate {
    func tokenView(token: KSTokenView, performSearchWithString string: String, completion: ((results: Array<AnyObject>) -> Void)?) {
        var matches: Array<String> = []
        let data = token.tag == 0 ? self.siteData : self.names
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
}

