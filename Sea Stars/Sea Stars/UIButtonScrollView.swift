//
//  UIButtonScrollView.swift
//  Sea Stars
//
//  Created by Christopher Wu on 2/14/16.
//  Copyright © 2016 Cal Poly Marine Biology. All rights reserved.
//

import UIKit

class UIButtonScrollView: UIScrollView {

    override func touchesShouldCancelInContentView(view: UIView) -> Bool {
        return true
    }

}