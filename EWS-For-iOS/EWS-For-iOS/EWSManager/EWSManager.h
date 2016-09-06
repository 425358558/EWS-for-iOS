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

@end
