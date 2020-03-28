//
//  ChatMenu.h
//  XMPPDemo
//
//  Created by 杨铁 on 2019/9/5.
//  Copyright © 2019 UnSee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XMPPFramework/XMPPFramework.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,DisplayMode){
    BUTTON,
    POPUP
};

@interface ChatMenu : NSObject

-(id)initWithXMLElement:(NSXMLElement*) element;

@property (nonatomic,strong) NSString* text;
@property (nonatomic,strong) NSString* action;
@property (nonatomic) DisplayMode displayMode;

@end

NS_ASSUME_NONNULL_END
