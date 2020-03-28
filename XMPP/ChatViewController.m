//
//  ChatViewController.m
//  XMPPDemo
//
//  Created by 杨铁 on 2019/9/4.
//  Copyright © 2019 UnSee. All rights reserved.
//
#import <SVProgressHUD/SVProgressHUD.h>
#import "ChatViewController.h"
#import "ChatMessage.h"
#import "HTMLViewCell.h"
#import "ImageViewCell.h"
#import "MessageStorage.h"
#import "ActionManager.h"
#import "ImageUtil.h"
#import "GXExAppDelegate.h"
#import "SessionManager.h"
#import "AppUsersProxy.h"
#import "DateUtil.h"
#import "Log.h"
#import "ImageListQuickViewController.h"

@interface ChatViewController ()

@end

@implementation ChatViewController {
    NSString* _currentTalkTo;
    NSString* _currentTalkToName;
    XMPPConnection* _connection;
    BOOL _ifViewDisappear;
    int _unreadMessageCount;
    BOOL _showChangeTalkToToast;
    int _currentHistoryIndex;
}

-(id)init {
    self = [super init];
    if(self) {
        [self initXMPPConnection];
    }
    return self;
}

-(void)initXMPPConnection {
    if(!_connection) {
        _connection = [GXExAppDelegate shared].xmppConnection;
        if(!_currentTalkTo || _currentTalkTo.length <= 0)
            [self changeTalkTo:[SessionManager shared].xmppConfig.robot displayName:[SessionManager shared].xmppConfig.robotName];
    }
}

-(void)chatWith:(NSString*)talkTo displayName:(NSString*)name text:(NSString*)text {
    if(_connection) {
        [self switchTalkTo:talkTo displayName:name];
        [_connection sendMessage:text to:self->_currentTalkTo];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initXMPPConnection];
    
#if DEBUG
    _tvText.text = @"客服";
#else
    _tvText.text = @"";
#endif
    _constraintTitleHeight.constant = Height_StatusBar + 44;
    
    _viewTitle.backgroundColor = [UIColor colorWithHexString:@"F25353"];
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15,Height_StatusBar + 11,12, 21)];
    imageView.image = [UIImage imageNamed:@"返回"];
    UIButton* backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.frame = CGRectMake(0,Height_StatusBar, 100, 44);
    [backBtn addBlockForControlEvents:UIControlEventTouchUpInside block:^(id  _Nonnull sender) {
        if(self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }];
    
    _lblTitle.font = [UIFont systemFontOfSize:17];
    _lblTitle.tintColor = [UIColor whiteColor];
    _lblTitle.textColor = [UIColor whiteColor];
    _lblTitle.textAlignment = NSTextAlignmentCenter;
    if(_currentTalkToName)
        _lblTitle.text = _currentTalkToName;
    
    [_viewTitle addSubview:backBtn];
    [_viewTitle addSubview:imageView];
    
    _constraintLabelTitleTop.constant = Height_StatusBar + 10;
    
    _btnSend.layer.cornerRadius = 5.0f;
    _btnSend.clipsToBounds = YES;
    
    _tvText.delegate = self;
    _tvText.layer.cornerRadius = 5.0f;
    _tvText.layer.masksToBounds = YES;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _delegate = self;
    
    [_tableView registerNib:[UINib nibWithNibName:@"HTMLViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"HTMLViewCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"ImageViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ImageViewCell"];
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [AppUsersProxy listUserChatHistory:_currentHistoryIndex pageSize:10 whenSuccessful:^(Result *result) {
            [_tableView.mj_header endRefreshing];
            NSString* fromJID = [NSString stringWithFormat:@"%@@%@", [SessionManager shared].xmppConfig.account, [SessionManager shared].xmppConfig.domain];
            
            NSMutableArray<ChatMessage*>* historyMessages = [NSMutableArray new];
            for (NSDictionary* history in [result list]) {
                NSError* error;
                XMPPMessage* message = [[XMPPMessage alloc] initWithXMLString:[history[@"stanza"] stringByReplacingOccurrencesOfString:@"xml:lang" withString:@"lang"] error:&error];
                if(error) {
                    DLog(@"error: %@", error);
                    continue;
                }
                
                if(!message.elementID || ![message.elementID isNotBlank])
                {
                    DLog(@"忽略没有id的消息：%@", message);
                    continue;
                }
                
                NSLog(@"%@ === %@", message.from.bare, fromJID);
                MessageDirection direction = IN;
                if([fromJID isEqualToString:message.from.bare])
                    direction = OUT;
               
                ChatMessage* chatMessage = [ChatMessage buildFromXMPPMessage:message direction:direction];
                chatMessage.status = SUCCEED;
                NSNumber* stamp = history[@"stamp"];
                chatMessage.stamp = [NSNumber numberWithLong: (long)(stamp.longValue/1000)];
                chatMessage.historyMessage = YES;
                
                [historyMessages addObject:chatMessage];
            }
            
            [[MessageStorage shared] putMessages:historyMessages];
            
            int total = [[result pagination][@"total"] intValue];
            if(_currentHistoryIndex+1<=total) {
                _currentHistoryIndex++;
            } else {
                [self.view makeToast:@"已无更旧的记录了。"];
            }
            
            [_tableView reloadData];
            [self scrollTableToTop];
        } whenFailed:^(NSError *error) {
            DLog(@"list chat history error: %@", error);
            [_tableView.mj_header endRefreshing];
        }];
    }];
    
    Action* actionTalkTo = [[Action alloc] initWithCallback:^(ActionURL * _Nonnull actionURL) {
        [self changeTalkTo:[actionURL paramAsString:@"to"] displayName:[actionURL paramAsString:@"name"]];
        if([actionURL paramAsString:@"command"]) {
            [self->_connection sendMessage:[actionURL paramAsString:@"command"] to:self->_currentTalkTo];
        }
    }];
    actionTalkTo.actionType = @"talk";
    
    [[ActionManager shared] registerAction: actionTalkTo];
}

