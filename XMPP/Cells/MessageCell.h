//
//  MessageCell.h
//  XMPPDemo
//
//  Created by 杨铁 on 2019/9/4.
//  Copyright © 2019 UnSee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessage.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CellActionDelegate <NSObject>

-(void) doAction:(NSString*) action;

-(void) switchTalkTo:(NSString*) talkTo displayName:(NSString*) name;
-(void) resendMessage:(ChatMessage*) message;
-(void) viewImage:(ChatMessage*) imageMessgae;

@end

@interface MessageCell : UITableViewCell
@property (nonatomic, strong) id<CellActionDelegate> cellActionDelegate;
@property (nonatomic, strong) ChatMessage* message;
+(CGFloat) fitnessHeight:(ChatMessage*) msg width:(CGFloat)width;

@end

NS_ASSUME_NONNULL_END
