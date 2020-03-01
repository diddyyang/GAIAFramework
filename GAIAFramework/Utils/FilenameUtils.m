//
//  FilenameUtils.m
//  GuoXinApp
//
//  Created by 杨铁 on 2019/7/15.
//  Copyright © 2019 UnSee. All rights reserved.
//

#import "FilenameUtils.h"

@implementation FilenameUtils

+(NSString *)uniqueFileName {
    return [[NSUUID UUID] UUIDString];
}

@end
