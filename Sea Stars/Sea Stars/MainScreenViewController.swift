//
//  MainScreenViewController.swift
//  Sea Stars
//
//  Created by Carson Carroll on 11/8/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit
import Parse

class MainScreenViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var pilingTextBox: UITextField!
    @IBOutlet weak var rotationTextBox: UITextField!
    @IBOutlet weak var depthTextBox: UITextField!
    
    @IBOutlet weak var imageButton1: UIButton!
    @IBOutlet weak var imageButton2: UIButton!
    @IBOutlet weak var imageButton3: UIButton!
    @IBOutlet weak var imageButton4: UIButton!
    @IBOutlet weak var imageButton5: UIButton!
    
    @IBOutlet weak var speciesLabel1: UILabel!
    @IBOutlet weak var speciesLabel2: UILabel!
    @IBOutlet weak var speciesLabel3: UILabel!
    @IBOutlet weak var speciesLabel4: UILabel!
    @IBOutlet weak var speciesLabel5: UILabel!
    
    var seaStarImages:[UIImage] = [UIImage]()
    var species:[String] = [String]()

    var observer_name: String?
    var site_location: String?
    var report_date: String?
    
    var imageButtonCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addCreature")
        
        let speciesQuery = PFQuery(className: "Species")
        speciesQuery.limit = 5
        speciesQuery.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    self.convertFirstElementToImage(object)
                    let speciesName:String = (object as PFObject)["name"] as! String
                    self.species.append(speciesName)
                    
                    switch (self.imageButtonCounter++) {
                        case 0:
                            self.speciesLabel1.text = self.species[0]
                        case 1:
                            self.speciesLabel2.text = self.species[1]
                        case 2:
                            self.speciesLabel3.text = self.species[2]
                        case 3:
                            self.speciesLabel4.text = self.species[3]
                        case 4:
                            self.speciesLabel5.text = self.species[4]
                        default:
                            break
                    }
                }
            }
            else {
                print("Error: \(error) \(error!.userInfo)")
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        pilingTextBox.text = ""
        rotationTextBox.text = ""
        depthTextBox.text = ""
    }
    
    func convertFirstElementToImage(object:AnyObject) -> Void {
        let imagesArray:[PFFile] = (object as! PFObject)["images"] as! [PFFile]
        let imageFile:PFFile = imagesArray[0]
        
        do {
            let imageData = try imageFile.getData()
            let seaStarImage:UIImage = UIImage(data: imageData)!
            self.seaStarImages.append(seaStarImage)
            
            switch (self.imageButtonCounter) {
                case 0:
                    self.imageButton1.setBackgroundImage(self.seaStarImages[self.imageButtonCounter], forState: .Normal)
                case 1:
                    self.imageButton2.setBackgroundImage(self.seaStarImages[self.imageButtonCounter], forState: .Normal)
                case 2:
                    self.imageButton3.setBackgroundImage(self.seaStarImages[self.imageButtonCounter], forState: .Normal)
                case 3:
                    self.imageButton4.setBackgroundImage(self.seaStarImages[self.imageButtonCounter], forState: .Normal)
                case 4:
                    self.imageButton5.setBackgroundImage(self.seaStarImages[self.imageButtonCounter], forState: .Normal)
                default:
                    break
            }
        }
        catch {
            print(error)
        }
    }
    
    func addCreature() -> Void {
        performSegueWithIdentifier("addCreatureSegue1", sender: self.navigationItem.rightBarButtonItem)
        print("Creature was added")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reportCell", forIndexPath: indexPath)
        cell.textLabel?.text = "Test"

        return cell
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let addCreatureVC = segue.destinationViewController as! AddCreatureViewController
        
        switch (NSArray(array:seaStarImages).indexOfObject(((sender as? UIButton)?.backgroundImageForState(.Normal))!)) {
            case 0:
                addCreatureVC.selectedSpecies = species[0]
            case 1:
                addCreatureVC.selectedSpecies = species[1]
            case 2:
                addCreatureVC.selectedSpecies = species[2]
            case 3:
                addCreatureVC.selectedSpecies = species[3]
            case 4:
                addCreatureVC.selectedSpecies = species[4]
            default:
                break
        }
        
        addCreatureVC.piling = Int(pilingTextBox.text!)
        addCreatureVC.rotation = Int(rotationTextBox.text!)
        addCreatureVC.depth = Int(depthTextBox.text!)
        addCreatureVC.observer_name = observer_name
        addCreatureVC.report_date = report_date
        addCreatureVC.site_location = site_location
    }

}
