//
//  EWSMailAccountModel.h
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/30.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EWSMailAccountModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic, strong) NSString *routingType;

@end
