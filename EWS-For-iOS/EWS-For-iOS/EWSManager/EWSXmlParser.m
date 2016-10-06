//
// EWSXmlParser.m
// EWS-For-iOS
//
// Copyright (c) 2016 wangxk
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
