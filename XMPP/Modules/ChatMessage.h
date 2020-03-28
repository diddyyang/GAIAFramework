//
//  ChatMessage.h
//  XMPPDemo
//
//  Created by 杨铁 on 2019/9/4.
//  Copyright © 2019 UnSee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPPFramework/XMPPFramework.h>
#import "ChatMenu.h"

#define XMPP_NAME_SPACE @"urn:xmpp:unsee"

typedef NS_ENUM(NSInteger,MessageDirection){
    IN,
    OUT
};

typedef NS_ENUM(NSInteger,MessageType){
    TEXT,
    IMAGE,
    SEPARATOR
};

typedef NS_ENUM(NSInteger,SendStatus){
    SENDING,
    FAILED,
    SUCCEED
};

NS_ASSUME_NONNULL_BEGIN

@interface ChatMessage : NSObject

@property (nonnull, nonatomic, readonly) NSString* messageId;

@property (nonatomic) MessageDirection direction;

@property (nonatomic) MessageType messageType;

@property (nonatomic, strong) XMPPMessage* message;

@property (readonly, nonatomic, strong) NSString* senderName;

@property (readonly, nonatomic, strong) NSString* senderPhone;

@property (readonly, nonatomic, strong) XMPPJID* sender;

@property (readonly, nonatomic, strong) NSString* text;

@property (readonly, nonatomic) BOOL menuEnabled;

@property (readonly, nonatomic, strong) NSArray<ChatMenu*>* menus;

@property (nonatomic) SendStatus status;

@property (readonly, nonatomic) BOOL transferRequired;

@property ( nonatomic) BOOL historyMessage;

@property (readonly, nonatomic) NSString* transferJID;

@property (readonly, nonatomic) NSString* transferName;

@property (nonatomic, strong) NSNumber* stamp;

@property (readonly, nonatomic) NSString* date;

/**
 正在上传的图片文件
 */
@property (nonatomic, strong) UIImage* uploadingImage;

/**
 上传成功之后的图片下载位置
 */
@property (readonly, nonatomic, strong) NSString* imageDownloadURL;

@property (readonly, nonatomic) CGSize imageSize;

@property (readonly, nonatomic) BOOL isErrorMessage;

+(NSString*) generateUUID;
+(ChatMessage*) buildFromXMPPMessage:(XMPPMessage*) message direction:(MessageDirection)direction;
+(ChatMessage*) buildFromImageUploading:(UIImage*) image toWho:(NSString*) to;

-(void)resetStatus:(SendStatus) status;
-(void)updateImageURL:(NSString*)downloadUrl width:(int)width heigh:(int)height;
-(void)updateMessageStatus:(XMPPMessage*)message;

@end

NS_ASSUME_NONNULL_END
