//
//  ChatMessage.m
//  XMPPDemo
//
//  Created by 杨铁 on 2019/9/4.
//  Copyright © 2019 UnSee. All rights reserved.
//

#import "ChatMessage.h"
#import "DateUtil.h"

@implementation ChatMessage {
    NSString* _messageId;
    NSArray<ChatMenu*>* _menus;
}

+(ChatMessage*) buildFromXMPPMessage:(XMPPMessage*) message  direction:(MessageDirection)direction {
    ChatMessage* msg =  [[ChatMessage alloc] init];
    msg.direction = direction;
    msg.messageType = TEXT;
    if([message elementForName:@"img"])
        msg.messageType = IMAGE;
    msg.message = message;
    
    if(OUT == direction)
        msg.status = SENDING;
    else
        msg.status = SUCCEED;
    
    if([message isErrorMessage]) msg.status = FAILED;
    
    return msg;
}

+(ChatMessage*) buildFromImageUploading:(UIImage*) image  toWho:(NSString*) to {
    ChatMessage* msg =  [[ChatMessage alloc] init];
    
    msg.direction = OUT;
    msg.messageType = IMAGE;
    msg.uploadingImage = image;
    msg.status = SENDING;
    msg.message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:to] elementID:[ChatMessage generateUUID]];
    [msg.message addBody:@"照片"];
    
    return msg;
}

+(NSString*) generateUUID {
    CFUUIDRef ref = CFUUIDCreate(NULL);
    
    CFStringRef stringRef = CFUUIDCreateString(NULL, ref);
    
    CFRelease(ref);
    
    NSString *uuid = (__bridge NSString*)stringRef;
    
    CFRelease(stringRef);
    
    return uuid;
}

-(id)init {
    self = [super init];
    if(self) {
        self->_messageId = [ChatMessage generateUUID];
        self->_stamp = [NSNumber numberWithDouble: [[NSDate date] timeIntervalSince1970]];
    }
    return self;
}

-(NSString*)messageId {
    if(_message)
        return _message.elementID? _message.elementID: _messageId;
    return _messageId;
}

-(NSString*)senderName {
    if(_message) {
        NSXMLElement* eleContact = [_message elementForName:@"contact"];
        if(eleContact) {
            return [eleContact attributeStringValueForName:@"name" withDefaultValue:_message.fromStr];
        }
        return _message.fromStr;
    }
    return @"";
}

-(NSString*)senderPhone {
    if(_message) {
        NSXMLElement* eleContact = [_message elementForName:@"contact"];
        if(eleContact) {
            return [eleContact attributeStringValueForName:@"mobile"];
        }
    }
    return @"";
}

-(XMPPJID*)sender {
    if(_message)
        return _message.from;
    return nil;
}

-(NSString*)text {
    if(_message)
#if DEBUG__DDY
        return [_message.body stringByAppendingFormat:@"\nstamp=%lu", self.stamp];
#else
        return _message.body;
#endif
        
    return nil;
}

-(NSString*) date {
    NSDate* date  = [NSDate dateWithTimeIntervalSince1970: self.stamp.doubleValue];
    return [DateUtil convertDateToString: date dateFormat:@"yyyy年MM月dd日"];
}

-(NSString*)imageDownloadURL {
    if(_message) {
        NSXMLElement* eleImg = [_message elementForName:@"img"];
        if(eleImg) {
            BOOL encoded = [@"true" isEqualToString:[eleImg attributeStringValueForName:@"url-encoded"]];
            NSString* imgURL = [eleImg attributeStringValueForName:@"url"];
            if(!encoded)
                return imgURL;
            return [[imgURL
                     stringByReplacingOccurrencesOfString:@"+" withString:@" "]
                    stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }
    
    return nil;
}

-(CGSize)imageSize {
    if(_message) {
        NSXMLElement* eleImg = [_message elementForName:@"img"];
        if(eleImg) {
            int width = [eleImg attributeIntValueForName:@"width"];
            int height = [eleImg attributeIntValueForName:@"height"];
            return CGSizeMake(width, height);
        }
    }
    return CGSizeZero;
}

-(BOOL)menuEnabled {
    if(!_message || _historyMessage) return NO;
    
    NSXMLElement* eleMenu = [_message elementForName:@"menus"];
    if(eleMenu) {
        NSMutableArray* menus = [NSMutableArray new];
        for(NSXMLElement* ele in [eleMenu elementsForName:@"menu"]) {
            [menus addObject:[[ChatMenu alloc] initWithXMLElement: ele]];
        }
        _menus = [NSArray arrayWithArray: menus];
    }
    
    return _menus && _menus.count > 0;
}

-(BOOL)isErrorMessage {
    if(!_message) return NO;
    return [_message isErrorMessage];
}

-(NSArray<ChatMenu*>*)menus {
    if(self.menuEnabled)
        return _menus;
    return nil;
}

-(void)resetStatus:(SendStatus) status {
    if(SENDING == status && _message) {
        if([@"error" isEqualToString:_message.type]) {
            [_message addAttributeWithName:@"type" stringValue:@"chat"];
        }
    }
}

-(void)updateImageURL:(NSString*)downloadUrl width:(int)width heigh:(int)height {
    if(_message) {
        NSXMLElement* eleImg = [[NSXMLElement alloc] initWithName:@"img"];
        [eleImg addAttributeWithName:@"url" stringValue: downloadUrl];
        [eleImg addAttributeWithName:@"width" intValue: width];
        [eleImg addAttributeWithName:@"height" intValue: height];
        
        [_message addChild:eleImg];
    }
}

-(void)updateMessageStatus:(XMPPMessage*)message {
    if(!_message)
        _message = message;
    if(![_message.type isEqualToString:message.type]) {
        [_message addAttributeWithName:@"type" stringValue:message.type];
    }
    
    if([_message isErrorMessage])
        _status = FAILED;
}

-(BOOL) transferRequired {
    if(_message) {
        NSXMLElement* eleTransfer = [_message elementForName:@"transfer"];
        return nil != eleTransfer;
    }
    
    return NO;
}

-(NSString*) transferJID {
    if(_message) {
        NSXMLElement* eleTransfer = [_message elementForName:@"transfer"];
        return [eleTransfer attributeStringValueForName:@"to"];
    }
    
    return nil;
}

-(NSString*) transferName {
    if(_message) {
        NSXMLElement* eleTransfer = [_message elementForName:@"transfer"];
        return [eleTransfer attributeStringValueForName:@"name"];
    }
    
    return nil;
}

@end
