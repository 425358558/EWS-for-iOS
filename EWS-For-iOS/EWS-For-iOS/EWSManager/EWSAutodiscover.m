//
// EWSAutodiscover.m
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

#import "EWSAutodiscover.h"
#import "EWSHttpRequest.h"
#import "EWSXmlParser.h"
#import "EWSManager.h"

typedef void (^GetEWSUrlBlock)(NSString *ewsUrl, NSError *error);

@implementation EWSAutodiscover{
     NSMutableArray *autodiscoverAddressList;

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
    autodiscoverAddressList = [[NSMutableArray alloc] init];
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

- (void)pushAutoDiscoverUrlList:(NSString *)url{
    [autodiscoverAddressList addObject:url];
}

- (NSString *)popAutoDiscoverUrl{

    NSString *url = autodiscoverAddressList.lastObject;

    [autodiscoverAddressList removeLastObject];

    return url;
}

-(void)autoDiscoverWithEmailAddress:(NSString *)emailAddress finishBlock:(void(^)(NSString *ewsUrl, NSError *error))getEWSUrlBlock{

    NSString *soapXmlString = [NSString stringWithFormat:
                               @"<Autodiscover xmlns=\"http://schemas.microsoft.com/exchange/autodiscover/outlook/requestschema/2006\">\n"
                               "<Request>\n"
                               "<EMailAddress>%@</EMailAddress>\n"
                               "<AcceptableResponseSchema>http://schemas.microsoft.com/exchange/autodiscover/outlook/responseschema/2006a</AcceptableResponseSchema>\n"
                               "</Request>\n"
                               "</Autodiscover>\n",emailAddress];
    
    [self setAutodiscoverAddressList:emailAddress];
    
    EWSEmailBoxModel *ebInfo = ((EWSManager *)[EWSManager sharedEwsManager]).ewsEmailBoxModel;

    [self attemptAutoDiscoverForEmailBoxInfo:ebInfo soapXmlString:soapXmlString finishBlock:getEWSUrlBlock];

}

- (void)attemptAutoDiscoverForEmailBoxInfo:(EWSEmailBoxModel *)ebInfo soapXmlString:(NSString *)soapXmlString finishBlock:(void(^)(NSString *ewsUrl, NSError *error))getEWSUrlBlock {

    NSString *url = [self popAutoDiscoverUrl];

    NSLog(@"\n\n------------Attempting autodiscovery via url-------------\n\n%@\n\n-", url);
//    NSLog(@"\n\n------------Credentials-------------\n\n%@\n%@\n-", ebInfo.emailAddress, ebInfo.password);

    if (!url)
    {

        getEWSUrlBlock(nil, [[NSError alloc] initWithDomain:@"EWS.autodiscovery.url" code:-1 userInfo:nil]);

        return;
    }

    __weak EWSAutodiscover *weakSelf = self;

    EWSHttpRequest *request = [[EWSHttpRequest alloc] init];

    [request ewsHttpRequest:soapXmlString url:url emailBoxInfo:ebInfo success:^(NSString *redirectLocation, NSData *xmlData) {

        if (redirectLocation) {
            NSLog(@"\n\n------------Received Redirection url location-------------\n\n%@\n\n-", redirectLocation);

            [weakSelf pushAutoDiscoverUrlList:redirectLocation];
        }

        [self checkForEWSUrlInReceivedData:xmlData withCompletionHandler:^(NSString *ewsUrl) {

                if (ewsUrl)
                {
                    NSLog(@"\n\n------------Received Autheticated EWS url-------------\n\n%@\n\n-", ewsUrl);

                    getEWSUrlBlock(ewsUrl, nil);

                }
                else
                {
                    // try next url
                    [weakSelf attemptAutoDiscoverForEmailBoxInfo:ebInfo soapXmlString:soapXmlString finishBlock:getEWSUrlBlock];
                }
            }];

    } failure:^(NSError *error) {

        NSLog(@"error: %@", error);
        // try next url
        [weakSelf attemptAutoDiscoverForEmailBoxInfo:ebInfo soapXmlString:soapXmlString finishBlock:getEWSUrlBlock];
    }];
}

-(void)checkForEWSUrlInReceivedData:(NSData *)data withCompletionHandler:(void(^)(NSString* ewsUrl))completion {

    if (!data.bytes)
    {
        completion(nil);

        return;
    }

    EWSXmlParser * parser = [[EWSXmlParser alloc] init];

    [parser parserWithData:data didStartDocument:^{
        
    } didStartElementBlock:^(NSString *elementName, NSString *namespaceURI, NSString *qName, NSDictionary *attributeDict) {
        currentElement = elementName;
        
    } foundCharacters:^(NSString *string) {

        if ([currentElement isEqualToString:@"EwsUrl"]) {
            ewsUrl = [NSString stringWithString:string];
        }

    } didEndElementBlock:^(NSString *elementName, NSString *namespaceURI, NSString *qName) {
        
        currentElement = nil;
    } didEndDocument:^{

        ewsUrl ? completion(ewsUrl) : completion(nil);
    }];
}

@end
