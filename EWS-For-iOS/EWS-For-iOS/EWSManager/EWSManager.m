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
#import "EWSInboxListModel.h"
#import "EWSItemContent.h"

static EWSManager *instance = nil;

typedef void (^ManagerGetAllItemContentBlock)(NSArray *allItemArray, NSError *error);

@implementation EWSManager{
    NSArray *_inboxList;
    NSMutableArray *_allItemContentArray;
    NSError *_error;
    
    ManagerGetAllItemContentBlock _managerGetAllItemContentBlock;
}

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
    ewsEmailBoxModel.mailBoxDescription = description;
    ewsEmailBoxModel.mailServerAddress = mailServerAddress;
    ewsEmailBoxModel.domain = domain;
    
    if (!(ewsEmailBoxModel.emailAddress&&ewsEmailBoxModel.password)) {
        NSLog(@"emailAddress and password can't be nil");
    }
    else if (!ewsEmailBoxModel.mailServerAddress||[ewsEmailBoxModel.mailServerAddress isEqualToString:@""]) {
        [self autodiscover];
    }
    
}

-(void)autodiscover{
    [[[EWSAutodiscover alloc] init] autoDiscoverWithEmailAddress:ewsEmailBoxModel.emailAddress finishBlock:^(NSString *ewsUrl, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        }
        ewsEmailBoxModel.mailServerAddress = ewsUrl;
    }];
}

-(void)getInboxList{
    [[[EWSInboxList alloc] init] getInboxListWithEWSUrl:ewsEmailBoxModel.mailServerAddress finishBlock:^(NSMutableArray *inboxList, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        }
        
    }];
    
}

-(void)getItemnContentWithInboxListModel:(EWSInboxListModel *)model{
    [[[EWSItemContent alloc] init] getItemContentWithEWSUrl:ewsEmailBoxModel.mailServerAddress item:model finishBlock:^(EWSItemContentModel *itemContentInfo, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        }
        NSLog(@"---content:%@-%@-%@-%@---",itemContentInfo.itemSubject,itemContentInfo.itemContentHtmlString,itemContentInfo.dateTimeSentStr,itemContentInfo.size);
    }];
}



-(void)getAllItemContent:(void (^)(NSArray *allItemArray, NSError *error))managerGetAllItemContentBlock{
    _managerGetAllItemContentBlock = managerGetAllItemContentBlock;
    [[[EWSInboxList alloc] init] getInboxListWithEWSUrl:ewsEmailBoxModel.mailServerAddress finishBlock:^(NSMutableArray *inboxList, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        }
        _inboxList = inboxList;
        _allItemContentArray = [[NSMutableArray alloc] init];
        [self getItemContentRecursion:0];
    }];
    
}

-(void)getItemContentRecursion:(int)index{
    if (index<_inboxList.count) {
        [[[EWSItemContent alloc] init] getItemContentWithEWSUrl:ewsEmailBoxModel.mailServerAddress item:_inboxList[index] finishBlock:^(EWSItemContentModel *itemContentInfo, NSError *error) {
            if (error) {
                _error = error;
            }
            [_allItemContentArray addObject:itemContentInfo];
            [self getItemContentRecursion:index+1];
        }];
    }
    else{
        if (_managerGetAllItemContentBlock) {
            
            _managerGetAllItemContentBlock([_allItemContentArray copy], _error);
        }
    }
}

@end
