//
//  EWSXmlParser.h
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/18.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EWSXmlParser : NSObject<NSXMLParserDelegate>

-(void)parserWithData:(NSData *)data didStartDocument:(void (^)())parserDidStartDocumentBlock didStartElementBlock:(void (^)(NSString *elementName, NSString *namespaceURI, NSString *qName, NSDictionary *attributeDict))parserDidStartElementBlock foundCharacters:(void (^)(NSString *string))parserFoundCharactersBlock didEndElementBlock:(void (^)(NSString *elementName, NSString *namespaceURI, NSString *qName))parserDidEndElementBlock didEndDocument:(void (^)())parserDidEndDocumentBlock;

@end
