//
//  EWSItemContent.m
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/30.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import "EWSItemContent.h"
#import "EWSHttpRequest.h"
#import "EWSXmlParser.h"

typedef void (^GetItemContentBlock)(EWSItemContentModel *itemContentInfo, NSError *error);

@implementation EWSItemContent{
    EWSHttpRequest *request;
    NSMutableData *eData;
    EWSXmlParser *parser;
    
    GetItemContentBlock _getItemContentBlock;
    
    NSString *currentElement;
    EWSMailAccountModel *_mailAccountModel;
    EWSItemContentModel *_itemContentModel;
    EWSMailAttachmentModel *_mailAttachmentModel;
    NSMutableString *_contentString;
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
    _itemContentModel = [[EWSItemContentModel alloc] init];
    _contentString = [[NSMutableString alloc] init];
}

-(void)getItemContentWithEWSUrl:(NSString *)url item:(EWSInboxListModel *)item finishBlock:(void (^)(EWSItemContentModel *itemContentInfo, NSError *error))getItemContentBlock{
    _getItemContentBlock = getItemContentBlock;
    
    NSString *soapXmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                               "<soap:Envelope\n"
                               "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n"
                               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"\n"
                               "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\n"
                               "xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\n"
                               "<soap:Body>\n"
                               "<GetItem\n"
                               "xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\"\n"
                               "xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\n"
                               "<ItemShape>\n"
                               "<t:BaseShape>AllProperties</t:BaseShape>\n"
                               "<t:IncludeMimeContent>false</t:IncludeMimeContent>\n"
                               "</ItemShape>\n"
                               "<ItemIds>\n"
                               "<t:ItemId Id=\"%@\" ChangeKey=\"%@\" />\n"
                               "</ItemIds>\n"
                               "</GetItem>\n"
                               "</soap:Body>\n"
                               "</soap:Envelope>\n",item.itemId,item.changeKey];
    
    [request ewsHttpRequest:soapXmlString andUrl:url receiveResponse:^(NSURLResponse *response) {
//        NSLog(@"response:%@",response);
    } reveiveData:^(NSData *data) {
        [eData appendData:data];
    } finishLoading:^{
//        NSLog(@"data:%@",[[NSString alloc] initWithData:eData encoding:NSUTF8StringEncoding]);
//        NSLog(@"----itemContent--finish-------");
        [self requestFinishLoading];
    } error:^(NSError *error) {
        _error = error;
    }];
}

-(void)requestFinishLoading{
    [parser parserWithData:eData didStartDocument:^{
        
    } didStartElementBlock:^(NSString *elementName, NSString *namespaceURI, NSString *qName, NSDictionary *attributeDict) {
        currentElement = elementName;
        [self itemContentDidStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
    } foundCharacters:^(NSString *string) {
        [self itemContentFoundCharacters:string];
    } didEndElementBlock:^(NSString *elementName, NSString *namespaceURI, NSString *qName) {
        currentElement = nil;
    } didEndDocument:^{
        [self itemContentDidEndDocument];
    }];
}


-(void)itemContentDidStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict{
    
    if ([elementName isEqualToString:@"t:Mailbox"]) {
        _mailAccountModel = [[EWSMailAccountModel alloc] init];
    }
    else if ([elementName isEqualToString:@"t:ToRecipients"]) {
        _itemContentModel.toRecipientsList = [[NSMutableArray alloc] init];
    }
    else if([elementName isEqualToString:@"t:CcRecipients"]) {
        _itemContentModel.ccRecipientsList = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:@"t:From"]) {
        _itemContentModel.fromList = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:@"t:Attachments"]) {
        _itemContentModel.attachmentList = [[NSMutableArray alloc] init];
    }
    else if ([elementName isEqualToString:@"t:FileAttachment"]) {
        _mailAttachmentModel = [[EWSMailAttachmentModel alloc] init];
    }
    else if ([elementName isEqualToString:@"t:AttachmentId"]) {
        _mailAttachmentModel.attachmentId = attributeDict[@"Id"];
    }
    
}

-(void)itemContentFoundCharacters:(NSString *)string{
    
    if ([currentElement isEqualToString:@"t:Subject"]) {
        _itemContentModel.itemSubject = string;
    }
    else if ([currentElement isEqualToString:@"t:Body"]){
        [_contentString appendString:string];
    }
    else if ([currentElement isEqualToString:@"t:Size"]) {
        _itemContentModel.size = string;
    }
    else if ([currentElement isEqualToString:@"t:DateTimeSent"]) {
        _itemContentModel.dateTimeSentStr = string;
    }
    else if ([currentElement isEqualToString:@"t:DateTimeCreated"]) {
        _itemContentModel.dateTimeCreatedStr = string;
    }
    else if ([currentElement isEqualToString:@"t:HasAttachments"]) {
        if ([string isEqualToString:@"true"]) {
            _itemContentModel.hasAttachments = YES;
        }
        else{
            _itemContentModel.hasAttachments = NO;
        }
    }
    else if ([currentElement isEqualToString:@"t:Name"]) {
        if (_mailAccountModel) {
            _mailAccountModel.name = string;
        }
        else if (_mailAttachmentModel) {
            _mailAttachmentModel.name = string;
            [_itemContentModel.attachmentList addObject:_mailAttachmentModel];
        }
    }
    else if ([currentElement isEqualToString:@"t:EmailAddress"]) {
        _mailAccountModel.emailAddress = string;
    }
    else if ([currentElement isEqualToString:@"t:RoutingType"]) {
        _mailAccountModel.routingType = string;
        if (_itemContentModel.fromList) {
            [_itemContentModel.fromList addObject:_mailAccountModel];
        }
        else if (_itemContentModel.ccRecipientsList){
            [_itemContentModel.ccRecipientsList addObject:_mailAccountModel];
        }
        else if (_itemContentModel.toRecipientsList){
            [_itemContentModel.toRecipientsList addObject:_mailAccountModel];
        }
    }
    else if ([currentElement isEqualToString:@"t:IsReadReceiptRequested"]) {
        if ([string isEqualToString:@"true"]) {
            _itemContentModel.isReadReceiptRequested = YES;
        }
        else{
            _itemContentModel.isReadReceiptRequested = NO;
        }
    }
    else if ([currentElement isEqualToString:@"t:IsDeliveryReceiptRequested"]) {
        if ([string isEqualToString:@"true"]) {
            _itemContentModel.isDeliveryReceiptRequested = YES;
        }
        else{
            _itemContentModel.isDeliveryReceiptRequested = NO;
        }
    }
    else if ([currentElement isEqualToString:@"t:IsRead"]){
        if ([string isEqualToString:@"true"]) {
            _itemContentModel.isRead = YES;
        }
        else{
            _itemContentModel.isRead = NO;
        }
    }
    else if ([currentElement isEqualToString:@"t:ContentType"]){
        _mailAttachmentModel.contentType = string;
    }
    else if ([currentElement isEqualToString:@"t:ContentId"]) {
        _mailAttachmentModel.contentId = string;
    }
}

-(void)itemContentDidEndDocument{
    _itemContentModel.itemContentHtmlString = _contentString;
    
    if (_getItemContentBlock) {
        _getItemContentBlock(_itemContentModel, _error);
    }
}

@end
