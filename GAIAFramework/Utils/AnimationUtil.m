//
//  AnimationUtil.m
//  GuoXinApp
//
//  Created by 杨铁 on 2018/9/6.
//  Copyright © 2018年 UnSee. All rights reserved.
//

#import "AnimationUtil.h"

@implementation AnimationUtil
+(void) slideFromLeft:(UIView*) view
{
    CATransition *transitionToRight= [CATransition animation];
    
    transitionToRight.duration = .45f;
    
    transitionToRight.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    transitionToRight.type = kCATransitionPush;
    
    transitionToRight.subtype = kCATransitionFromLeft;
    
    transitionToRight.fillMode = kCAFillModeBackwards;
    
    transitionToRight.speed = 0.5f ;
    
    transitionToRight.removedOnCompletion = YES;
    
    [view.layer removeAllAnimations];
    [view.layer addAnimation:transitionToRight forKey:nil];
}

+(void) slideFromRight:(UIView*) view
{
    CATransition *transitionToLeft = [CATransition animation];
    
    transitionToLeft.duration = .45f;
    
    transitionToLeft.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    transitionToLeft.type = kCATransitionPush;
    
    transitionToLeft.subtype = kCATransitionFromRight;
    
    transitionToLeft.fillMode = kCAFillModeBackwards;
    
    transitionToLeft.speed = 0.5f ;
    
    transitionToLeft.removedOnCompletion = YES;
    
    [view.layer removeAllAnimations];
    [view.layer addAnimation:transitionToLeft forKey:nil];
}

+(void) slideSubViewAsTeam:(UIView*) view viewTag:(int) tag;
{
    int effectCount = 0;
    for(UIView* child in view.subviews) {
        if(child.tag == tag) {
            if((effectCount++)%2 == 0)
                [AnimationUtil slideFromLeft: child];
            else
                [AnimationUtil slideFromRight: child];
        }
    }
}
@end
