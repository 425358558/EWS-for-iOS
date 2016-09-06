//
//  EWSInboxList.m
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/29.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import "EWSInboxList.h"
#import "EWSHttpRequest.h"
#import "EWSXmlParser.h"
#import "EWSInboxListModel.h"

typedef void (^GetInboxListBlock)(NSMutableArray *inboxList);

@implementation EWSInboxList{
    EWSHttpRequest *request;
    NSMutableData *eData;
    EWSXmlParser *parser;
    
    GetInboxListBlock _getInboxListBlock;
    
    NSString *currentElement;
    NSMutableArray *_inboxListArray;
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
}


-(void)getInboxListWithEWSUrl:(NSString *)url finishBlock:(void(^)(NSMutableArray *inboxList))getInboxListBlock{
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
    
    [request ewsHttpRequest:soapXmlString andUrl:url receiveResponse:^(NSURLResponse *response) {
        NSLog(@"response:%@",response);
    } reveiveData:^(NSData *data) {
        [eData appendData:data];
    } finishLoading:^{
        NSLog(@"data:%@",[[NSString alloc] initWithData:eData encoding:NSUTF8StringEncoding]);
        NSLog(@"---inboxList---finish-------");
        [self requestFinishLoading];
    } error:^(NSError *error) {
        NSLog(@"error:%@",error);
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
        _getInboxListBlock(_inboxListArray);
    }
}

@end
