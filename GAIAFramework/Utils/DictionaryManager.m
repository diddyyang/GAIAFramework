//
//  DictionaryManager.m
//  YMCRM
//
//  Created by Yang Diddy on 2017/8/23.
//  Copyright © 2017年 安舍科技. All rights reserved.
//

#import "DictionaryManager.h"
#import "DictionaryProxy.h"
#import "Log.h"

@implementation DictionaryManager

-(instancetype) init {
    if((self = [super init])) {
        _cachedDictionary = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

+(instancetype)shareInstance
{
    static DictionaryManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        manager=[[DictionaryManager alloc] init];
    });
    
    return manager;
}

-(void) cacheDictionary:(NSString*) dictName data:(NSArray<NSDictionary*>*) data {
    if(_cachedDictionary.count > 10) {
        [_cachedDictionary removeAllObjects];
    }
    
    [_cachedDictionary setObject:data forKey:dictName];
}

-(void) getDictionaryByName:(NSString*) dictName queryParams:(NSDictionary*)queryParams whenGot:(whenDictionaryGot) whenGot
{
    DLog(@"%@", dictName);
    if([_cachedDictionary valueForKey:dictName]) {
        whenGot([_cachedDictionary objectForKey:dictName]);
    } else {
        dispatch_queue_t backgroundQueue = dispatch_queue_create("getDictionaryQuery", 0);
        
        dispatch_async(backgroundQueue, ^{
            DictionaryProxy* proxy = [[DictionaryProxy alloc] init];
            [proxy getRemotingDictionary:dictName queryParams:queryParams success:^(Result *result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self cacheDictionary:dictName data:result.tag];
                    whenGot(result.tag);
                });
            } failure:^(NSError *error) {
                DLog(@"获取字典失败：%@", error);
            }];
        });
    }
}

-(void) lookup:(NSString*) dictName queryParams:(NSDictionary*)queryParams key:(NSString*) key whenFound:(whenLookupDone) whenFound {
    [self getDictionaryByName:dictName queryParams: queryParams whenGot:^(NSArray<NSDictionary *> *data) {
       BOOL found = NO;
       for(NSDictionary* dict in data) {
           if((found = [dict[@"key"] isEqualToString:key])) {
               whenFound(found, dict);
               return;
           }
       }
       
       whenFound(found, nil);
   }];
}

@end
