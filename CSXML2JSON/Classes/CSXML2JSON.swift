//
//  CSXML2JSON.swift
//  CSXML2JSON
//
//  Created by mr.s on 12/10/2018.
//  Copyright (c) 2018 mr.s. All rights reserved.
//

import Foundation

//XML ELEMENT/Tag
class CSXMLTag : NSObject{
    public weak var parentTag : CSXMLTag?
    public var subTags : Array<CSXMLTag>
    //
    public var tagName : String?
    //
    public var namespaceURI : String?
    //text = text
    public var text : String = String()
    //tagName_text = data string
    public var CDATA : Data = Data()
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
    
    public func getTagContentDictionary()->Dictionary<String,Any>?{
        var result : Dictionary<String,Any> = [:]
        if let tagName = self.tagName{
            if self.subTags.count == 0{//no sub tags
                // add attributes
                var tmpDict = Dictionary<String,Any>()
                if(attributes.count > 0){
                    attributes.forEach { tmpDict[$0] = $1 }
                }
                if let uri = namespaceURI{
                    tmpDict["#namespaceURI"] = uri
                }
                //add text
                if self.text.lengthOfBytes(using: .utf8) > 0{
                    //add cdata
                    if(cdataString.lengthOfBytes(using: .utf8) > 0){
                        tmpDict["#cdata_setion"] = cdataString
                    }
                    if(tmpDict.count ==  0){
                        result[tagName] = text
                    }else{
                        if(text.lengthOfBytes(using: .utf8) > 0){
                            tmpDict["#\(tagName)_text"] = text;
                        }
                        result[tagName] = tmpDict
                    }
                }else{
                    //add cdata
                    if tmpDict.count == 0{
                        if(cdataString.lengthOfBytes(using: .utf8) > 0){
                            result[tagName] = cdataString
                        }else{
                            result[tagName] = ""
                        }
                    }else{
                        if(cdataString.lengthOfBytes(using: .utf8) > 0){
                            tmpDict["#cdata_setion"] = cdataString
                        }
                        result[tagName] = tmpDict
                    }
                }
                return result;
            }else{
                attributes.forEach { result[$0] = $1 }
                if(cdataString.count > 0){
                    result["#cdata_setion"] = cdataString
                }
                if self.text.lengthOfBytes(using: .utf8)>0{
                    result["#\(tagName)_text"] = text;
                }
                if let uri = namespaceURI{
                    result["#namespaceURI"] = uri
                }
                for tag in self.subTags{
                    if let subTagName = tag.tagName{
                        if let subDict = tag.getTagContentDictionary(){
                            if let item = result[subTagName] {
                                //According Sub item type
                                if item is String {
                                    if let obj = subDict[subTagName]{
                                        var arr = Array<Any>()
                                        arr.append(item)
                                        arr.append(obj)
                                        result[subTagName] = arr
                                    }else{
                                        result[subTagName] = item
                                    }
                                }
                                if item is Dictionary<String,Any>{
                                    var arr = Array<Any>()
                                    if let obj = subDict[subTagName]{
                                        arr.append(item)
                                        arr.append(obj)
                                        result[subTagName] = arr
                                    }else{
                                        result[subTagName] = item;
                                    }
                                }
                                
                                if item is Array<Any>{
                                    if let obj = subDict[subTagName]{
                                        var arr = item as! Array<Any>
                                        arr.append(obj)
                                        result[subTagName] = arr
                                    }else{
                                        result[subTagName] = item
                                    }
                                }
                            }else{
                                result[subTagName] = subDict[subTagName]
                            }
                        }
                    }
                }
            }
            return [tagName:result];
        }else{
            //elementName is nil
        }
        return result;
    }
    
    public func jsonObject()->Dictionary<String,Any>?{
        return self.getTagContentDictionary()
    }
}

@objc public class CSXML2JSON : NSObject,XMLParserDelegate{
    //Call After Finished
    private var resultHandler : ((Dictionary<String,Any>?,Error?)->Void)?
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
    
    public override init() {
        self.rootTag = CSXMLTag()
        self.currentTag = self.rootTag;
        self.parser = XMLParser()
    }
    
    @objc public func xml2jsonObject(xml : String, resultHandler : @escaping (Dictionary<String,Any>?,Error?)->Void){
        self.resultHandler = resultHandler
        if let data = xml.data(using: String.Encoding.utf8){
            self.parser = XMLParser(data:data)
            parser.delegate = self
            if parser.parse(){
                
            }else{
                if let handler = self.resultHandler{
                    handler(nil,NSError(domain: "com.csdq.error", code: -1, userInfo: ["message" : parser.parserError?.localizedDescription ?? "xml is in wrong format"]));
                }
            }
        }else{
            if let handler = self.resultHandler{
                handler(nil,NSError(domain: "com.csdq.error", code: -1, userInfo: ["message" : "xml is in wrong format"]));
            }
        }
        
    }
    
    @objc public func xml2jsonObject(xmlParser : XMLParser, resultHandler : @escaping (Dictionary<String,Any>?,Error?)->Void){
        self.resultHandler = resultHandler
        self.parser = xmlParser
        parser.delegate = self
        if parser.parse(){
            
        }else{
            if let handler = self.resultHandler{
                handler(nil,NSError(domain: "com.csdq.error", code: -1, userInfo: ["message" : parser.parserError?.localizedDescription ?? "xml is in wrong format"]));
            }
        }
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
        }
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]){
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
        self.currentTag.attributes = attributeDict
        self.currentTag.namespaceURI = namespaceURI
        self.dataString = String()
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?){
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
    
    public func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error){
        if let handler = self.resultHandler{
            handler(nil,NSError(domain: "com.csdq.error", code: -1, userInfo: ["message" : parseError.localizedDescription]));
        }
    }
    
    public func parser(_ parser: XMLParser, validationErrorOccurred validationError: Error){
        if let handler = self.resultHandler{
            handler(nil,NSError(domain: "com.csdq.error", code: -1, userInfo: ["message" : validationError.localizedDescription]));
        }
    }
}
