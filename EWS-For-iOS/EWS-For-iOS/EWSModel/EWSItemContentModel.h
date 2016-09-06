//
//  EWSItemContentModel.h
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/30.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWSInboxListModel.h"
#import "EWSMailAccountModel.h"
#import "EWSMailAttachmentModel.h"

@interface EWSItemContentModel : NSObject

@property (nonatomic, strong) EWSInboxListModel *itemInfo;       //邮件id信息
@property (nonatomic, strong) NSString *itemSubject;           //邮件标题
@property (nonatomic, strong) NSString *itemContentHtmlString;    //邮件内容（html）
@property (nonatomic, strong) NSString *dateTimeSentStr;
@property (nonatomic, strong) NSString *dateTimeCreatedStr;
@property (nonatomic, strong) NSMutableArray *toRecipientsList;        //EWSMailAccountModel数组，收件人
@property (nonatomic, strong) NSMutableArray *ccRecipientsList;       //EWSMailAccountModel数组，抄送
@property (nonatomic, strong) NSMutableArray *fromList;               //EWSMailAccountModel数组，发件人
@property (nonatomic) BOOL isRead;
@property (nonatomic, strong) NSString *size;
@property (nonatomic) BOOL hasAttachments;
@property (nonatomic, strong) NSMutableArray *attachmentList;    //EWSMailAttachmentModel数组
@property (nonatomic) BOOL isReadReceiptRequested;
@property (nonatomic) BOOL isDeliveryReceiptRequested;

@end
