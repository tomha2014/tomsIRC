//
//  NSMutableAttributedString.swift
//  TomsIRC
//
//  Created by tom hackbarth on 4/2/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    @discardableResult func bold(_ text: String) -> NSMutableAttributedString {
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Arial-BoldMT", size: 17)!]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text: String) -> NSMutableAttributedString {
        
        let attrs: [NSAttributedString.Key: Any] = [.font: UIFont(name: "Arial", size: 12)!]
        let boldString = NSMutableAttributedString(string:text, attributes: attrs)
        append(boldString)
        
        return self
    }
}
