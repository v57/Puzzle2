//
//  Puzzle.h
//  Puzzle2
//
//  Created by Dmitry on 10/17/13.
//  Copyright (c) 2013 LinO_dska. All rights reserved.
//
#define PUZZLESCALE 0.07f

#import <Foundation/Foundation.h>
@class SKSpriteNode;
@interface Puzzle : NSObject
@property SKSpriteNode*view;
@property BOOL onField;
@property CGRect rect;
@property BOOL inPlace;
@property CGRect rightPlace;
@property CGPoint pos;
@property CGMutablePathRef hitbox;
@property NSMutableArray *attachment;
@property BOOL fullAttached;
@property BOOL grabbed;
-(BOOL)tapOn:(CGPoint)pos;
@end
