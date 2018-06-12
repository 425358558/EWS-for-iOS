//
// EWSManager.h
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
#import "EWSEmailBoxModel.h"
#import "EWSInboxListModel.h"
#import "EWSItemContentModel.h"

@interface EWSManager : NSObject

@property (nonatomic, strong) EWSEmailBoxModel *ewsEmailBoxModel;

+(id)sharedEwsManager;

/**
 *  设置邮箱信息
 *
 *  @param emailAddress      邮箱地址（必填）
 *  @param password          邮箱密码（必填）
 *  @param description       邮箱描述
 *  @param mailServerAddress 邮箱服务器地址（如果没有设置就会用autodiscover去尝试寻找）
 *  @param domain            域
 *  @param completion        completionHandles, returns true, if everything went well
 */
-(void)setEmailBoxInfoEmailAddress:(NSString *)emailAddress
                          password:(NSString *)password
                       description:(NSString *)description
                 mailServerAddress:(NSString *)mailServerAddress
                            domain:(NSString *)domain
                        completion:(void(^)(BOOL success))completion;

/**
 *  获取邮箱列表
 *
 *  @param managerGetInboxListBlock 返回EWSInboxListModel数组和错误信息
 */
-(void)getInboxListComplete:(void (^)(NSArray *inboxList, NSError *error))managerGetInboxListBlock;

/**
 *  获取所有邮件内容（不包含附件）
 *
 *  @param managerGetAllItemContentBlock 返回邮件EWSItemContentModel数组和错误信息
 */
-(void)getAllItemContent:(void (^)(NSArray *allItemArray, NSError *error))managerGetAllItemContentBlock;

/**
 *  获取特定EWSInboxListModel
 *
 *  @param model                      邮件列表数组中的成员，包含itemID和changeKey
 *  @param managerGetItemContentBlock 返回获取的EWSItemContentModel（邮件的内容）和错误信息
 */
-(void)getItemnContentWithInboxListModel:(EWSInboxListModel *)model complete:(void (^)(EWSItemContentModel *model, NSError *error))managerGetItemContentBlock;

/**
 *  获取邮件附件
 *
 *  @param itemContentInfo                   邮件内容model
 *  @param managerGetAttachmentCompleteBlock 执行完成后的回调，附件存储路径放在itemContentInfo的EWSMailAttachmentModel的attachmentPath里
 */
-(void)getMailAllAttachmentWithItemContentInfo:(EWSItemContentModel *)itemContentInfo complete:(void (^)())managerGetAttachmentCompleteBlock;

/**
 *  获取特定附件
 *
 *  @param attachmentModel                   附件model
 *  @param managerGetAttachmentCompleteBlock 完成后的回调
 */
-(void)getMailAttachmentWithAttachmentModel:(EWSMailAttachmentModel *)attachmentModel complete:(void (^)())managerGetAttachmentCompleteBlock;

@end
