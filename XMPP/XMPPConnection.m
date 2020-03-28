//
//  XMPPConnection.m
//  XMPPDemo
//
//  Created by 杨铁 on 2019/9/4.
//  Copyright © 2019 UnSee. All rights reserved.
//

#import "XMPPConnection.h"
#import "Log.h"

@implementation XMPPConnection {
    XMPPStream* _xmppStream;
    NSString* _serverAddr;
    NSInteger _serverPort;
    NSString* _xmppDomain;
    NSString* _xmppResource;
    NSString* _xmppLoginName;
    NSString* _xmppPassword;
    XPMM_LOGIN_CALLBACK _loginCallback;
    XMPPAutoPing* _xmppAutoPing;
    XMPPReconnect* _xmppReconnect;
    int pingTimeoutCount;
    int reconnectCount;
    BOOL _doLogin;
}

-(id)initWithServerOptions:(NSString*) server port:(NSInteger)port domain:(nonnull NSString *)domain resource:(nonnull NSString *)resource {
    self = [super init];
    if(self) {
        self->_serverAddr = [server copy];
        self->_serverPort = port;
        self->_xmppDomain = [domain copy];
        self->_xmppResource = [resource copy];
        
        self->_xmppStream = [[XMPPStream alloc] init];
        [self->_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        self->_xmppAutoPing =  [[XMPPAutoPing alloc] initWithDispatchQueue:dispatch_get_main_queue()];
        self->_xmppAutoPing.pingInterval = 10.0;
        [self->_xmppAutoPing addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
        
        [_xmppAutoPing activate:self->_xmppStream];
        
        _xmppReconnect = [[XMPPReconnect alloc] init];
        _xmppReconnect.autoReconnect = YES;
        _xmppReconnect.reconnectDelay = 0.f;// 一旦失去连接，立马开始自动重连，不延迟
        _xmppReconnect.reconnectTimerInterval = 3.f;// 每隔3秒自动重连一次
        [_xmppReconnect activate:_xmppStream];
        [_xmppReconnect addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    
    return self;
}

-(void)login:(NSString *)loginName password:(NSString *)password onLogin:(XPMM_LOGIN_CALLBACK)whenLogin {
    if([self->_xmppStream isConnected]) {
        [self->_xmppStream disconnectAfterSending];
    }
    
    XMPPJID* jid = [XMPPJID jidWithUser:loginName domain:self->_xmppDomain resource:_xmppResource];
    [self->_xmppStream setMyJID: jid];
    [self->_xmppStream setHostName: self->_serverAddr];
    [self->_xmppStream setHostPort: self->_serverPort];
    
    self->_xmppLoginName = [loginName copy];
    self->_xmppPassword = [password copy];
    self->_loginCallback = whenLogin;
    
    _doLogin = YES;
    [self->_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:nil];
}

-(void)sendMessage:(NSString*)message to:(NSString*) toUser {
    XMPPJID* jid = nil;
    if([toUser containsString:@"@"]) {
        jid = [XMPPJID jidWithString:toUser];
    } else {
        jid = [XMPPJID jidWithUser:toUser domain:self->_xmppDomain resource:@"*"];
    }
   
    XMPPMessage* msg = [XMPPMessage messageWithType:@"chat" to:jid elementID: [ChatMessage generateUUID]];
    [msg addBody:message];
    if(![msg elementForName:@"contact"]) {
        DDXMLElement* extension = [DDXMLElement elementWithName:@"contact"];
        extension.URI = XMPP_NAME_SPACE;
        [extension addAttributeWithName:@"mobile" stringValue:self.contactMobile];
        [extension addAttributeWithName:@"name" stringValue:self.contactName];
        [extension addAttributeWithName:@"webUserId" stringValue:self.webUserId];
        
        [msg addChild:extension];
    }
    NSLog(@"send message: %@", msg);
    
    [self->_xmppStream sendElement:msg];
}

-(void)sendMessage:(XMPPMessage*)message {
    if(![message elementForName:@"contact"]) {
        DDXMLElement* extension = [DDXMLElement elementWithName:@"contact"];
        [extension addAttributeWithName:@"mobile" stringValue:self.contactMobile];
        [extension addAttributeWithName:@"name" stringValue:self.contactName];
        [extension addAttributeWithName:@"webUserId" stringValue:self.webUserId];
        
        [message addChild:extension];
    }
    NSLog(@"send message: %@", message);
    
    [self->_xmppStream sendElement:message];
}

-(void)disconnect {
    if(_xmppStream)
        [_xmppStream disconnectAfterSending];
}

#pragma XMPPStreamDelegate
-(void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
    NSLog(@"正在建立网络连接...");
}

-(void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSLog(@"已建立网络连接!");
    [sender authenticateWithPassword:self->_xmppPassword error:nil];
}

-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    NSLog(@"已登录XMPP服务器!");
    
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    NSXMLElement* eleGreeting = [[NSXMLElement alloc] initWithName:@"greeting"];
    [eleGreeting addAttributeWithName:@"greeting" objectValue:@"greeting"];
    eleGreeting.URI = XMPP_NAME_SPACE;
    [presence addChild: eleGreeting];
    
    [self->_xmppStream sendElement: presence];
    
    if(self->_doLogin && self->_loginCallback) {
        self->_loginCallback(YES, nil);
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    NSLog(@"连接失败,原因:%@", error);
    if(self->_doLogin && self->_loginCallback) {
        self->_loginCallback(NO, [NSError errorWithDomain:NSGlobalDomain code:0 userInfo:@{NSLocalizedDescriptionKey:@"登录失败"}]);
    }
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    NSLog(@"已断开连接(%@:%d)，原因：%@",sender.hostName, sender.hostPort, [error localizedDescription]);
    if(self->_doLogin && self->_loginCallback) {
        self->_loginCallback(NO, error);
    }
}

-(void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    [[MessageStorage shared] putMessage:[ChatMessage buildFromXMPPMessage:message direction:OUT]];
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
    NSLog(@"fail to send message: %@", message);
    [[MessageStorage shared] updateMessageStatus:[ChatMessage buildFromXMPPMessage:message direction:OUT] status:FAILED];
}

-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSLog(@"receive message: %@", message);
    [[MessageStorage shared] putMessage:[ChatMessage buildFromXMPPMessage:message direction:IN]];
}

-(void)xmppStream:(XMPPStream *)sender didReceiveError:(DDXMLElement *)error {
     NSLog(@"receive from (%@:%d)，error：%@",sender.hostName, sender.hostPort, error);
}

-(BOOL)isActivited {
    return _xmppStream && _xmppStream.isAuthenticated;
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
#if DEBUG__
    DLog(@"receive IQ: %@", iq);
#endif
}

#pragma mark - XMPPAutoPingDelegate
- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender{
    // 如果至少有1次超时了，再收到ping包，则清除超时次数
    if (pingTimeoutCount > 0) {
        pingTimeoutCount = 0;
    }
}
- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender {
    // 收到5次超时，就disconnect
    pingTimeoutCount++;
    if (pingTimeoutCount >= 5) {
        [self->_xmppStream disconnect];
    }
}

#pragma mark - XMPPReconnectDelegate
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags {
    NSLog(@"监测到XMPP意外断开连接。");
}

- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags {
    reconnectCount++;

    NSLog(@"XMPP自动重连...第%@次", @(reconnectCount));
    
    if (reconnectCount < 5) {
        [self reconnectImmediately];
    }
    
    return YES;
}

- (void)reconnectImmediately {
    self->_xmppReconnect.reconnectTimerInterval = 3.f;
    reconnectCount = 0;
    
    [self->_xmppReconnect stop];
    [self->_xmppReconnect manualStart];
}

@end
