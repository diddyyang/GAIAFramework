//
//  TypeDefine.h
//  YMCRM
//
//  Created by 杨铁 on 2017/8/30.
//  Copyright © 2017年 安舍科技. All rights reserved.
//

#ifndef TypeDefine_h
#define TypeDefine_h

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

#endif /* TypeDefine_h */
