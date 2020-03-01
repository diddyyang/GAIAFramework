//
//  GAIAHTTPRequest.m
//  one
//
//  Created by newbee on 2018/9/19.
//  Copyright © 2018年 newbee. All rights reserved.
//

#import "GAIAHTTPRequest.h"
#import "Log.h"
#import "LocalStorage.h"
#import "JSONUtil.h"

@interface GAIAHTTPRequest ()
@property(nonatomic,strong) NSData *cookiesData;

@end

@implementation GAIAHTTPRequest

+(GAIAHTTPRequest *)shared{
    static GAIAHTTPRequest *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GAIAHTTPRequest alloc]init];
    });
    return manager;
}

-(NSURLSessionDataTask *)PostWithUrl:(NSString *)url parameter:(NSDictionary *)params whenSuccessful:(HTTP_SUCCESSFUL)onSuccessful whenFailed:(HTTP_FAILED)onFailed
{
    return [self PostURLWitCookie:url withCookies:[[LocalStorage shared] getUserCookies] parameter:params whenSuccessful:onSuccessful whenFailed:onFailed];
}

-(NSURLSessionDataTask *)PostURLWitCookie:(NSString *)url withCookies:(NSArray<NSHTTPCookie*>*)cookies parameter:(NSDictionary *)params  whenSuccessful:(HTTP_SUCCESSFUL)onSuccessful whenFailed:(HTTP_FAILED)onFailed
{
#ifdef DEBUG
    DLog(@"------------------------------------------------------");
    DLog(@"post with url: %@", url);
    DLog(@"post data with following:");
    DLog(@"%@", params);
    DLog(@"------------------------------------------------------");
#endif
    AFHTTPSessionManager *manager = [self buildAFRequestManagerWithCookies:cookies];
    manager.responseSerializer = [AFJSONResponseSerializer new];
 
    NSURLSessionDataTask *task = [manager POST:url parameters:[self dealParams:params] progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject[@"success"] boolValue]==YES) {
            onSuccessful([Result resultFromDictionary:responseObject]);
        }else{
            NSError *error = [NSError errorWithDomain:responseObject[@"message"]?responseObject[@"message"]:@"" code:999 userInfo:@{}];
            onFailed(error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSHTTPURLResponse *r = (NSHTTPURLResponse *)task.response;
            NSLog(@"%@" ,[r allHeaderFields]);
        }
#ifdef DEBUG
        DLog(@"------------------------------------------------------");
        DLog(@"post data failed:");
        DLog(@"%@", error);
        DLog(@"------------------------------------------------------");
#endif
        onFailed(error);
    }];
    return task;
}

-(NSURLSessionDataTask *)GetWithUrl:(NSString *)url parameter:(NSDictionary *)params  whenSuccessful:(HTTP_SUCCESSFUL)onSuccessful whenFailed:(HTTP_FAILED) onFailed{
    AFHTTPSessionManager *manager = [self buildAFRequestManager];
    manager.responseSerializer = [AFJSONResponseSerializer new];
    NSURLSessionDataTask *task = [manager GET:url parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        onSuccessful(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        onFailed(error);
    }];
    return task;
}


-(AFHTTPSessionManager*)buildAFRequestManager
{
    return [self buildAFRequestManagerWithCookies:[[LocalStorage shared] getUserCookies]];
}

-(AFHTTPSessionManager*)buildAFRequestManagerWithCookies:(NSArray<NSHTTPCookie*>*)cookies
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration: configuration];
    for(NSHTTPCookie* cookie in cookies){
        [[NSHTTPCookieStorage sharedHTTPCookieStorage]setCookie:cookie];
    }
    return manager;
}

-(void)cancelAllOperations{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration: configuration];
    [manager.operationQueue cancelAllOperations];
}

//处理参数
-(NSDictionary *)dealParams:(NSDictionary *)params{
    NSMutableDictionary *dic = [params mutableCopy];
    
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]||[obj isKindOfClass:[NSArray class]]) {
            NSString *stringValue = [JSONUtil toJSON: obj];
            [dic setValue:stringValue forKey:key];
        }
    }];
    
    return dic;
}

@end
