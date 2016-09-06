//
//  EWSMailAttachment.h
//  EWS-For-iOS
//
//  Created by wangxk on 16/8/30.
//  Copyright © 2016年 wangxk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EWSMailAttachmentModel.h"

@interface EWSMailAttachment : NSObject

-(void)getAttachmentWithEWSUrl:(NSString *)url attachmentInfo:(EWSMailAttachmentModel *)attachmentInfo;

@end
