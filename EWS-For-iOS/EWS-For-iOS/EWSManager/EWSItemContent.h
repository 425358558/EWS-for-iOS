//
//  EWSItemContent.h
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/30.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWSInboxListModel.h"
#import "EWSItemContentModel.h"

@interface EWSItemContent : NSObject

-(void)getItemContentWithEWSUrl:(NSString *)url item:(EWSInboxListModel *)item finishBlock:(void (^)(EWSItemContentModel *itemContentInfo, NSError *error))getItemContentBlock;

@end
