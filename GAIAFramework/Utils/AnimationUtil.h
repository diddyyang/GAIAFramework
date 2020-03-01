//
//  AnimationUtil.h
//  GuoXinApp
//
//  Created by 杨铁 on 2018/9/6.
//  Copyright © 2018年 UnSee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AnimationUtil : NSObject
+(void) slideFromLeft:(UIView*) view;
+(void) slideFromRight:(UIView*) view;
+(void) slideSubViewAsTeam:(UIView*) view viewTag:(int) tag;
@end
