//
//  XMPPConnection.h
//  XMPPDemo
//
//  Created by 杨铁 on 2019/9/4.
//  Copyright © 2019 UnSee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPPFramework/XMPPFramework.h>
#import "MessageStorage.h"

typedef void (^XPMM_LOGIN_CALLBACK)(BOOL logon, NSError* _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface XMPPConnection : NSObject<XMPPStreamDelegate, XMPPAutoPingDelegate, XMPPReconnectDelegate>

-(id)initWithServerOptions:(NSString*) server port:(NSInteger)port domain:(NSString*) domain resource:(NSString*) resource;
-(void)login:(NSString*)loginName password:(NSString*)password onLogin:(XPMM_LOGIN_CALLBACK)whenLogin;
-(void)sendMessage:(NSString*)message to:(NSString*) toUser;
-(void)sendMessage:(XMPPMessage*)message;
-(void)disconnect;

@property (nonatomic, readonly) BOOL isActivited;

@property (nonatomic, strong) NSString* contactName;
@property (nonatomic, strong) NSString* contactMobile;
@property (nonatomic, strong) NSString* webUserId;

@end

NS_ASSUME_NONNULL_END