-(void)updateUnreadMessageCount {
    if(_unreadMessageCount > 0 && _ifViewDisappear) {
        self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", _unreadMessageCount];
    } else {
         self.tabBarItem.badgeValue = nil;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self initXMPPConnection];
    
    if(!_connection || !_connection.isActivited) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"错误" message:@"您与客服系统的连接有误，请重试。" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:NO];
        }]];
       
        [self.navigationController presentViewController:alert animated:YES completion:nil];
        
        if(_connection && !_connection.isActivited)
            [[GXExAppDelegate shared] initXMPPConnection];
        return;
    }
    
    _ifViewDisappear = NO;
    _unreadMessageCount = 0;
    
    [[MessageStorage shared] addDelegate:self];
    
    // 取消全局弹框
    [GXExAppDelegate shared].globalPopupXMPPMessage = NO;
    
    [self updateUnreadMessageCount];
    
    [_tableView reloadData];
    [self scrollTableToBottom];
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 全局弹框
    [GXExAppDelegate shared].globalPopupXMPPMessage = YES;
    [[MessageStorage shared] removeDelegate:self];
    
    _ifViewDisappear = YES;
    [self updateUnreadMessageCount];
}

-(void)changeTalkTo:(NSString*) talkTo displayName:(NSString*) title {
    if(!talkTo || talkTo.length <= 0) return;

    if(![talkTo isEqualToString: self->_currentTalkTo]) {
        self->_currentTalkTo = talkTo;
        self->_lblTitle.text = _currentTalkToName = title ? title : talkTo;
        
        if(_showChangeTalkToToast)
            [self.view makeToast:[NSString stringWithFormat: @"当前对话已切换至：%@",_currentTalkToName]];
    }
}

- (IBAction)onSendPicture:(id)sender {
    [self takePhoto];
}

-(void)takePhoto
{
//    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
//    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
//    {
//        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//        picker.delegate = self;
//        //设置拍照后的图片可被编辑
//        picker.allowsEditing = NO;
//        picker.sourceType = sourceType;
//
//        //推出图片选择器
//        [self presentViewController:picker animated:YES completion:nil];
//
//    }else
//    {
//        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
//    }

    LPDImagePickerController* controller  = [[LPDImagePickerController alloc] initWithMaxImagesCount:100 delegate:self];
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}

- (IBAction)sendText:(id)sender {
    if([_tvText.text isNotBlank]) {
        [self->_connection sendMessage:_tvText.text to:self->_currentTalkTo];
        _tvText.text = @"";
    }
}

