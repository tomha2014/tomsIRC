//
//  CmdMsg.swift
//  TomsIRC
//
//  Created by tom hackbarth on 4/2/19.
//  Copyright © 2019 thackbarth.com. All rights reserved.
//

import Foundation

class CmdMsg
{
    let cmd:String
    let msg : String
    init(cmd:String, msg: String) {
        self.cmd = cmd
        self.msg = msg
    }
}
