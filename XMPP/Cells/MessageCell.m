//
//  MessageCell.m
//  XMPPDemo
//
//  Created by 杨铁 on 2019/9/4.
//  Copyright © 2019 UnSee. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(CGFloat) fitnessHeight:(ChatMessage*)msg width:(CGFloat)width {
    CGFloat defaultHeight = 120.f;
    switch(msg.messageType) {
        case TEXT:
            if(msg.text && msg.text.length > 0) {
                CGRect rect = [msg.text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize: 16.0f]} context:nil];
//                CGSize size = [msg.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize: 16.0f]}];
                defaultHeight = rect.size.height + 20.0f ;
            } else {
                defaultHeight = 20.f;
            }
            break;
        case IMAGE:
            break;
    }

    return defaultHeight + 24.0f + (msg.menuEnabled ? 30.0f : 0.0f);
}

@end
