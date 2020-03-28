//
//  ImageViewCell.h
//  XMPPDemo
//
//  Created by 杨铁 on 2019/9/9.
//  Copyright © 2019 UnSee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageCell.h"
#import "ChatMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageViewCell : MessageCell
@property (weak, nonatomic) IBOutlet UILabel *lblSender;
@property (weak, nonatomic) IBOutlet UIImageView *ivImage;
@property (weak, nonatomic) IBOutlet UIButton *btnError;

@end

NS_ASSUME_NONNULL_END
