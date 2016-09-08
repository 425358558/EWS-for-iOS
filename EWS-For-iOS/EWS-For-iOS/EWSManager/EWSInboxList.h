//
//  EWSInboxList.h
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/29.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EWSInboxList : NSObject

-(void)getInboxListWithEWSUrl:(NSString *)url finishBlock:(void(^)(NSMutableArray *inboxList, NSError *error))getInboxListBlock;

@end
