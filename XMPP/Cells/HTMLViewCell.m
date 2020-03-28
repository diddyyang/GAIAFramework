//
//  HTMLViewCell.m
//  XMPPDemo
//
//  Created by 杨铁 on 2019/9/4.
//  Copyright © 2019 UnSee. All rights reserved.
//

#import "HTMLViewCell.h"
#import "ChatMessage.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIView+Toast.h"

@implementation HTMLViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _tvHTML.clipsToBounds = YES;
    _tvHTML.layer.cornerRadius = 10.f;
    _tvHTML.backgroundColor = [UIColor colorWithWhite:0 alpha:0.0f];
    _tvHTML.textColor = [UIColor blackColor];
    
    UILongPressGestureRecognizer* gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLabelSenderLongPress:)];
    [_lblSender addGestureRecognizer: gesture];
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

-(void)setMessage:(ChatMessage *)message {
    super.message = message;
    
    if(message.direction == IN) {
        _lblSender.text = [message.senderName stringByAppendingString:@"："];
        _lblSender.textAlignment = NSTextAlignmentLeft;
        _tvHTML.textAlignment = NSTextAlignmentLeft;
        _viewPhone.hidden = ![message senderPhone] || [message senderPhone].length <= 0;
    } else {
        _lblSender.text = @"我：";
        _lblSender.textAlignment = NSTextAlignmentRight;
        _tvHTML.textAlignment = NSTextAlignmentRight;
        _viewPhone.hidden = YES;
    }
    
    _tvHTML.text = message.text;
    
    
    for (UIView* childView in _scrollview4Buttons.subviews) {
        [childView removeFromSuperview];
    }
    
    [_tvHTML setScrollEnabled:NO];
    if(message.menuEnabled) {
        _constraintTextBottom.constant = 30;
        
        _scrollview4Buttons.hidden = NO;
        CGFloat offsetX = 5.0f;
        NSArray<ChatMenu*>* menus = message.menus;
        for (int i=0; i<menus.count; i++) {
            ChatMenu* menu = menus[i];
            UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, 0, 0, 0)];
            [btn setTitle:menu.text forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:12.0f];
            [btn sizeToFit];
            [btn setTag: i];
            [btn addTarget:self action:@selector(onMenuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.backgroundColor = [UIColor redColor];
            btn.layer.cornerRadius = 5.0f;
            btn.clipsToBounds = YES;
            
            [_scrollview4Buttons addSubview: btn];
            
            offsetX += btn.frame.size.width + 5.0f;
        }
        [_scrollview4Buttons setContentSize:CGSizeMake(offsetX + 100, 30)];
    } else {
        _scrollview4Buttons.hidden = YES;
        _constraintTextBottom.constant = 0;
    }
    
    _btnError.hidden = message.status != FAILED;
    if(_btnError.hidden) {
        _constraintErrorSpace.constant = 0.f;
    } else {
        _constraintErrorSpace.constant = 30.f;
    }
}

- (IBAction)onMakePhoneCall:(id)sender {
    if(self.message && self.message.senderPhone && self.message.senderPhone.length > 0) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", self.message.senderPhone]]];
    }
}

-(void)onMenuButtonClick:(UIButton*)sender {
    ChatMenu* menu = self.message.menus[(NSUInteger) sender.tag];
    if(self.cellActionDelegate) {
        [self.cellActionDelegate doAction: menu.action];
    }
}

- (IBAction)onResendMessage:(id)sender {
    if(self.cellActionDelegate) {
        [self.cellActionDelegate resendMessage: self.message];
    }
}

@end
