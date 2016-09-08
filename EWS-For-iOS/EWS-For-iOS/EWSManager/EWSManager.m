//
//  EWSManager.m
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/18.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import "EWSManager.h"
#import "EWSAutodiscover.h"
#import "EWSInboxList.h"

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

-(void)setEmailBoxInfoEmailAddress:(NSString *)emailAddress password:(NSString *)password description:(NSString *)description mailServerAddress:(NSString *)mailServerAddress domain:(NSString *)domain{
    ewsEmailBoxModel = [[EWSEmailBoxModel alloc] init];
    ewsEmailBoxModel.emailAddress = emailAddress;
    ewsEmailBoxModel.password = password;
    ewsEmailBoxModel.description = description;
    ewsEmailBoxModel.mailServerAddress = mailServerAddress;
    ewsEmailBoxModel.domain = domain;
    
    if (!(ewsEmailBoxModel.emailAddress&&ewsEmailBoxModel.password)) {
        NSLog(@"emailAddress and password can't be nil");
    }
    else if (!ewsEmailBoxModel.mailServerAddress) {
        [self autodiscover];
    }
    
}

-(void)autodiscover{
    if (ewsEmailBoxModel) {
        [[[EWSAutodiscover alloc] init] autoDiscoverWithEmailAddress:ewsEmailBoxModel.emailAddress finishBlock:^(NSString *ewsUrl, NSError *error) {
            if (error) {
                NSLog(@"error:%@",error);
                return ;
            }
            ewsEmailBoxModel.mailServerAddress = ewsUrl;
        }];
    }
}

-(NSArray *)getInboxList{
    __block NSArray *list;
    if (ewsEmailBoxModel) {
        [[[EWSInboxList alloc] init] getInboxListWithEWSUrl:ewsEmailBoxModel.mailServerAddress finishBlock:^(NSMutableArray *inboxList, NSError *error) {
            if (error) {
                NSLog(@"error:%@",error);
                return ;
            }
            list = [inboxList copy];
        }];
    }
    
    return list;
}

-(NSArray *)getAllItemContent{
    NSArray *inboxList = [self getInboxList];
    if (ewsEmailBoxModel) {
        <#statements#>
    }
}

@end
