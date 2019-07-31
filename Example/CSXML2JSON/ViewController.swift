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
        tool.ignoreAttributes = false
        tool.jsonObject(xml:
            """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE note SYSTEM "Note.dtd">
            <!-- Comments -->
            <cs:books groupId='123' xmlns:cs="http://xxxx.com">
            <book>
            <author id='1'>Sheery</author>
            <title>Orange</title>
            <publisher>O'Reilly</publisher>
            </book>
            <book>
            <author id='2'><id>1uwefueign3</id>Jack</author>
            <title>The sheep</title>
            <publisher><![CDATA[ O'Reilly ]]><![CDATA[ Publisher  in cdata]]></publisher>
            </book>
            </cs:books>
            """
            ,resultHandler:{ (dict, error) in
                do{
                    let json = String.init(data: try JSONSerialization.data(withJSONObject: dict ?? [:], options: JSONSerialization.WritingOptions.prettyPrinted), encoding: String.Encoding.utf8);
                    self.textView.text = json
                }catch{
                    
                }
        })
        
        tool.jsonObject(xml:
            """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE note SYSTEM "Note.dtd">
            <!-- Comments -->
            <cs:books groupId='123' xmlns:cs="http://xxxx.com">
            <book>
            <author id='1'>Tom</author>
            <title>The Apple</title>
            <publisher>O'Reilly</publisher>
            </book>
            <book>
            <author id='2'><id>13</id>Jack</author>
            <title>The sheep</title>
            <publisher><![CDATA[ O'Reilly ]]><![CDATA[ Publisher ]]></publisher>
            </book>
            </cs:books>
            """, jsonHandler: { (json, error) in
                if let jsonDict = json {
                    print(jsonDict.dictionary ?? "no value")
                }
        })
        
        tool.jsonObject(xml:
            """
            <?xml version="1.0" encoding="UTF-8"?>
            <!DOCTYPE note SYSTEM "Note.dtd">
            <!-- Comments -->
            <Group groupId='1' xmlns:cs="http://xxxx.com">
            <name>jack</name>
            <id>33889</id>
            </Group>
            """,jsonHandler: { (json, error) in
                print(json!.dictionary ?? "")
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

