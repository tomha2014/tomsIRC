//
//  StringExtension.swift
//  KISS_IRC
//
//  Created by tom hackbarth on 3/19/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//

import Foundation
extension String {
    func withoutWhitespace() -> String {
        return self.replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
            .replacingOccurrences(of: "\0", with: "")
    }
    
    func replace(target: String, withString: String) -> String
    {
        return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil)
    }

    func indexes(of character: String) -> [Int] {
        
        precondition(character.count == 1, "Must be single character")
        
        return self.enumerated().reduce([]) { partial, element  in
            if String(element.element) == character {
                return partial + [element.offset]
            }
            return partial
        }
    }
}
