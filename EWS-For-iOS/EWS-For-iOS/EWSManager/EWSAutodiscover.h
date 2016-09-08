//
//  EWSAutodiscover.h
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/18.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EWSAutodiscover : NSObject

-(void)autoDiscoverWithEmailAddress:(NSString *)emailAddress finishBlock:(void(^)(NSString *ewsUrl, NSError *error))getEWSUrlBlock;

@end
