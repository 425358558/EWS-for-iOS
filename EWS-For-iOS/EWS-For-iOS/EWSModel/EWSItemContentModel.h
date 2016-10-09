//
// EWSItemContentModel.h
// EWS-For-iOS
//
// Copyright (c) 2016 wangxk
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
