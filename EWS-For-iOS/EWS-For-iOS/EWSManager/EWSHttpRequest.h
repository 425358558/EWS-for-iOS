//
//  EWSHttpRequest.h
//  SSAnimationBox
//
//  Created by wangxk on 16/6/23.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWSEmailBoxModel.h"

typedef void  (^HttpRequestReceiveResponseBlock)(NSURLResponse *response);
typedef void  (^HttpRequestErrorBlock)(NSError *error);
typedef void  (^HttpRequestReceiveDataBlock)(NSData *data);
typedef void  (^HttpRequestDidFinishLoadingBlock)();

@interface EWSHttpRequest : NSObject

@property (nonatomic, strong) EWSEmailBoxModel *emailBoxModel;

-(void)ewsHttpRequest:(NSString *)soapXmlString andUrl:(NSString *)url receiveResponse:(void (^)(NSURLResponse *response))receiveResponseBlock reveiveData:(void (^)(NSData *data))receiveDataBlock finishLoading:(void (^)())finishLoadingBlock error:(void (^)(NSError *error))errorBlock;

-(void)ewsHttpRequest:(NSString *)soapXmlString andUrl:(NSString *)url emailBoxInfo:(EWSEmailBoxModel *)emailBoxInfo receiveResponse:(void (^)(NSURLResponse *response))receiveResponseBlock reveiveData:(void (^)(NSData *data))receiveDataBlock finishLoading:(void (^)())finishLoadingBlock error:(void (^)(NSError *error))errorBlock;

@end
