//
//  DictionaryItemPickerView.h
//  YMCRM
//
//  Created by Yang Diddy on 2017/8/23.
//  Copyright © 2017年 安舍科技. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BOTTOM_ZONE_HEIGHT 40

typedef void (^whenConfirmChoose)(id data);

@interface DictionaryItemPickerView : UIView<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (nonatomic,retain) UITableView* tableView;
@property (nonatomic,retain) UIButton* btnOK;

+(void) popup:(NSString*) dictionaryName queryParams:(NSDictionary*) queryParams multiSelection:(BOOL) multiSelection parentView:(UIView*) superView callback:(whenConfirmChoose) confirmChoose;

+(void) popup:(NSString*) dictionaryName queryParams:(NSDictionary*) queryParams parentView:(UIView*) superView callback:(whenConfirmChoose) confirmChoose;
@end
