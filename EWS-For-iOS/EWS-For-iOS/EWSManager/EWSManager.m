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
#import "EWSItemContent.h"
#import "EWSMailAttachment.h"

static EWSManager *instance = nil;

typedef void (^ManagerGetAllItemContentBlock)(NSArray *allItemArray, NSError *error);
typedef void (^ManagerGetItemContentBlock)(EWSItemContentModel *model, NSError *error);
typedef void (^ManagerGetAllAttachmentCompleteBlock)();
typedef void (^ManagerGetInboxListBlock)(NSArray *inboxList, NSError *error);
typedef void (^ManagerGetAttachmentCompleteBlock)();

@implementation EWSManager{
    NSArray *_inboxList;
    NSMutableArray *_allItemContentArray;
    NSError *_error;
    
    ManagerGetAllItemContentBlock _managerGetAllItemContentBlock;
    ManagerGetItemContentBlock _managerGetItemContentBlock;
    ManagerGetAllAttachmentCompleteBlock _managerGetAllAttachmentCompleteBlock;
    ManagerGetInboxListBlock _managerGetInboxListBlock;
    ManagerGetAttachmentCompleteBlock _managerGetAttachmentCompleteBlock;
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

-(void)getInboxListComplete:(void (^)(NSArray *inboxList, NSError *error))managerGetInboxListBlock{
    _managerGetInboxListBlock = managerGetInboxListBlock;
    [[[EWSInboxList alloc] init] getInboxListWithEWSUrl:ewsEmailBoxModel.mailServerAddress finishBlock:^(NSMutableArray *inboxList, NSError *error) {
        if (error) {
            _error = error;
        }
        else{
            _error = nil;
        }
        if (_managerGetInboxListBlock) {
            _managerGetInboxListBlock([inboxList copy],error);
            [inboxList removeAllObjects];
            inboxList = nil;
        }
        
    }];
    
}

-(void)getItemnContentWithInboxListModel:(EWSInboxListModel *)model complete:(void (^)(EWSItemContentModel *model, NSError *error))managerGetItemContentBlock{
    _managerGetItemContentBlock = managerGetItemContentBlock;
    [[[EWSItemContent alloc] init] getItemContentWithEWSUrl:ewsEmailBoxModel.mailServerAddress item:model finishBlock:^(EWSItemContentModel *itemContentInfo, NSError *error) {
        if (error) {
            _error = error;
        }
        else{
            _error = nil;
        }
        if (_managerGetItemContentBlock) {
            _managerGetItemContentBlock(itemContentInfo, _error);
        }
    }];
}



-(void)getAllItemContent:(void (^)(NSArray *allItemArray, NSError *error))managerGetAllItemContentBlock{
    _managerGetAllItemContentBlock = managerGetAllItemContentBlock;
    [[[EWSInboxList alloc] init] getInboxListWithEWSUrl:ewsEmailBoxModel.mailServerAddress finishBlock:^(NSMutableArray *inboxList, NSError *error) {
        if (error) {
            NSLog(@"GetInboxListError:%@",error);
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
            else{
                _error = nil;
            }
            
            [_allItemContentArray addObject:itemContentInfo];
            [self getItemContentRecursion:index+1];
        }];
    }
    else{
        if (_managerGetAllItemContentBlock) {
            
            _managerGetAllItemContentBlock([_allItemContentArray copy], _error);
            
            [_allItemContentArray removeAllObjects];
            _allItemContentArray = nil;
        }
    }
}

-(void)getMailAllAttachmentWithItemContentInfo:(EWSItemContentModel *)itemContentInfo complete:(void (^)())managerGetAllAttachmentCompleteBlock{
    _managerGetAllAttachmentCompleteBlock = managerGetAllAttachmentCompleteBlock;
    [self getMailAttachmentRecursion:itemContentInfo index:0];
}

-(void)getMailAttachmentRecursion:(EWSItemContentModel *)itemContentInfo index:(int)i {
    [[[EWSMailAttachment alloc] init] getAttachmentWithEWSUrl:ewsEmailBoxModel.mailServerAddress attachmentInfo:itemContentInfo.attachmentList[i] complete:^{
        if (i==itemContentInfo.attachmentList.count-1) {
            if (_managerGetAllAttachmentCompleteBlock) {
                _managerGetAllAttachmentCompleteBlock();
            }
        }
        else{
            [self getMailAttachmentRecursion:itemContentInfo index:i+1];
        }
    }];
}

-(void)getMailAttachmentWithAttachmentModel:(EWSMailAttachmentModel *)attachmentModel complete:(void (^)())managerGetAttachmentCompleteBlock{
    _managerGetAttachmentCompleteBlock = managerGetAttachmentCompleteBlock;
}

@end
