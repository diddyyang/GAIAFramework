//
//  HTMLViewCell.h
//  XMPPDemo
//
//  Created by 杨铁 on 2019/9/4.
//  Copyright © 2019 UnSee. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTMLViewCell : MessageCell
@property (weak, nonatomic) IBOutlet UILabel *lblSender;
@property (weak, nonatomic) IBOutlet UITextView *tvHTML;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview4Buttons;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintTextBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintErrorSpace;
@property (weak, nonatomic) IBOutlet UIButton *btnError;
@property (weak, nonatomic) IBOutlet UIView *viewPhone;

@end

NS_ASSUME_NONNULL_END
