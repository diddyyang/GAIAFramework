//
//  ChatMenu.m
//  XMPPDemo
//
//  Created by 杨铁 on 2019/9/5.
//  Copyright © 2019 UnSee. All rights reserved.
//

#import "ChatMenu.h"

@implementation ChatMenu
-(id)initWithXMLElement:(NSXMLElement*) element {
    self = [super init];
    if(self) {
        self.text = element.stringValue;
        self.action = [element attributeStringValueForName:@"action"];
        self.displayMode = BUTTON;
        if([@"popup" isEqualToString:[element attributeStringValueForName:@"display-mode"]])
            self.displayMode = POPUP;
    }
    return self;
}
@end
