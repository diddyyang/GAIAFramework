//
//  Result.h
//  GXExApp
//
//  Created by 杨铁 on 2018/8/17.
//  Copyright © 2018年 UnSee. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Result;

// HTTP成功的回调
typedef void (^HTTP_SUCCESSFUL)(Result* result);

// HTTP失败的回调
typedef void (^HTTP_FAILED)(NSError *error);

@interface Result : NSObject

@property (nonatomic) BOOL success;
@property (copy, nonatomic) NSString* message;
@property (strong, nonatomic) NSDictionary<NSString*, NSString*>* params;
@property (nonatomic, weak) id tag;

+(Result*) resultFromDictionary:(NSDictionary*) dictionary;

@end
