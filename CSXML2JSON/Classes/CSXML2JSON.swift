//
//  CSXML2JSON.swift
//  CSXML2JSON
//
//  Created by mr.s on 12/10/2018.
//  Copyright (c) 2018 mr.s. All rights reserved.
//

import Foundation
import SwiftyJSON

enum XML2JSONError : Int {
    case ValidationError = -1
    case XMLFormatError = -2
    case ParseError = -3
    case Unknown = -100
}
//XML ELEMENT/Tag
class CSXMLTag : NSObject{
    //
    public weak var parentTag : CSXMLTag?
    //
    public var subTags : Array<CSXMLTag>
    //
    public var tagName : String?
    //
    public var namespaceURI : String?
    //when tag contain subtags and text , the text stored as key-value: prefix+'text' : text-value
    public var prefix : String = "_";
    public var text : String = String()
    
    //tagName_text = data string
    public var CDATA : Data = Data()
    //process CDATA to String
    public var cdataString : String{
        get {
            return (String.init(data: CDATA, encoding: .utf8) ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
    }
    //<'_' + attributes Name : Value>
    public var attributes : Dictionary<String,String> = [:]
    
    override init() {
        subTags = Array<CSXMLTag>()
    }
    
    public func getTagContentDictionary()->(Dictionary<String,Any>?,JSON){
        var result : Dictionary<String,Any> = [:]
        var json = JSON()
        if let tagName = self.tagName{
            if self.subTags.count == 0{//no sub tags
                // add attributes
                var tmpDict = Dictionary<String,Any>()
                var tmpJson = JSON()
                attributes.forEach { (key,value) in
                    tmpDict[key] = value
                    tmpJson[key] = JSON(value)
                }
                if let uri = namespaceURI{
                    tmpDict["\(prefix)namespaceURI"] = uri
                    tmpJson["\(prefix)namespaceURI"] = JSON(uri)
                }
                //add text
                if self.text.lengthOfBytes(using: .utf8) > 0{
                    //add cdata
                    if(cdataString.lengthOfBytes(using: .utf8) > 0){
                        tmpDict["\(prefix)cdata_setion"] = cdataString
                        tmpJson["\(prefix)cdata_setion"] = JSON(cdataString)
                    }
                    if(tmpDict.count ==  0){
                        result[tagName] = text
                        json[tagName] = JSON(text)
                    }else{
                        if(text.lengthOfBytes(using: .utf8) > 0){
                            tmpDict["\(prefix)\(tagName)_text"] = text
                            tmpJson["\(prefix)\(tagName)_text"] = JSON(text)
                        }
                        result[tagName] = tmpDict
                        json[tagName] = tmpJson
                    }
                }else{
                    //add cdata
                    if tmpDict.count == 0{
                        if(cdataString.lengthOfBytes(using: .utf8) > 0){
                            result[tagName] = cdataString
                            json[tagName] = JSON(cdataString)
                        }else{
                            result[tagName] = ""
                            json[tagName] = JSON("")
                        }
                    }else{
                        if(cdataString.lengthOfBytes(using: .utf8) > 0){
                            tmpDict["\(prefix)cdata_setion"] = cdataString
                            tmpJson["\(prefix)cdata_setion"] = JSON(cdataString)
                        }
                        result[tagName] = tmpDict
                        json[tagName] = tmpJson
                    }
                }
                return (result,json);
            }else{
                attributes.forEach { (key,value) in
                    result[key] = value
                    json[key] = JSON(value)
                }
                if(cdataString.count > 0){
                    result["\(prefix)cdata_setion"] = cdataString
                    json["\(prefix)cdata_setion"] = JSON(cdataString)
                }
                if self.text.lengthOfBytes(using: .utf8)>0{
                    result["\(prefix)\(tagName)_text"] = text
                    json["\(prefix)\(tagName)_text"] = JSON(text)
                }
                if let uri = namespaceURI{
                    result["\(prefix)namespaceURI"] = uri
                    json["\(prefix)namespaceURI"] = JSON(uri)
                }
                for tag in self.subTags{
                    if let subTagName = tag.tagName{
                        let subTag = tag.getTagContentDictionary()
                        if let subDict = subTag.0{
                            if let item = result[subTagName] {
                                //JSON Obj
                                let jsonItem = json[subTagName]
                                switch item {//According Sub item type
                                case let str as String:
                                    if let obj = subDict[subTagName]{
                                        var arr = Array<Any>()
                                        arr.append(str)
                                        arr.append(obj)
                                        result[subTagName] = arr
                                        //wrap in JSON
                                        var jsonArr = Array<JSON>()
                                        jsonArr.append(jsonItem)
                                        jsonArr.append(subTag.1[subTagName])
                                        json[subTagName] = JSON(jsonArr)
                                    }else{
                                        result[subTagName] = str
                                        //wrap in JSON
                                        json[subTagName] = jsonItem
                                    }
                                    break
                                case let dict as Dictionary<String,Any>:
                                    if let obj = subDict[subTagName]{
                                        var arr = Array<Any>()
                                        arr.append(dict)
                                        arr.append(obj)
                                        result[subTagName] = arr
                                        //wrap in JSON
                                        var jsonArr = Array<JSON>()
                                        jsonArr.append(jsonItem)
                                        jsonArr.append(subTag.1[subTagName])
                                        json[subTagName] = JSON(jsonArr)
                                    }else{
                                        result[subTagName] = dict
                                        //wrap in JSON
                                        json[subTagName] = jsonItem
                                    }
                                    break
                                case _ as Array<Any>:
                                    if let obj = subDict[subTagName]{
                                        var subArr = item as! Array<Any>
                                        subArr.append(obj)
                                        result[subTagName] = subArr
                                        //wrap in JSON
                                        if var jsonArr = jsonItem.array{
                                            jsonArr.append(subTag.1[subTagName])
                                            json[subTagName] = JSON(jsonArr)
                                        }
                                    }else{
                                        result[subTagName] = item
                                        //wrap in JSON
                                        json[subTagName] = jsonItem
                                    }
                                    break
                                default:
                                    break
                                }
                            }else{
                                result[subTagName] = subDict[subTagName]
                                json[subTagName] = subTag.1[subTagName]
                            }
                        }
                    }
                }
            }
            var tmpJson = JSON()
            tmpJson[tagName] = json
            return ([tagName:result],tmpJson);
        }else{
            //elementName is nil
        }
        return (result,json);
    }
    
    public func jsonObject() -> Dictionary<String,Any>?{
        return self.getTagContentDictionary().0
    }
    
    public func jsonObject() -> JSON{
        return self.getTagContentDictionary().1
    }
}

@objc public class CSXML2JSON : NSObject,XMLParserDelegate{
    //
    @objc public var ignoreAttributes : Bool = false
    @objc public var ignoreNamespaceURI : Bool = false
    //Call After Finished
    private var resultHandler : ((Dictionary<String,Any>?,Error?)->Void)?
    private var jsonHandler : ((JSON,Error?)->Void)?
    //element stack
    private var elementStack : Array<String> = [];
    //root tag
    private var rootTag : CSXMLTag
    //current tag
    private var currentTag : CSXMLTag
    //CDATA
    private var dataString : String = String()
    private var cdData : Data? = nil;
    //
    private var parser : XMLParser
    //
    private let lock : NSLock = NSLock.init()
    
    public override init() {
        self.rootTag = CSXMLTag()
        self.currentTag = self.rootTag;
        self.parser = XMLParser()
    }
    
    @objc public func jsonObject(xml : String, resultHandler : @escaping (Dictionary<String,Any>?,Error?)->Void){
        if let data = xml.data(using: String.Encoding.utf8){
            let xmlParser = XMLParser(data:data)
            jsonObject(xmlParser: xmlParser, resultHandler: resultHandler)
        }else{
            if let handler = self.resultHandler{
                handler(nil,NSError(domain: "com.csdq.error", code: XML2JSONError.XMLFormatError.rawValue, userInfo: ["message" : "xml is in wrong format"]));
            }
            parserEndClean()
        }
    }
    
    @objc public func jsonObject(xmlParser : XMLParser, resultHandler : @escaping (Dictionary<String,Any>?,Error?)->Void){
        lock.lock()
        self.resultHandler = resultHandler
        self.parser = xmlParser
        parser.delegate = self
        if parser.parse(){
            
        }else{
            if let handler = self.resultHandler{
                handler(nil,NSError(domain: "com.csdq.error", code: XML2JSONError.ValidationError.rawValue, userInfo: ["message" : parser.parserError?.localizedDescription ?? "xml is in wrong format"]))
            }
            parserEndClean()
        }
    }
    
    public func jsonObject(xml : String, jsonHandler : @escaping (JSON,Error?)->Void){
        if let data = xml.data(using: String.Encoding.utf8){
            let xmlParser = XMLParser(data:data)
            jsonObject(xmlParser: xmlParser, jsonHandler: jsonHandler)
        }else{
            if let handler = self.jsonHandler{
                handler(JSON(),NSError(domain: "com.csdq.error", code: XML2JSONError.XMLFormatError.rawValue,
                                    userInfo: ["message" : "xml is in wrong format"]));
            }
            parserEndClean()
        }
    }
    
    public func jsonObject(xmlParser : XMLParser, jsonHandler : @escaping (JSON,Error?)->Void){
        lock.lock()
        self.jsonHandler = jsonHandler
        self.parser = xmlParser
        parser.delegate = self
        if parser.parse(){
            
        }else{
            if let handler = self.jsonHandler{
                handler(JSON(),NSError(domain: "com.csdq.error",
                                    code: XML2JSONError.XMLFormatError.rawValue,
                                    userInfo: ["message" : parser.parserError?.localizedDescription ?? "xml is in wrong format"]));
            }
            parserEndClean()
        }
    }
    
    /// clean up after parser
    func parserEndClean(){
        self.jsonHandler = nil
        self.resultHandler = nil
        self.parser.delegate = nil
        lock.unlock()
    }
    //    MARK:
    public func parserDidStartDocument(_ parser: XMLParser){
        elementStack.removeAll()
        rootTag = CSXMLTag()
        currentTag = rootTag
    }
    
    public func parserDidEndDocument(_ parser: XMLParser){
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        queue.sync {
            if let handler = self.resultHandler{
                handler(self.rootTag.jsonObject(),nil)
            }
            if let handler = self.jsonHandler{
                handler(self.rootTag.jsonObject(),nil)
            }
            parserEndClean()
        }
    }
    
    public func parser(_ parser: XMLParser,
                       didStartElement elementName: String,
                       namespaceURI: String?,
                       qualifiedName qName: String?,
                       attributes attributeDict: [String : String] = [:]){
        elementStack.append(elementName)
        if let _ = self.currentTag.tagName {
            //store data string
            self.currentTag.text.append(self.dataString)
            //
            let newTagModel = CSXMLTag()
            newTagModel.parentTag = self.currentTag;
            self.currentTag.subTags.append(newTagModel);
            self.currentTag = newTagModel;
        }
        self.currentTag.tagName = elementName
        if !ignoreAttributes {
            self.currentTag.attributes = attributeDict
        }
        if !ignoreNamespaceURI{
            self.currentTag.namespaceURI = namespaceURI
        }
        self.dataString = String()
    }
    
    public func parser(_ parser: XMLParser,
                       didEndElement elementName: String,
                       namespaceURI: String?,
                       qualifiedName qName: String?){
        if let e = elementStack.last {
            if(e == elementName){
                elementStack.removeLast()
                self.currentTag.text = self.dataString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                self.currentTag = self.currentTag.parentTag ?? self.rootTag
                self.dataString = self.currentTag.text
            }else{
                //Exception
            }
        }
    }
    
    public func parser(_ parser: XMLParser, foundCharacters string: String){
        self.dataString.append(string);
    }
    
    public func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String){
        //ignore
    }
    
    public func parser(_ parser: XMLParser, foundComment comment: String){
        //ignore
    }
    
    public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data){
        self.currentTag.CDATA.append(CDATABlock)
    }
    
    public func parser(_ parser: XMLParser,
                       parseErrorOccurred parseError: Error){
        if let handler = self.resultHandler{
            handler(nil,NSError(domain: "com.csdq.error",
                                code: XML2JSONError.ParseError.rawValue,
                                userInfo: ["message" : parseError.localizedDescription]));
        }
        if let handler = self.jsonHandler{
            handler(JSON(),NSError(domain: "com.csdq.error",
                                code: XML2JSONError.ParseError.rawValue,
                                userInfo: ["message" : parseError.localizedDescription]));
        }
        parserEndClean()
    }
    
    public func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error){
        let error = NSError(domain: "com.csdq.error",
                            code: XML2JSONError.ValidationError.rawValue,
                            userInfo: ["message" : validationError.localizedDescription])
        if let handler = self.resultHandler{
            handler(nil,error);
        }
        if let handler = self.jsonHandler{
            handler(JSON(),error);
        }
        parserEndClean()
    }
}
