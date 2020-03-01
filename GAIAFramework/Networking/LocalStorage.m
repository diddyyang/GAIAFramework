//
//  UserModel.m
//  one
//
//  Created by newbee on 2018/9/19.
//  Copyright © 2018年 newbee. All rights reserved.
//

#import "LocalStorage.h"

#define USERINFOKEY   @"userInfoKey"
#define UUIDKEY       @"UUIDKEY"
#define FIRSTKEY      @"FIRSTKEY"
#define  Save_Cookie_PATH   @"gaia.cookies"



@implementation LocalStorage

+(LocalStorage *)shared {
    static LocalStorage *model = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        model = [[LocalStorage alloc]init];
    });
    return model;
}


-(void)removeCookie {
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookieArray = [NSArray arrayWithArray:[cookieJar cookies]];
    [NSKeyedArchiver archivedDataWithRootObject:cookieArray requiringSecureCoding:YES error:nil];
    
    for (id obj in cookieArray) {
        [cookieJar deleteCookie:obj];
    }
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:Save_Cookie_PATH];
}

-(void)saveCookie {
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookieArray = [NSArray arrayWithArray:[cookieJar cookies]];
    NSData* cookiesData = [NSKeyedArchiver archivedDataWithRootObject:cookieArray requiringSecureCoding:YES error:nil];
    if ([cookiesData length]>0) {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        [user removeObjectForKey:Save_Cookie_PATH];
        [user setObject:cookiesData forKey:Save_Cookie_PATH];
    }
    
}

-(NSArray<NSHTTPCookie*> * _Nonnull)getUserCookies{
    NSData *cookieData = [[NSUserDefaults standardUserDefaults] objectForKey:Save_Cookie_PATH];
    if ([cookieData length]) {
        return [NSKeyedUnarchiver unarchivedObjectOfClass:[NSArray class] fromData:cookieData error:nil];
    }
    return @[];
}

@end
