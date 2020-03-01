//
//  GAIAHTTPRequest.h
//  one
//
//  Created by newbee on 2018/9/19.
//  Copyright © 2018年 newbee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Result.h"
#import "GAIANetwork.h"
#import "AFNetworking.h"

@interface GAIAHTTPRequest : NSObject

+(GAIAHTTPRequest *)shared;


-(void)cancelAllOperations;

-(NSURLSessionDataTask *)GetWithUrl:(NSString *)url parameter:(NSDictionary *)params  whenSuccessful:(HTTP_SUCCESSFUL)onSuccessful whenFailed:(HTTP_FAILED) onFailed;

-(NSURLSessionDataTask *)PostWithUrl:(NSString *)url parameter:(NSDictionary *)params whenSuccessful:(HTTP_SUCCESSFUL) onSuccessful whenFailed:(HTTP_FAILED) onFailed;

-(NSURLSessionDataTask *)PostURLWitCookie:(NSString *)url withCookies:(NSArray<NSHTTPCookie*>*)cookies parameter:(NSDictionary *)params  whenSuccessful:(HTTP_SUCCESSFUL)onSuccessful whenFailed:(HTTP_FAILED)onFailed;

@end
