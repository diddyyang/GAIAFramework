//
//  ChatViewController.h
//  XMPPDemo
//
//  Created by 杨铁 on 2019/9/4.
//  Copyright © 2019 UnSee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XMPPFramework/XMPPFramework.h>
#import <IQKeyboardManager/IQKeyboardManager.h>

#import "XMPPConnection.h"
#import "MessageCell.h"
#import "MJRefresh.h"

// GXExApp项目专用
#import "UIView+Toast.h"
#import "Constant.h"
#import <YYKit/YYKit.h>
#import "LPDImagePickerController.h"

#define KB 1024

NS_ASSUME_NONNULL_BEGIN

@protocol ChatViewControllerDelegate <NSObject,UITextViewDelegate>

-(void)onUploadImage:(ChatMessage*) message width:(int)width height:(int)height;

@end

@interface ChatViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, CellActionDelegate, UINavigationControllerDelegate, MessageStorageDelegate,ChatViewControllerDelegate, LPDImagePickerControllerDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;

@property (weak, nonatomic) IBOutlet UITextView *tvText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintInputZoneHeight;
@property (weak, nonatomic) id<ChatViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTitleHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLabelTitleTop;
@property (weak, nonatomic) IBOutlet UIView *viewTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

-(void)loginXMPPWithAccount;
-(void)chatWith:(NSString*)talkTo displayName:(NSString*)name text:(NSString*)text;

@end

NS_ASSUME_NONNULL_END
