//
//  ViewController.swift
//  CSXML2JSON
//
//  Created by mr.s on 12/10/2018.
//  Copyright (c) 2018 mr.s. All rights reserved.
//

import UIKit
import CSXML2JSON

class ViewController: UIViewController {
    
    let tool : CSXML2JSON = CSXML2JSON.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        tool.xml2jsonObject(xml:
"""
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Name</key>
    <string>Mr.s</string>
    <key>Address</key>
    <dict>
        <key>Country</key>
        <string>C</string>
        <key>Province</key>
        <string>Z</string>
        <key>City</key>
        <string>N</string>
    </dict>
    <key>Array</key>
    <array>
        <dict>
            <key>title</key>
            <string>🏀</string>
            <key>icons</key>
            <array>
                <string>1-1.png</string>
                <string>1-2.png</string>
            </array>
        </dict>
        <dict>
            <key>title</key>
            <string>⚽️</string>
            <key>icons</key>
            <array>
                <string>2-1.png</string>
                <string>2-2.png</string>
            </array>
        </dict>
        <dict>
            <key>title</key>
            <string>🏓️</string>
            <key>icons</key>
            <array>
                <string>3-1.png</string>
                <string>3-2.png</string>
            </array>
        </dict>
    </array>
</dict>

<my_addition>
<letters>
<a>Letter A</a>
<b>Letter B</b>
<b>Letter B</b>
<b>Letter B</b>
<b>Letter B</b>
<c>Letter B</c>
</letters>
</my_addition>

</plist>

"""
        ) { (dict, error) in
            do{
                try print("\(String(describing: String.init(data: JSONSerialization.data(withJSONObject: dict ?? [:], options: JSONSerialization.WritingOptions.prettyPrinted), encoding: String.Encoding.utf8)!))");
                //");
            }catch{
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

