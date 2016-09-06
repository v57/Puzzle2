//
//  Button.h
//  Puzzle2
//
//  Created by Dmitry on 10/17/13.
//  Copyright (c) 2013 LinO_dska. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SKSpriteNode;
@interface Button : NSObject
@property BOOL rounded;
@property float size;
@property SKSpriteNode *view;
@property SKSpriteNode *viewDown;
@property BOOL tapIn;
@property CGRect rect;
@property BOOL active;
@end
