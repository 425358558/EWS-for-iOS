//
//  EWSInboxListModel.h
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/30.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EWSInboxListModel : NSObject

@property (nonatomic, strong) NSString *changeKey;
@property (nonatomic, strong) NSString *itemId;
@property (nonatomic, strong) NSString *itemType;

@end
