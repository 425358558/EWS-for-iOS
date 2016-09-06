//
//  EWSEmailBoxModel.h
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/18.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EWSEmailBoxModel : NSObject

@property (nonatomic, strong) NSString *emailAddress;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *ewsUrl;
@property (nonatomic, strong) NSString *mailServerAddress;
@property (nonatomic, strong) NSString *domain;

@end
