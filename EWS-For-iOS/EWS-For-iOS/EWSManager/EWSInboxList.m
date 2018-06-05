//
// EWSInboxList.m
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

#import "EWSInboxList.h"
#import "EWSHttpRequest.h"
#import "EWSXmlParser.h"
#import "EWSInboxListModel.h"
#import "EWSManager.h"

typedef void (^GetInboxListBlock)(NSMutableArray *inboxList, NSError *error);

@implementation EWSInboxList{
    EWSHttpRequest *request;
    NSMutableData *eData;
    EWSXmlParser *parser;
    
    GetInboxListBlock _getInboxListBlock;
    
    NSString *currentElement;
    NSMutableArray *_inboxListArray;
    NSError *_error;
}


-(instancetype)init{
    self = [super init];
    if (!self) {
        return nil;
    }
    [self initData];
    
    return self;
}

-(void)initData{
    eData = [[NSMutableData alloc] init];
    request = [[EWSHttpRequest alloc] init];
    parser = [[EWSXmlParser alloc] init];
    _inboxListArray = [[NSMutableArray alloc] init];
}


-(void)getInboxListWithEWSUrl:(NSString *)url finishBlock:(void(^)(NSMutableArray *inboxList, NSError *error))getInboxListBlock{
    _getInboxListBlock = getInboxListBlock;
    
    NSString *soapXmlString =
    @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
    "<soap:Envelope xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\n"
    "xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\n"
    "<soap:Body>\n"
    "<FindItem xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\"\n"
    "xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\"\n"
    "Traversal=\"Shallow\">\n"
    "<ItemShape>\n"
    "<t:BaseShape>IdOnly</t:BaseShape>\n"
    "</ItemShape>\n"
    "<ParentFolderIds>\n"
    "<t:DistinguishedFolderId Id=\"inbox\"/>\n"
    "</ParentFolderIds>\n"
    "</FindItem>\n"
    "</soap:Body>\n"
    "</soap:Envelope>\n";

    [request ewsHttpRequest:soapXmlString url:url emailBoxInfo:((EWSManager *)[EWSManager sharedEwsManager]).ewsEmailBoxModel success:^(NSString *redirectLocation, NSData *xmlData) {

        //        NSLog(@"data:%@",[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding]);
        //        NSLog(@"---inboxList---finish-------");

        [eData appendData:xmlData];
        [self requestFinishLoading];

    } failure:^(NSError *error) {
        _error = error;
    }];
}

-(void)requestFinishLoading{
    __block NSString *currentItemType;
    [parser parserWithData:eData didStartDocument:^{
        
    } didStartElementBlock:^(NSString *elementName, NSString *namespaceURI, NSString *qName, NSDictionary *attributeDict) {
        currentElement = elementName;
        [self inboxListDidStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict currentType:currentItemType];
        currentItemType = elementName;
    } foundCharacters:^(NSString *string) {
        
    } didEndElementBlock:^(NSString *elementName, NSString *namespaceURI, NSString *qName) {
        currentElement = nil;
    } didEndDocument:^{
        [self inboxListDidEndDocument];
    }];
}

-(void)inboxListDidStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict currentType:(NSString *)currentType{
    if ([elementName isEqualToString:@"t:ItemId"]) {
        EWSInboxListModel *temp = [[EWSInboxListModel alloc] init];
        temp.changeKey = attributeDict[@"ChangeKey"];
        temp.itemId = attributeDict[@"Id"];
        if ([currentType isEqualToString:@"t:Message"]) {
            temp.itemType = @"Message";
        }
        else if ([currentType isEqualToString:@"t:MeetingRequest"]){
            temp.itemType = @"MeetingRequest";
        }
        [_inboxListArray addObject:temp];
    }
}

-(void)inboxListDidEndDocument{
    if (_getInboxListBlock) {
        _getInboxListBlock(_inboxListArray,_error);
    }
    request = nil;
    parser = nil;
    eData = nil;
}

@end
