//
//  Attachment.h
//  Puzzle2
//
//  Created by Dmitry on 10/25/13.
//  Copyright (c) 2013 LinO_dska. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Puzzle;
@interface Attachment : NSObject
@property Puzzle *puzzle;
@property CGPoint center;
@property CGRect hitbox;
@property BOOL attached;

@end
