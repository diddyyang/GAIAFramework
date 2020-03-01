//
//  UserModel.h
//  KMMC
//
//  Created by newbee on 2018/11/28.
//  Copyright © 2018年 newbee. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LocalStorage : NSObject
{
}

+(LocalStorage *)shared;

//cookie
-(void)removeCookie;
-(void)saveCookie;
-(NSArray<NSHTTPCookie*>* _Nonnull)getUserCookies;

@end

NS_ASSUME_NONNULL_END
