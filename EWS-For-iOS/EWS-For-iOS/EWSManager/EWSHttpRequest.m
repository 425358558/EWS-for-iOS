//
//  EWSHttpRequest.m
//  SSAnimationBox
//
//  Created by wangxk on 16/6/23.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import "EWSHttpRequest.h"

typedef void  (^HttpRequestReceiveResponseBlock)(NSURLResponse *response);
typedef void  (^HttpRequestErrorBlock)(NSError *error);
typedef void  (^HttpRequestReceiveDataBlock)(NSData *data);
typedef void  (^HttpRequestDidFinishLoadingBlock)();

@implementation EWSHttpRequest{
    HttpRequestReceiveResponseBlock _receiveResponseBlock;
    HttpRequestReceiveDataBlock _receiveDataBlock;
    HttpRequestDidFinishLoadingBlock _finishLoadingBlock;
    HttpRequestErrorBlock _errorBlock;
}


-(void)ewsHttpRequest:(NSString *)soapXmlString andUrl:(NSString *)url emailBoxInfo:(EWSEmailBoxModel *)emailBoxInfo receiveResponse:(void (^)(NSURLResponse *response))receiveResponseBlock reveiveData:(void (^)(NSData *data))receiveDataBlock finishLoading:(void (^)())finishLoadingBlock error:(void (^)(NSError *error))errorBlock{
    
    self.emailBoxModel = emailBoxInfo;
    [self ewsHttpRequest:soapXmlString andUrl:url receiveResponse:receiveResponseBlock reveiveData:receiveDataBlock finishLoading:finishLoadingBlock error:errorBlock];
    
}

-(void)ewsHttpRequest:(NSString *)soapXmlString andUrl:(NSString *)url receiveResponse:(void (^)(NSURLResponse *response))receiveResponseBlock reveiveData:(void (^)(NSData *data))receiveDataBlock finishLoading:(void (^)())finishLoadingBlock error:(void (^)(NSError *error))errorBlock{
    
    [self httpRequest:soapXmlString andUrl:url];
    
    _receiveResponseBlock = [receiveResponseBlock copy];
    _receiveDataBlock = [receiveDataBlock copy];
    _finishLoadingBlock = [finishLoadingBlock copy];
    _errorBlock = [errorBlock copy];
}




-(void)httpRequest:(NSString *)soapXmlString andUrl:(NSString *)url{
    NSString *xmlLength = [NSString stringWithFormat:@"%ld",soapXmlString.length];
    
    NSURL *requestUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestUrl];
    [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue: xmlLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[soapXmlString dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if (conn == nil) {
        NSLog(@"NSURLConnection init error!");
    }
}


#pragma mark - delegate
-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(nonnull NSURLAuthenticationChallenge *)challenge{
    
    if ([challenge previousFailureCount]) {
        
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
    else {
        
        NSURLCredential *credential = [NSURLCredential credentialWithUser:self.emailBoxModel.emailAddress
                                                                 password:self.emailBoxModel.password
                                                              persistence:NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    
    _receiveResponseBlock(response);
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    
    _receiveDataBlock(data);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    _errorBlock(error);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection{
    
    _finishLoadingBlock();
}

@end
