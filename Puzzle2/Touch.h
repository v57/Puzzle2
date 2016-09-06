//
//  Touch.h
//  Puzzle2
//
//  Created by Dmitry on 10/17/13.
//  Copyright (c) 2013 LinO_dska. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Button;
@class Puzzle;
@interface Touch : NSObject
@property Button *button;
@property Puzzle *puzzle;
@end