-(void) scrollTableToBottom {
    if ([MessageStorage shared].count > 0)
    {
        [_tableView
         scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[MessageStorage shared].count-1
                                                   inSection:0]
         atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


-(void) scrollTableToTop {
    if ([MessageStorage shared].count > 0)
    {
        [_tableView
         scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                   inSection:0]
         atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)postImageMessage:(UIImage*) image toWho:(NSString*)to {
    ChatMessage* msg = [ChatMessage buildFromImageUploading: image toWho:to];
    [[MessageStorage shared] putMessage:msg];
    
    if(self.delegate) {
        [self.delegate onUploadImage: msg width:image.size.width height:image.size.height];
    }
}

#pragma UITextViewDelegate
- (void)textViewDidEndEditing:(UITextView *)textView {
    
}

#pragma LPDImagePickerControllerDelegate
- (void)imagePickerController:(LPDImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    for (UIImage* image in photos) {
        [self postImageMessage: image toWho: self->_currentTalkTo];
    }
}

#pragma MessageStorageDelegate
-(void)onMessageUpdate:(ChatMessage*) message {
    [_tableView reloadData];

//    if(message.transferRequired) {
//        [self changeTalkTo: message.transferJID displayName: message.transferName];
//        [self->_connection sendMessage:@"你好！" to:_currentTalkTo];
//    }
    
    _unreadMessageCount++;
    [self updateUnreadMessageCount];
    [self scrollTableToBottom];
}

-(void)switchTalkTo:(NSString *)talkTo displayName:(NSString *)name {
    _showChangeTalkToToast = YES;
    [self changeTalkTo:talkTo displayName:name];
    _showChangeTalkToToast = NO;
}

-(void) viewImage:(ChatMessage*) imageMessgae {
    if(imageMessgae) {
        if(imageMessgae != SENDING) {
            ImageListQuickViewController* controller = [ImageListQuickViewController new];
            [controller appendImageURLs:@[imageMessgae.imageDownloadURL]];
            
            [self.navigationController presentViewController:controller animated:YES completion:nil];
        }
    }
}

#pragma UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [MessageStorage shared].count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessage* msg = [[MessageStorage shared] messageByIndex: indexPath.row];
    return [MessageCell fitnessHeight: msg width: tableView.frame.size.width];
}

#pragma UITableViewDelegate
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell* cell = nil;
    ChatMessage* msg = [[MessageStorage shared] messageByIndex: indexPath.row];
    switch (msg.messageType) {
        case TEXT:
            cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier:@"HTMLViewCell"];
            break;
        case IMAGE:
            cell = (MessageCell*)[tableView dequeueReusableCellWithIdentifier:@"ImageViewCell"];
            break;
        default:
            break;
    }
    
    if(cell) {
        cell.message = msg;
        cell.cellActionDelegate = self;
    }
    
    return cell;
}

#pragma CellActionDelegate
-(void) doAction:(NSString *)action {
    NSLog(@"ready to execute action: %@", action);
    NSURL* actionUrl = [NSURL URLWithString:[action stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if([[ActionManager shared] supportedAction: actionUrl.host]) {
        [[ActionManager shared] execute:actionUrl.host actionURL:actionUrl];
    } else {
        NSLog(@"doesn't support action: %@, use system openurl", action);
        BOOL ok = [[ActionManager shared] openURL: actionUrl];
        if(!ok) {
            NSLog(@"cannot open url:%@", actionUrl);
        }
    }
}

-(void) resendMessage:(ChatMessage *)message {
    [message resetStatus: SENDING];
    [self->_connection sendMessage: message.message];
    
    [[MessageStorage shared] removeMessage: message];
    
    [_tableView reloadData];
}

#pragma UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        //先把图片转成NSData
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
//        NSData *data;
//        if (UIImagePNGRepresentation(image) == nil)
//        {
//            data = UIImageJPEGRepresentation(image, 0.5);
//        }
//        else
//        {
//            //压缩图片大小
//            //UIImage *newImg = [ImageUtil imageCompressForWidth:image targetWidth:self.view.frame.size.width];
//            data = UIImagePNGRepresentation(image);
//        }
        
        __block UIImage *processedImage = [ImageUtil imageCompressForWidth:image targetWidth:2000];
        
        [picker dismissViewControllerAnimated:YES completion:^{
            [self postImageMessage: processedImage toWho: self->_currentTalkTo];
        }];
    }
}

#pragma UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    CGRect rect = [textView.text boundingRectWithSize:CGSizeMake(_tvText.frame.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize: 16.0f]} context:nil];
    //                CGSize size = [msg.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize: 16.0f]}];
    if(rect.size.height <= 55.0f) {
        _constraintInputZoneHeight.constant = 55.0f;
    } else if(rect.size.height <= self.view.frame.size.height / 2 ) {
        _constraintInputZoneHeight.constant = rect.size.height + 10.0f ;
    }
    
    return YES;
}

#pragma ChatViewControllerDelegate
-(void)onUploadImage:(ChatMessage*) message width:(int)width height:(int)height {
    [AppUsersProxy uploadUserFile:message.uploadingImage additionalParams:nil progress:nil whenSuccessful:^(Result *result) {
        NSLog(@"upload succeed: %@", result.items.firstObject[@"uuid"]);
        NSString* downloadURL = [NSString stringWithFormat:@"%@/service/AppUserDownloadFile.action?target=downloadFile&verb=get&uuid=%@"
                                 ,[SessionManager shared].webRoot
                                 ,result.items.firstObject[@"uuid"]];
        [message updateImageURL: downloadURL width:width heigh:height ];
        [[MessageStorage shared] updateMessageStatus:message status:SUCCEED];
        NSLog(@"@%@", downloadURL);
        
        [_connection sendMessage:message.message];
    } whenFailed:^(NSError *error) {
        NSLog(@"upload failed: %@", error);
        [[MessageStorage shared] updateMessageStatus:message status:FAILED];
    }];
}

@end
