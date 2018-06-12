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
#import "EWSEmailBoxModel.h"

@interface EWSHttpRequest () <NSURLSessionDelegate>

@property (strong, nonatomic) NSMutableData *data;
@property (strong, nonatomic) NSString *redirectLocation;
@property (strong, nonatomic) EWSEmailBoxModel *emailBoxModel;
@property (copy, nonatomic) HTTPRequestSuccessCompletion successBlock;
@property (copy, nonatomic) HTTPRequestFailureCompletion failureBlock;

@end


@implementation EWSHttpRequest

- (void)ewsHttpRequest:(NSString *)soapXmlString url:(NSString *)url emailBoxInfo:(EWSEmailBoxModel *)emailBoxInfo success:(HTTPRequestSuccessCompletion)success failure:(HTTPRequestFailureCompletion)failure
{
    self.emailBoxModel = emailBoxInfo;

    self.successBlock = success;
    self.failureBlock = failure;
    self.data = [NSMutableData data];

    NSURL *requestUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestUrl];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 20.0;

    if (soapXmlString)
    {
        NSString *xmlLength = [NSString stringWithFormat:@"%ld", (unsigned long)soapXmlString.length];
        request.HTTPBody = [soapXmlString dataUsingEncoding:NSUTF8StringEncoding];
        [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request addValue:xmlLength forHTTPHeaderField:@"Content-Length"];
    }

    dispatch_async(dispatch_get_main_queue(), ^{

        NSURLSessionConfiguration *defaultConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];

        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfiguration
                                                                     delegate:self
                                                                delegateQueue:nil];

        NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:request];

        [dataTask resume];
    });
}

-(void)ewsHttpRequest:(NSString *)soapXmlString andUrl:(NSString *)url emailBoxInfo:(EWSEmailBoxModel *)emailBoxInfo receiveResponse:(void (^)(NSURLResponse *response))receiveResponseBlock finishLoading:(void (^)(NSData *data))finishLoadingBlock error:(void (^)(NSError *error))errorBlock{

    [self ewsHttpRequest:soapXmlString url:url emailBoxInfo:emailBoxInfo success:^(NSString *redirectLocation, NSData *xmlData) {

        NSString *xmlString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];

        NSLog(@"xmlString Data: %@", xmlString);
        finishLoadingBlock(xmlData);

    } failure:^(NSError *error) {

        errorBlock(error);
    }];

}

#pragma mark - NSURLSession Delegates

-(void)URLSession:(NSURLSession *)session
             task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{

    if (challenge.previousFailureCount == 0)
    {
        NSURLCredential* credential;

        credential = [NSURLCredential credentialWithUser:self.emailBoxModel.emailAddress password:self.emailBoxModel.password persistence:NSURLCredentialPersistenceForSession];

        [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];

        completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
    }
    else
    {
        // URLSession:task:didCompleteWithError in case of wrong credentials.

        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }

}

-(void)URLSession:(NSURLSession *)session
         dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    completionHandler(NSURLSessionResponseAllow);
}

-(void)URLSession:(NSURLSession *)session
         dataTask:(NSURLSessionDataTask *)dataTask
   didReceiveData:(NSData *)data
{

    [self.data appendData:data];
}

-(void)URLSession:(NSURLSession *)session
             task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    if (error)
    {
        self.failureBlock ? self.failureBlock(error) : nil;

    }
    else
    {
        NSData *data;

        if (self.data)
        {
            data = [NSData dataWithData:self.data];
        }

        self.successBlock ? self.successBlock(self.redirectLocation, data) : nil;
    }

    [session finishTasksAndInvalidate]; // release the session, else it holds strong referance for it's delegate (in our case EWSHTTPRequest).
    // And it wont allow the delegate object to free -> cause memory leak
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * _Nullable))completionHandler;

{

    self.redirectLocation = request.URL.absoluteString;

    if (response)
    {
        completionHandler(nil);
    }
    else
    {
        completionHandler(request); // new redirect request
    }
}
@end
