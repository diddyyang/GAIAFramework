//
//  JSONUtil.m
//  GAIAFramework
//
//  Created by 杨铁 on 2020/3/1.
//  Copyright © 2020 UnSee Corp. All rights reserved.
//

#import "JSONUtil.h"

@implementation JSONUtil

+(NSString*)toJSON:(id)obj {
    NSError *error;
       
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:&error];

    NSString *jsonString;

    if (!jsonData) {
       NSLog(@"%@",error);
    }else{
       jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }

    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];

    NSRange range = {0,jsonString.length};

    //去掉字符串中的空格

    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];

    NSRange range2 = {0,mutStr.length};

    //去掉字符串中的换行符

    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];

    return mutStr;
}

@end
