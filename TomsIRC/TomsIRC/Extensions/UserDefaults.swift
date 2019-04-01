//
//  UserDefaults.swift
//  Bubble_IRC
//
//  Created by tom hackbarth on 3/25/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//

import Foundation

extension UserDefaults
{
    
    func getStringFromDefaults(key:String) -> String {
        
        if let _ = self.object(forKey: key){
            return self.object(forKey: key) as! String
        }
        else {
            return ""
        }
        
    }
}
