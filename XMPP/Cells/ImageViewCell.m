//
//  ImageViewCell.m
//  XMPPDemo
//
//  Created by 杨铁 on 2019/9/9.
//  Copyright © 2019 UnSee. All rights reserved.
//

#import "ImageViewCell.h"
#import "UIImageView+WebCache.h"

@implementation ImageViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UILongPressGestureRecognizer* gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLabelSenderLongPress:)];
    [_lblSender addGestureRecognizer: gesture];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onImageViewTap:)];
    [_ivImage addGestureRecognizer: tapGesture];
}

-(void)onImageViewTap:(id)sender {
    if(self.cellActionDelegate) {
        [self.cellActionDelegate viewImage: self.message];
    }
}

-(void)onLabelSenderLongPress:(id)sender {
    if(self.cellActionDelegate && self.message.direction == IN) {
        if([self.cellActionDelegate respondsToSelector:@selector(switchTalkTo:displayName:)]) {
            [self.cellActionDelegate switchTalkTo:self.message.sender.bare displayName:self.message.senderName];
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setMessage:(ChatMessage*)message {
    super.message = message;
    
    if(message.direction == IN) {
        _lblSender.text = [message.senderName stringByAppendingString:@"："];
        _lblSender.textAlignment = NSTextAlignmentLeft;
    } else {
        _lblSender.text = @"我：";
        _lblSender.textAlignment = NSTextAlignmentRight;
    }
    
#if DEBUG__DDY
    _lblSender.text = [_lblSender.text stringByAppendingFormat:@",stamp=%lu", self.message.stamp];
#endif
    
    switch(message.status) {
        case SENDING:
             _ivImage.image = [UIImage imageNamed:@"upload_128.png"];
            break;
        default:
            [_ivImage sd_setImageWithURL:[NSURL URLWithString:message.imageDownloadURL] placeholderImage:[UIImage imageNamed:@"upload_128.png"]];
            break;
    }
    
    _btnError.hidden = message.status != FAILED;
}
- (IBAction)onResendImage:(id)sender {
    if(self.cellActionDelegate) {
        [self.cellActionDelegate resendMessage: self.message];
    }
}

@end
