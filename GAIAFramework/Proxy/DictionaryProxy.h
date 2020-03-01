//
//  DictionaryProxy.h
//  YMCRM
//
//  Created by Yang Diddy on 2017/8/23.
//  Copyright © 2017年 安舍科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GAIAHTTPRequest.h"

#define DICTIONARY_SERVLET_PATH @"/server/Dictionary.action"

@interface DictionaryProxy : NSObject

-(void)getRemotingDictionary:(NSString*) dictionaryName queryParams:(NSDictionary*) queryParams success:(HTTP_SUCCESSFUL)success failure:(HTTP_FAILED)failure;

-(void)getRemotingDictionary:(NSString*) dictionaryName success:(HTTP_SUCCESSFUL)success failure:(HTTP_FAILED)failure;

@end
