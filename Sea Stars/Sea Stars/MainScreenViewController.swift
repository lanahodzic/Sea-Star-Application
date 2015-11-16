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
    
    @IBOutlet weak var imageButton1: UIButton!
    @IBOutlet weak var imageButton2: UIButton!
    @IBOutlet weak var imageButton3: UIButton!
    @IBOutlet weak var imageButton4: UIButton!
    @IBOutlet weak var imageButton5: UIButton!
    
    var seaStarImages:[UIImage] = [UIImage]()
    var species:[String] = [String]()

    var observer_name: String?
    var site_location: String?
    var report_date: String?
    
    var imageButtonCounter = 0
    
    func convertFirstElementToImage(object:AnyObject, imageNumber:Int) -> Void {
        let imagesArray:[PFFile] = (object as! PFObject)["images"] as! [PFFile]
        let imageFile:PFFile = imagesArray[0]

        do {
            let imageData = try imageFile.getData()
            let seaStarImage:UIImage = UIImage(data: imageData)!
            self.seaStarImages.append(seaStarImage)
            
            switch (imageNumber) {
                case 0:
                    self.imageButton1.setBackgroundImage(self.seaStarImages[imageNumber], forState: .Normal)
                case 1:
                    self.imageButton2.setBackgroundImage(self.seaStarImages[imageNumber], forState: .Normal)
                case 2:
                    self.imageButton3.setBackgroundImage(self.seaStarImages[imageNumber], forState: .Normal)
                case 3:
                    self.imageButton4.setBackgroundImage(self.seaStarImages[imageNumber], forState: .Normal)
                case 4:
                    self.imageButton5.setBackgroundImage(self.seaStarImages[imageNumber], forState: .Normal)
                default:
                    break
            }
        }
        catch {
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "addCreature")
        
        let speciesQuery = PFQuery(className: "Species")
        speciesQuery.limit = 5
        speciesQuery.findObjectsInBackgroundWithBlock{ (objects, error) -> Void in
            if error == nil {
                for object in objects! {
                    self.convertFirstElementToImage(object, imageNumber:self.imageButtonCounter++)
                    let speciesName:String = (object as PFObject)["name"] as! String
                    self.species.append(speciesName)
                }
            }
            else {
                print("Error: \(error) \(error!.userInfo)")
            }
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
