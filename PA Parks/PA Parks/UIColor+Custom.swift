//
//  UIColor+Custom.swift
//  US States
//
//  Created by John Hannan on 10/3/17.
//  Copyright © 2017 John Hannan. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    static var randomColor : UIColor {return UIColor(red: CGFloat(arc4random() % 256)/255.0, green: CGFloat(arc4random() % 256)/255.0, blue: CGFloat(arc4random() % 256)/255.0, alpha: 1.0)}
    
    static var lightTan : UIColor {return UIColor(red: 1.0, green: 234.0/255.0, blue: 184.0/255.0, alpha: 1.0)}
    
    static var mediumTan : UIColor {return UIColor(red: 153.0/255.0, green: 102.0/255.0, blue: 51.0/255.0, alpha: 1.0)}
    
    static var darkTan : UIColor {return UIColor(red: 79.0/255.0, green: 47.0/255.0, blue: 0.0/255.0, alpha: 1.0)}
}
