//
//  Puzzle.m
//  Puzzle2
//
//  Created by Dmitry on 10/17/13.
//  Copyright (c) 2013 LinO_dska. All rights reserved.
//

#import "Puzzle.h"
#import <SpriteKit/SpriteKit.h>
#import "LinX.h"

@implementation Puzzle
-(BOOL)tapOn:(CGPoint)pos {
    
    BOOL on = NO;
    if(self.hitbox) {
        on = CGPathContainsPoint(self.hitbox, nil, pos, NO);
    }
    else {
        on = CGRectContainsPoint(self.rect, pos);
    }
    
    return on;
}

@end
