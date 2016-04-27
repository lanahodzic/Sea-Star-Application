//
//  InitialScreenViewController.swift
//  Sea Stars
//
//  Created by Lana Hodzic on 11/11/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit

class InitialScreenViewController: UIViewController {
    @IBOutlet weak var startReportButton: UIButton!
    
    @IBOutlet weak var viewReportsButton: UIButton!

    @IBOutlet weak var settingsButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem = movedBackButton()

        decorateButtons()
    }
    
    func decorateButtons(){
        let borderColor = UIColor(red: 2/255, green: 204/255, blue: 184/255, alpha: 1).CGColor
        
        startReportButton.layer.borderWidth = 2.0
        startReportButton.layer.borderColor = borderColor
        startReportButton.layer.cornerRadius = 15
        viewReportsButton.layer.borderWidth = 2.0
        viewReportsButton.layer.borderColor = borderColor
        viewReportsButton.layer.cornerRadius = 15
        settingsButton.layer.borderWidth = 2.0
        settingsButton.layer.borderColor = borderColor
        settingsButton.layer.cornerRadius = 15
    }
}