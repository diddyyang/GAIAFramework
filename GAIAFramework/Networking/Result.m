//
//  Result.m
//  GXExApp
//
//  Created by 杨铁 on 2018/8/17.
//  Copyright © 2018年 UnSee. All rights reserved.
//

#import "Result.h"

@implementation Result
-(void) setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"key(%@) is not exist in class[Result] properties", key);
}

+(Result*)resultFromDictionary:(NSDictionary*) dictionary {
    Result* result = [Result new];
    [result setValuesForKeysWithDictionary:dictionary];
    
    return result;
}

@end
