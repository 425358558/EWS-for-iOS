//
//  EWSAutodiscover.m
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/18.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import "EWSAutodiscover.h"
#import "EWSHttpRequest.h"
#import "EWSXmlParser.h"
#import "EWSManager.h"

typedef void (^GetEWSUrlBlock)(NSString *ewsUrl, NSError *error);

@implementation EWSAutodiscover{
    EWSHttpRequest *request;
    EWSXmlParser *parser;
    
    NSMutableArray *autodiscoverAddressList;
    NSMutableData *eData;
    
    GetEWSUrlBlock _getEWSUrlBlock;
    
    NSString *currentElement;
    NSString *ewsUrl;
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
    request = [[EWSHttpRequest alloc] init];
    autodiscoverAddressList = [[NSMutableArray alloc] init];
    eData = [[NSMutableData alloc] init];
    parser = [[EWSXmlParser alloc] init];
}

-(void)setAutodiscoverAddressList:(NSString *)emailAddress{
    if (emailAddress) {
        NSArray *address = [emailAddress componentsSeparatedByString:@"@"];
        [autodiscoverAddressList addObject:[NSString stringWithFormat:@"https://autodiscover.%@/autodiscover/autodiscover.xml",[address objectAtIndex:1]]];
        [autodiscoverAddressList addObject:[NSString stringWithFormat:@"https://%@/autodiscover/autodiscover.xml",[address objectAtIndex:1]]];
        [autodiscoverAddressList addObject:[NSString stringWithFormat:@"https://email.%@/autodiscover/autodiscover.xml",[address objectAtIndex:1]]];
    }
    else{
        NSLog(@"error:Could not find emailAddress!");
    }
}

-(void)autoDiscoverWithEmailAddress:(NSString *)emailAddress finishBlock:(void(^)(NSString *ewsUrl, NSError *error))getEWSUrlBlock{
    _getEWSUrlBlock = [getEWSUrlBlock copy];
    
    NSString *soapXmlString = [NSString stringWithFormat:
                               @"<Autodiscover xmlns=\"http://schemas.microsoft.com/exchange/autodiscover/outlook/requestschema/2006\">\n"
                               "<Request>\n"
                               "<EMailAddress>%@</EMailAddress>\n"
                               "<AcceptableResponseSchema>http://schemas.microsoft.com/exchange/autodiscover/outlook/responseschema/2006a</AcceptableResponseSchema>\n"
                               "</Request>\n"
                               "</Autodiscover>\n",emailAddress];
    
    [self setAutodiscoverAddressList:emailAddress];
    
    EWSEmailBoxModel *ebInfo = ((EWSManager *)[EWSManager sharedEwsManager]).ewsEmailBoxModel;
    
    for (NSString *url in autodiscoverAddressList) {
        [request ewsHttpRequest:soapXmlString andUrl:url emailBoxInfo:ebInfo receiveResponse:^(NSURLResponse *response) {
            NSLog(@"response:%@",response);
        } reveiveData:^(NSData *data) {
            [eData appendData:data];
        } finishLoading:^{
            NSLog(@"data:%@",[[NSString alloc] initWithData:eData encoding:NSUTF8StringEncoding]);
            [self requestFinishLoading];
        } error:^(NSError *error) {
            _error = error;
        }];
    }
}

-(void)requestFinishLoading{
    [parser parserWithData:eData didStartDocument:^{
        
    } didStartElementBlock:^(NSString *elementName, NSString *namespaceURI, NSString *qName, NSDictionary *attributeDict) {
        currentElement = elementName;
        
    } foundCharacters:^(NSString *string) {
        
        [self autodiscoverFoundCharacters:string];
    } didEndElementBlock:^(NSString *elementName, NSString *namespaceURI, NSString *qName) {
        
        currentElement = nil;
    } didEndDocument:^{
        
        [self autodiscoverDidEndDocument];
    }];
}

-(void)autodiscoverFoundCharacters:(NSString *)string{
    if ([currentElement isEqualToString:@"EwsUrl"] && !ewsUrl) {
        ewsUrl = [NSString stringWithString:string];
    }
}

-(void)autodiscoverDidEndDocument{
    if (_getEWSUrlBlock) {
        _getEWSUrlBlock(ewsUrl, _error);
    }
}

@end
