//
// ViewController.m
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

#import "ViewController.h"
#import "EWSManager.h"
#import "EWSItemContentModel.h"
#import "EWSMailAttachmentModel.h"
#import "EWSMailAttachment.h"
#import "EWSMailAccountModel.h"

#define ScreenWidth  [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()

@end

@implementation ViewController{
    UITextField *_eAddressTf;
    UITextField *_ePasswordTf;
    UITextField *_eDescription;
    UITextField *_eServerAddress;
    UIButton *_eConfirmBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.5 alpha:1.0];
    
    [self initUI];
    
}

-(void)initUI{
    
    [self.view addSubview:({
        _eAddressTf = [[UITextField alloc] initWithFrame:CGRectMake(20, 80, ScreenWidth-40, 30)];
        _eAddressTf.placeholder = @"邮箱（必填）";
        _eAddressTf.delegate = self;
        _eAddressTf;
    })];
    
    [self.view addSubview:({
        _ePasswordTf = [[UITextField alloc] initWithFrame:CGRectMake(20, 130, ScreenWidth-40, 30)];
        _ePasswordTf.placeholder = @"密码（必填）";
        _ePasswordTf.delegate = self;
        _ePasswordTf;
    })];
    
    [self.view addSubview:({
        _eDescription = [[UITextField alloc] initWithFrame:CGRectMake(20, 180, ScreenWidth-40, 30)];
        _eDescription.placeholder = @"描述（选填）";
        _eDescription.delegate = self;
        _eDescription;
    })];
    
    [self.view addSubview:({
        _eServerAddress = [[UITextField alloc] initWithFrame:CGRectMake(20, 230, ScreenWidth-40, 30)];
        _eServerAddress.placeholder = @"邮箱服务器地址（选填）";
        _eServerAddress.delegate = self;
        _eServerAddress;
    })];
    
    [self.view addSubview:({
        _eConfirmBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _eConfirmBtn.frame = CGRectMake(20, 280, ScreenWidth-40, 30);
        [_eConfirmBtn addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [_eConfirmBtn setTitle:@"确认" forState:UIControlStateNormal];
        _eConfirmBtn;
    })];
    
}

-(void)confirmBtnClicked{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [[EWSManager sharedEwsManager] setEmailBoxInfoEmailAddress:_eAddressTf.text password:_ePasswordTf.text description:_eDescription.text mailServerAddress:_eServerAddress.text domain:nil completion:^(BOOL success) {

        dispatch_async(dispatch_get_main_queue(), ^{

            if (success) {

                [self getAllItem];
                //        [self getInboxList];
            }
            else {
                NSLog(@"Something went wrong...May be EWS url was not discovered");
            }
        });

    }];
}

-(void)getInboxList{
    [[EWSManager sharedEwsManager] getInboxListComplete:^(NSArray *inboxList, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        }
        else{
            for (EWSInboxListModel *temp in inboxList) {
                NSLog(@"======%@=%@===",temp.itemId,temp.changeKey);
            }
        }
        
    }];
}

-(void)getAllItem{
    [[EWSManager sharedEwsManager] getAllItemContent:^(NSArray *allItemArray, NSError *error) {
        if (error) {
            NSLog(@"error:%@",error);
        }
        else{
            EWSItemContentModel *itemContentInfo = allItemArray[0];
            NSLog(@"---content:%@-%@-%@-%@-%@--",itemContentInfo.itemSubject,itemContentInfo.itemContentHtmlString,itemContentInfo.dateTimeSentStr,itemContentInfo.size,((EWSMailAttachmentModel *)itemContentInfo.attachmentList[0]).attachmentPath);
            if (itemContentInfo.hasAttachments) {
//                [[EWSManager sharedEwsManager] getMailAllAttachmentWithItemContentInfo:itemContentInfo complete:^{
//                    NSLog(@"---content:%@-%@-%@-%@-%@--",itemContentInfo.itemSubject,itemContentInfo.itemContentHtmlString,itemContentInfo.dateTimeSentStr,itemContentInfo.size,((EWSMailAttachmentModel *)itemContentInfo.attachmentList[0]).attachmentPath);
//                }];
                EWSMailAttachmentModel *temp = itemContentInfo.attachmentList[0];
                [[EWSManager sharedEwsManager] getMailAttachmentWithAttachmentModel:temp complete:^{
                    NSLog(@"-!!!!!--content:%@-%@-%@-%@-%@--",itemContentInfo.itemSubject,itemContentInfo.itemContentHtmlString,itemContentInfo.dateTimeSentStr,itemContentInfo.size,((EWSMailAttachmentModel *)itemContentInfo.attachmentList[0]).attachmentPath);
                }];
            }
            
        }
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        allItemArray = nil;
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
