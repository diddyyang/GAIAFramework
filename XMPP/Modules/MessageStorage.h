//
//  MessageStorage.h
//  XMPPDemo
//
//  Created by 杨铁 on 2019/9/5.
//  Copyright © 2019 UnSee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMessage.h"

NS_ASSUME_NONNULL_BEGIN
@protocol MessageStorageDelegate <NSObject>

-(void)onMessageUpdate:(ChatMessage*)message;

@end

@interface MessageStorage : NSObject

+(MessageStorage *)shared;

-(void)putMessage:(ChatMessage*) message;
-(void)removeMessage:(ChatMessage*) message;
-(void)updateMessageStatus:(ChatMessage*) message status:(SendStatus)status;
-(ChatMessage*) messageByIndex:(NSUInteger) index;
@property (readonly, nonatomic) NSUInteger count;

-(void)putMessages:(NSArray<ChatMessage*>*) messages;

-(void)addDelegate:(id<MessageStorageDelegate>) delegate;
-(void)removeDelegate:(id<MessageStorageDelegate>) delegate;
-(void)clearMessages;

@end

NS_ASSUME_NONNULL_END
