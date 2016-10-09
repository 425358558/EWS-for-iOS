//
// EWSHttpRequest.m
// SSAnimationBox
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
