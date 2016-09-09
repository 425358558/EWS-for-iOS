//
//  EWSManager.h
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/18.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWSEmailBoxModel.h"

@interface EWSManager : NSObject

@property (nonatomic, strong) EWSEmailBoxModel *ewsEmailBoxModel;

+(id)sharedEwsManager;

-(void)setEmailBoxInfoEmailAddress:(NSString *)emailAddress password:(NSString *)password description:(NSString *)description mailServerAddress:(NSString *)mailServerAddress domain:(NSString *)domain;

-(void)getAllItemContent;

@end
