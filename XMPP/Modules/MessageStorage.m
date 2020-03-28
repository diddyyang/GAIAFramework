//
//  MessageStorage.m
//  XMPPDemo
//
//  Created by 杨铁 on 2019/9/5.
//  Copyright © 2019 UnSee. All rights reserved.
//

#import "MessageStorage.h"

@implementation MessageStorage {
    NSMutableArray<ChatMessage*>* _messages;
    NSMutableArray<MessageStorageDelegate>* _delegates;
}

+(MessageStorage *)shared{
    static MessageStorage *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MessageStorage alloc]init];
    });
    return manager;
}

-(id)init {
    self = [super init];
    if(self) {
        self->_messages = [NSMutableArray new];
        self->_delegates = [NSMutableArray new];
    }
    return self;
}

-(void)addDelegate:(id<MessageStorageDelegate>) delegate {
    if([_delegates indexOfObject:delegate] == NSNotFound) {
        NSLock* lock = [[NSLock alloc] init];
        [lock lock];
        [_delegates addObject: delegate];
        [lock unlock];
    }
}

-(void)removeDelegate:(id<MessageStorageDelegate>) delegate {
    NSLock* lock = [[NSLock alloc] init];
    [lock lock];
    [_delegates removeObject:delegate];
    [lock unlock];
}

-(void)notifyMessageUpdate:(ChatMessage*)message {
    NSLock* lock = [[NSLock alloc] init];
    [lock lock];
    for (id<MessageStorageDelegate> delegate in _delegates) {
        [delegate onMessageUpdate:message];
    }
    [lock unlock];
}

-(ChatMessage*)findByMessageID:(NSString*)messageId {
    for (ChatMessage* msg in _messages) {
        if([msg.messageId isEqualToString:messageId])
            return msg;
    }
    
    return nil;
}

-(void)resortMessages {
    [_messages sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        ChatMessage* m1 = obj1;
        ChatMessage* m2 = obj2;
        
        long l1 = m1.stamp.longValue;
        long l2 = m2.stamp.longValue;
        
        if(l1 == l2) return NSOrderedSame;
        if(l1>l2) return NSOrderedDescending;
        return NSOrderedAscending;
    }];
}

-(void)putMessage:(ChatMessage*) message {
    NSLock* lock = [[NSLock alloc] init];
    [lock lock];
    ChatMessage* msg = [self findByMessageID:message.messageId];
    if(msg) {
        [msg updateMessageStatus:message.message];
    } else {
        [_messages addObject: message];
    }
    
    [self resortMessages];
    [lock unlock];
    
    [self notifyMessageUpdate: message];
}

-(void)putMessages:(NSArray<ChatMessage*>*) messages {
    NSLock* lock = [[NSLock alloc] init];
    [lock lock];
    
    for (ChatMessage* message in messages) {
        ChatMessage* msg = [self findByMessageID:message.messageId];
        if(msg) {
            [msg updateMessageStatus:message.message];
        } else {
            [_messages addObject: message];
        }
    }
    
    [self resortMessages];
    
    [lock unlock];
}

-(void)clearMessages {
    [_messages removeAllObjects];
    
    [self notifyMessageUpdate: nil];
}

-(void)removeMessage:(ChatMessage *)message {
    ChatMessage* msg = [self findByMessageID:message.messageId];
    if(msg) {
        [_messages removeObject:msg];
    }
}

-(void)updateMessageStatus:(ChatMessage*) message status:(SendStatus)status {
    ChatMessage* msg = [self findByMessageID:message.messageId];
    if(!msg) return;
    msg.status = status;
    
   [self notifyMessageUpdate: message];
}

-(ChatMessage*) messageByIndex:(NSUInteger) index {
    return _messages[index];
}

-(NSUInteger)count {
    return _messages.count;
}

@end
