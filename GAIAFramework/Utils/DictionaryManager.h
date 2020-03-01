//
//  DictionaryManager.h
//  YMCRM
//
//  Created by Yang Diddy on 2017/8/23.
//  Copyright © 2017年 安舍科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictionaryManager : NSObject

typedef void (^whenDictionaryGot)(NSArray<NSDictionary*>* data);
typedef void (^whenLookupDone)(BOOL found, NSDictionary* dictionary);

+(instancetype)shareInstance;

@property (nonatomic, retain) NSMutableDictionary* cachedDictionary;
-(void) getDictionaryByName:(NSString*) dictName queryParams:(NSDictionary*)queryParams whenGot:(whenDictionaryGot) whenGot;
-(void) lookup:(NSString*) dictName queryParams:(NSDictionary*)queryParams key:(NSString*) key whenFound:(whenLookupDone) whenFound;
@end
