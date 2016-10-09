//
// EWSMailAttachment.m
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

#import "EWSMailAttachment.h"
#import "EWSHttpRequest.h"
#import "EWSXmlParser.h"

typedef void (^GetAttachmentCompleteBlock)();

@implementation EWSMailAttachment{
    EWSHttpRequest *request;
    NSMutableData *eData;
    EWSXmlParser *parser;
    
    NSString *currentElement;
    EWSMailAttachmentModel *_mailAttachmentModel;
    
    GetAttachmentCompleteBlock _getAttachmentCompleteBlock;
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
    request = [[EWSHttpRequest alloc] init];
    eData = [[NSMutableData alloc] init];
    parser = [[EWSXmlParser alloc] init];
}


-(void)getAttachmentWithEWSUrl:(NSString *)url attachmentInfo:(EWSMailAttachmentModel *)attachmentInfo complete:(void (^)())completeBlock{
    _getAttachmentCompleteBlock = completeBlock;
    _mailAttachmentModel = attachmentInfo;
    NSString *soapXmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                               "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\n"
                               "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"\n"
                               "xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\"\n"
                               "xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\n"
                               "<soap:Body>\n"
                               "<GetAttachment xmlns=\"http://schemas.microsoft.com/exchange/services/2006/messages\"\n"
                               "xmlns:t=\"http://schemas.microsoft.com/exchange/services/2006/types\">\n"
                               "<AttachmentShape>\n"
                               "<t:IncludeMimeContent>true</t:IncludeMimeContent>\n"
                               "</AttachmentShape>\n"
                               "<AttachmentIds>\n"
                               "<t:AttachmentId Id=\"%@\"/>\n"
                               "</AttachmentIds>\n"
                               "</GetAttachment>\n"
                               "</soap:Body>\n"
                               "</soap:Envelope>\n",attachmentInfo.attachmentId];
    
    [request ewsHttpRequest:soapXmlString andUrl:url receiveResponse:^(NSURLResponse *response) {
        NSLog(@"response:%@",response);
    } reveiveData:^(NSData *data) {
        [eData appendData:data];
    } finishLoading:^{
//        NSLog(@"data:%@",[[NSString alloc] initWithData:eData encoding:NSUTF8StringEncoding]);
        NSLog(@"---attachment---finish-------");
        [self requestFinishLoading];
    } error:^(NSError *error) {
        NSLog(@"error:%@",error);
    }];
}

-(void)requestFinishLoading{
    [parser parserWithData:eData didStartDocument:^{
        
    } didStartElementBlock:^(NSString *elementName, NSString *namespaceURI, NSString *qName, NSDictionary *attributeDict) {
        currentElement = elementName;
    } foundCharacters:^(NSString *string) {
        [self attachmentFoundCharacters:string];
    } didEndElementBlock:^(NSString *elementName, NSString *namespaceURI, NSString *qName) {
        currentElement = nil;
    } didEndDocument:^{
        [self mailAttachmentDidEndDocument];
    }];
}

-(void)attachmentFoundCharacters:(NSString *)string{
    if ([currentElement isEqualToString:@"t:Content"]) {
        NSData *xmlData = [[NSData alloc] initWithBase64EncodedString:string options:0];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
//        NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"EWSMailAttachments/%@",_mailAttachmentModel.name]];
        NSString *fullPathToFile = [documentsDirectory stringByAppendingPathComponent:_mailAttachmentModel.name];
        
        [xmlData writeToFile:fullPathToFile atomically:YES];
        _mailAttachmentModel.attachmentPath = fullPathToFile;
    }
    
}

-(void)mailAttachmentDidEndDocument{
    if (_getAttachmentCompleteBlock) {
        _getAttachmentCompleteBlock();
    }
    request = nil;
    parser = nil;
    eData = nil;
}

@end
