//
//  DictionaryProxy.m
//  YMCRM
//
//  Created by Yang Diddy on 2017/8/23.
//  Copyright © 2017年 安舍科技. All rights reserved.
//

#import "DictionaryProxy.h"

@implementation DictionaryProxy
-(void)getRemotingDictionary:(NSString*) dictionaryName queryParams:(NSDictionary*) queryParams success:(HTTP_SUCCESSFUL)success failure:(HTTP_FAILED)failure
{
    NSString* queryDictionaryUrl = [NSString stringWithFormat:@"%@?verb=%@", DICTIONARY_SERVLET_PATH, VERB_LIST];
  //  /server/Dictionary.action？verb=list
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    if(queryParams)
        [params addEntriesFromDictionary:queryParams];
    [params setValue:dictionaryName forKey:@"dictName"];
    
    [[GAIAHTTPRequest shared] GetWithUrl:queryDictionaryUrl parameter:params whenSuccessful:^(Result *result) {
        if(result.success) {
            NSError *error = nil;
            NSData *jsonData = [result.params[@"dictionary"] dataUsingEncoding:NSUTF8StringEncoding];
            
            result.tag = [NSJSONSerialization
                             JSONObjectWithData:jsonData
                             options:0
                             error:&error];
            if(error) {
                failure(error);
            } else {
                success(result);
            }
        } else {
            failure([NSError errorWithDomain:NSCocoaErrorDomain code:400 userInfo:nil]);
        }
    } whenFailed:^(NSError *error) {
        failure(error);
    }];
}

-(void)getRemotingDictionary:(NSString*) dictionaryName success:(HTTP_SUCCESSFUL)success failure:(HTTP_FAILED)failure
{
    [self getRemotingDictionary:dictionaryName queryParams:nil success:success failure:failure];
}

@end
