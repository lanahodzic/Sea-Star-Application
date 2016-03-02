//
//  Species.swift
//  Sea Stars
//
//  Created by Carson Carroll on 2/25/16.
//  Copyright © 2016 Cal Poly Marine Biology. All rights reserved.
//

import Foundation
import Firebase

class Species {
    
    var commonName:String = ""
    var groupName:String = ""
    var isMobile:Bool = false
    var name:String = ""
    var phylum:String = ""
    var imageURL:String = ""
    var imageView:UIImageView = UIImageView()
    
    init (fromSnapshot snapshot:FDataSnapshot, loadImages:Bool) {
        let dictionary = snapshot.value as! [String:AnyObject]
        
        if let commonName = dictionary["commonName"] as? String {
            self.commonName = commonName
        }
        if let groupName = dictionary["groupName"] as? String {
            self.groupName = groupName
        }
        if let isMobile = dictionary["isMobile"] as? Bool {
            self.isMobile = isMobile
        }
        if let name = dictionary["name"] as? String {
            self.name = name
        }
        if let phylum = dictionary["phylum"] as? String {
            self.phylum = phylum
        }
        if let imagesArray = dictionary["images"] as? [[String:String]] {
            if let imageURL = imagesArray[0]["url"] {
                self.imageURL = imageURL
            }
        }
        
        if loadImages {
            if let url = NSURL(string: imageURL) {
                if let placeholder = UIImage(named: "sea-star-black") {
                    let urlRequest = NSURLRequest(URL: url)
                    imageView.setImageWithURLRequest(urlRequest, placeholderImage: placeholder, success: {
                        (request: NSURLRequest, response: NSHTTPURLResponse?, image: UIImage) -> Void in
                        self.imageView.image = image
                        let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
                        let navVC = appDel.window?.rootViewController as! UINavigationController
                        let vc = navVC.topViewController as! MainScreenViewController
                        vc.refreshTable()
                        }, failure: {
                            (request: NSURLRequest, response: NSHTTPURLResponse?, error: NSError) -> Void in
                    })
                }
            }
        }
    }
}