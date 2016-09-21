//
//  EWSManager.h
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/18.
//  Copyright © 2016年 wangxk. All rights reserved.
//

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
 */
-(void)setEmailBoxInfoEmailAddress:(NSString *)emailAddress password:(NSString *)password description:(NSString *)description mailServerAddress:(NSString *)mailServerAddress domain:(NSString *)domain;

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

@end
