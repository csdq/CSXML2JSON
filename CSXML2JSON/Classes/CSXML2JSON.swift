//
//  CSXML2JSON.swift
//  CSXML2JSON
//
//  Created by mr.s on 12/10/2018.
//  Copyright (c) 2018 mr.s. All rights reserved.
//

import Foundation

class CSXMLTag : NSObject{
    public weak var parentTag : CSXMLTag?
    public var subTags : Array<CSXMLTag>
    public var tagName : String?
    public var data : Data?
    public var content : String?
    override init() {
        subTags = Array<CSXMLTag>()
    }
    
    public func getTagContentDictionary()->Dictionary<String,Any>?{
        var result : Dictionary<String,Any> = [:]
        var tmp = result;
        if self.subTags.count == 0{
            if let tagName = self.tagName{
                if let content = self.content{
                    result[tagName] = content;
                }else{
                    result[tagName] = "";
                }
            }else{
                
            }
        }else{
            result = [:]
            for tag in self.subTags{
                if let subTagName = tag.tagName{
                    if let rDict = tag.getTagContentDictionary(){
                        if let dict = rDict["root"] as? Dictionary<String,Any>{
                            if let items = result[subTagName] {
                                if items is String {
                                    var arr = Array<Any>()
                                    arr.append(items)
                                    if let str = dict[subTagName]{
                                        arr.append(str)
                                    }else{
                                        arr.append(dict)
                                    }
                                    result[subTagName] = arr
                                }
                                
                                if items is Dictionary<String,Any>{
                                    var arr = Array<Any>()
                                    arr.append(items)
                                    arr.append(dict)
                                    result[subTagName] = arr
                                }
                                
                                if items is Array<Any>{
                                    var arr = items as! Array<Any>
                                    if let content = dict[subTagName]{
                                        arr.append(content)
                                    }else{
                                        arr.append(dict)
                                    }
                                    result[subTagName] = arr
                                }
                            }else{
                                if let content = dict[subTagName]{
                                    result[subTagName] = content;
                                }else{
                                    result[subTagName] = dict
                                }
                            }
                        }
                    }else{
                        
                    }
                }
            }
            if let tagName = self.tagName{
                tmp[tagName] = result;
                result = tmp;
            }
        }
        return ["root":result];
    }
    
    public func jsonObject()->Dictionary<String,Any>?{
        if let dict = self.getTagContentDictionary(){
            return dict["root"] as? Dictionary<String, Any>
        }else{
            return nil
        }
    }
}

@objc public class CSXML2JSON : NSObject,XMLParserDelegate{
    
    private var resultHandler : ((Dictionary<String,Any>?,Error?)->Void)?
    
    private var elementStack : Array<String> = [];
    
    private var rootTag : CSXMLTag
    private var currentTag : CSXMLTag
    
    private var dataString : String = String()
    private var cdData : Data? = nil;
    
    private var parser : XMLParser
    public override init() {
        self.rootTag = CSXMLTag()
        self.currentTag = self.rootTag;
        self.parser = XMLParser()
    }
    
    public func xml2jsonObject(xml : String, resultHandler : @escaping (Dictionary<String,Any>?,Error?)->Void){
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
    
    
    public func parser(_ parser: XMLParser, foundNotationDeclarationWithName name: String, publicID: String?, systemID: String?){
        
    }
    
    public func parser(_ parser: XMLParser, foundUnparsedEntityDeclarationWithName name: String, publicID: String?, systemID: String?, notationName: String?){
        
    }
    
    public func parser(_ parser: XMLParser, foundAttributeDeclarationWithName attributeName: String, forElement elementName: String, type: String?, defaultValue: String?){
        
    }
    
    public func parser(_ parser: XMLParser, foundElementDeclarationWithName elementName: String, model: String){
        
    }
    
    public func parser(_ parser: XMLParser, foundInternalEntityDeclarationWithName name: String, value: String?){
        
    }
    
    public func parser(_ parser: XMLParser, foundExternalEntityDeclarationWithName name: String, publicID: String?, systemID: String?){
        
    }
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]){
        //
        elementStack.append(elementName)//1. html 2. html head 3. html head meta
        //
        if let _ = self.currentTag.tagName {
            let newTagModel = CSXMLTag()
            newTagModel.tagName = elementName;
            newTagModel.parentTag = self.currentTag;
            self.currentTag.subTags.append(newTagModel);
            self.currentTag = newTagModel;
        }else{//是root
            self.currentTag.tagName = elementName
        }
        self.dataString = String()
    }
    
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?){
        if let e = elementStack.last {
            if(e == elementName){
                elementStack.removeLast()
                self.currentTag.content = self.dataString
                self.dataString = String()
                self.currentTag = self.currentTag.parentTag ?? self.rootTag
            }else{
                //Exception
            }
        
        }
    }
    
    public func parser(_ parser: XMLParser, didStartMappingPrefix prefix: String, toURI namespaceURI: String){
        
    }
    
    public func parser(_ parser: XMLParser, didEndMappingPrefix prefix: String){
        
    }
    
    
    public func parser(_ parser: XMLParser, foundCharacters string: String){
        self.dataString.append(string);
    }
    
    public func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String){
//        self.dataString.append(whitespaceString);
    }
    
    public func parser(_ parser: XMLParser, foundProcessingInstructionWithTarget target: String, data: String?){
        
    }
    
    public func parser(_ parser: XMLParser, foundComment comment: String){
        
    }
    
    public func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data){
        self.currentTag.data = CDATABlock
    }
    
//    func parser(_ parser: XMLParser, resolveExternalEntityName name: String, systemID: String?) -> Data?{
//
//    }
    
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
