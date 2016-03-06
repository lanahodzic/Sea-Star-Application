//
//  StartTrackingViewController.swift
//  Sea Stars
//
//  Created by Lana Hodzic on 11/2/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class StartTrackingViewController: UIViewController {
    
    let ref = Firebase(url:"https://sea-stars2.firebaseio.com")

    @IBOutlet weak var site: KSTokenView!
    @IBOutlet weak var observer_name: KSTokenView!
    @IBOutlet weak var report_date: UIDatePicker!
    @IBOutlet weak var startButton: UIButton!


    var siteData: [String] = [String]()
    var names: [String] = [String]()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.site.delegate = self
        self.site.promptText = ""
        self.site.backgroundColor = UIColor(red: 0.00784314, green: 0.8, blue: 0.721569, alpha: 0.202571)
        self.site.maxTokenLimit = 1
        self.site.style = .Squared
        self.site.searchResultSize = CGSize(width: self.site.frame.width, height: 160)
        self.site.font = UIFont.systemFontOfSize(26)
        self.site.direction = .Horizontal

        self.observer_name.delegate = self
        self.observer_name.promptText = ""
        self.observer_name.backgroundColor = self.site.backgroundColor
        self.observer_name.maxTokenLimit = 1
        self.observer_name.style = .Squared
        self.observer_name.searchResultSize = CGSize(width: self.site.frame.width, height: 160)
        self.observer_name.font = UIFont.systemFontOfSize(26)
        self.observer_name.direction = .Horizontal

        
        let siteRef = ref.childByAppendingPath("sites")
        siteRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            for child in snapshot.children.allObjects as! [FDataSnapshot] {
                if let siteName = child.value["name"] as? String {
                    self.siteData.append(siteName)
                }
            }
        })
        
        let observerRef = ref.childByAppendingPath("observers")
        var firstName = ""
        var lastName = ""
        observerRef.observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            for child in snapshot.children.allObjects as! [FDataSnapshot] {
                if let observerFirstName = child.value["firstName"] as? String {
                    firstName = observerFirstName
                }
                if let observerLastName = child.value["lastName"] as? String {
                    lastName = observerLastName
                }
                self.names.append("\(firstName) \(lastName)")
            }
        })
        
        decorateStartButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }

    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if !self.observer_name.hasTokens() && self.observer_name.text.isEmpty {
            return false
        }

        if !self.site.hasTokens() && self.site.text.isEmpty {
            return false
        }

        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let vc = segue.destinationViewController as! MainScreenViewController
        vc.observer_name = self.observer_name.hasTokens() ? self.observer_name.tokens()![0].title : self.observer_name.text
        print("*** NAME: " + vc.observer_name!)

        vc.site_location = self.site.hasTokens() ? self.site.tokens()![0].title : self.site.text
        print("*** SITE: " + vc.site_location!)

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let date = dateFormatter.stringFromDate(self.report_date.date)
        vc.report_date = date

        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
        let context = appDel.managedObjectContext
        
        let reportRequest = NSFetchRequest(entityName: "Reports")
        reportRequest.returnsObjectsAsFaults = false

        let reportXSpeciesRequest = NSFetchRequest(entityName: "ReportXSpecies")
        reportXSpeciesRequest.returnsObjectsAsFaults = false

        let reportDeleteRequest = NSBatchDeleteRequest(fetchRequest: reportRequest)
        let reportXSpeciesDeleteRequest = NSBatchDeleteRequest(fetchRequest: reportXSpeciesRequest)
        do {
            try context.executeRequest(reportDeleteRequest)
            try context.executeRequest(reportXSpeciesDeleteRequest)
            print("Deleted all rows from unfinished report")
        }
        catch {
            print("Error deleting all rows from entities")
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
    
    func tokenView(token: KSTokenView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
    }
    
    func decorateStartButton() {
        let borderColor = UIColor(red: 2/255, green: 204/255, blue: 184/255, alpha: 1).CGColor
        startButton.layer.borderColor = borderColor
        startButton.layer.borderWidth = 2
        startButton.layer.cornerRadius = 15
    }
}

