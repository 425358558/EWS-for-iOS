//
//  EWSMailAttachmentModel.h
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/30.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EWSMailAttachmentModel : NSObject

@property (nonatomic, strong) NSString *attachmentId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) NSUInteger attachmentType;
@property (nonatomic, strong) NSString *contentType;
@property (nonatomic, strong) NSString *contentId;
@property (nonatomic, strong) NSString *attachmentPath;

@end
