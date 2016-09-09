//
//  EWSXmlParser.m
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/18.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import "EWSXmlParser.h"

typedef void (^ParserDidStartDocumentBlock)();
typedef void (^ParserDidStartElementBlock)(NSString *elementName, NSString *namespaceURI, NSString *qName, NSDictionary *attributeDict);
typedef void (^ParserFoundCharactersBlock)(NSString *string);
typedef void (^ParserDidEndElementBlock)(NSString *elementName, NSString *namespaceURI, NSString *qName);
typedef void (^ParserDidEndDocumentBlock)();

@implementation EWSXmlParser{
    NSXMLParser *xmlParser;
    
    ParserDidStartDocumentBlock _parserDidStartDocumentBlock;
    ParserDidStartElementBlock _parserDidStartElementBlock;
    ParserFoundCharactersBlock _parserFoundCharactersBlock;
    ParserDidEndElementBlock _parserDidEndElementBlock;
    ParserDidEndDocumentBlock _parserDidEndDocumentBlock;
}

-(void)parserWithData:(NSData *)data didStartDocument:(void (^)())parserDidStartDocumentBlock didStartElementBlock:(void (^)(NSString *elementName, NSString *namespaceURI, NSString *qName, NSDictionary *attributeDict))parserDidStartElementBlock foundCharacters:(void (^)(NSString *string))parserFoundCharactersBlock didEndElementBlock:(void (^)(NSString *elementName, NSString *namespaceURI, NSString *qName))parserDidEndElementBlock didEndDocument:(void (^)())parserDidEndDocumentBlock{
    
    _parserDidStartDocumentBlock = parserDidStartDocumentBlock;
    _parserDidStartElementBlock = parserDidStartElementBlock;
    _parserFoundCharactersBlock = parserFoundCharactersBlock;
    _parserDidEndElementBlock = parserDidEndElementBlock;
    _parserDidEndDocumentBlock = parserDidEndDocumentBlock;
    
    [self parserWithData:data];
}

-(void)parserWithData:(NSData *)data{
    xmlParser = [[NSXMLParser alloc] initWithData:data];
    xmlParser.delegate = self;
    [xmlParser parse];
}

#pragma mark - delegate
- (void)parserDidStartDocument:(NSXMLParser *)parser{
    if (_parserDidStartDocumentBlock) {
        _parserDidStartDocumentBlock();
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict{
    if (_parserDidStartElementBlock) {
        _parserDidStartElementBlock(elementName, namespaceURI, qName, attributeDict);
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if (_parserFoundCharactersBlock) {
        _parserFoundCharactersBlock(string);
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName{
    if (_parserDidEndElementBlock) {
        _parserDidEndElementBlock(elementName, namespaceURI, qName);
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser{
    
    if (_parserDidEndDocumentBlock) {
        _parserDidEndDocumentBlock();
    }
}


@end
