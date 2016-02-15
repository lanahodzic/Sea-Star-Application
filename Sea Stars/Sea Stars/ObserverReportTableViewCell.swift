//
//  ReportTableViewCell.swift
//  Sea Stars
//
//  Created by Carson Carroll on 11/17/15.
//  Copyright © 2015 Cal Poly Marine Biology. All rights reserved.
//

import UIKit

class ObserverReportTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var seaStarImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
