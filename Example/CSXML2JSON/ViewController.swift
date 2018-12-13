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
    
    @IBOutlet weak var textView: UITextView!
    let tool : CSXML2JSON = CSXML2JSON.init()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.isEditable = false
        tool.xml2jsonObject(xml:
"""
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE note SYSTEM "Note.dtd">
<!-- Comments -->
<cs:books groupId='123' xmlns:cs="http://xxxx.com">
<book>
<author id='1'>Tom</author>
<title>The Apple<a>a tag</a> ^_^ </title>
<publisher>O'Reilly</publisher>
</book>
<book>
<author id='2'><id>13</id>Jack</author>
<title>The sheep</title>
<publisher><![CDATA[ O'Reilly ]]><![CDATA[ Publisher ]]></publisher>
</book>
</cs:books>
"""
        ) { (dict, error) in
            do{
                let json = String.init(data: try JSONSerialization.data(withJSONObject: dict ?? [:], options: JSONSerialization.WritingOptions.prettyPrinted), encoding: String.Encoding.utf8);
                self.textView.text = json
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

