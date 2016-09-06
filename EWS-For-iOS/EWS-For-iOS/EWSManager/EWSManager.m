//
//  EWSManager.m
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/18.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import "EWSManager.h"

static EWSManager *instance = nil;

@implementation EWSManager

@synthesize ewsEmailBoxModel;

-(instancetype)init{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    return self;
}

+(id)sharedEwsManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[EWSManager alloc] init];
    });
    return instance;
}

//-(void)setEmailBoxInfoEmailAddress:(NSString *)emailAddress password:(NSString *)password description:(NSString *)description mailServerAddress:(NSString *)mailServerAddress domain:(NSString *)domain{
//    ewsEmailBoxModel = [[EWSEmailBoxModel alloc] init];
//    ewsEmailBoxModel.emailAddress = emailAddress;
//    ewsEmailBoxModel.password = password;
//    ewsEmailBoxModel.description = description;
//    ewsEmailBoxModel.mailServerAddress = mailServerAddress;
//    ewsEmailBoxModel.domain = domain;
//}

-(void)autodiscover{
    if (ewsEmailBoxModel) {
        
    }
}

@end
