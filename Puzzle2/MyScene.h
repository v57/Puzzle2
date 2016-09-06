//
//  MyScene.h
//  Puzzle2
//

//  Copyright (c) 2013 LinO_dska. All rights reserved.
//
#define RP 30
#define TEXTCOLOR [SKColor whiteColor]
#define BACKGROUNDCOLOR [SKColor brownColor]
#define NOCOLOR [SKColor redColor]
#define LIGHTCOLOR [SKColor colorWithRed:224.0f/255.0f green:161.0f/255.0f blue:93.0f/255.0f alpha:1.0f]
#define DARKCOLOR [SKColor colorWithRed:155.0f/255.0f green:102.0f/255.0f blue:46.0f/255.0f alpha:1.0f]

#define MENUFPX 940
#define MENUFPY 30
#define MENUFP CGPointMake(MENUFPX, MENUFPY)
#define RESTARTFPX 990
#define RESTARTFPY 30
#define RESTARTFP CGPointMake(RESTARTFPX, RESTARTFPY)
#define NEXTLEVELMPX self.size.width/2
#define NEXTLEVELMPY self.size.height/2
#define BOXX self.size.width/2
#define BOXY 50
#define TIPX 30
#define TIPY 30
#define AHS 4

#define PFS 0.1
#define PBS 0.07f
#define PMS 0.02f

#define MLS 200
#define MLDX 100
#define MLDY 360
#define MLB 20

#define VERSION @"1028"


#define YEP YES

#import <SpriteKit/SpriteKit.h>
@class Button;
@class Touch;
@class Puzzle;
@interface MyScene : SKScene

@property NSMutableArray *puzzles;

@property NSMutableArray *levelPreviews;

@property BOOL completed;

@property SKSpriteNode*completedLabel;

@property Button*nextLevelButton;
@property Button*menuButton;
@property Button*restartButton;
@property Button*box;
@property Button*tip;

@property SKShapeNode *effect;

@property Button*buttonClicked;
@property Puzzle*puzzleClicked;
@property NSMutableArray *grabbed;
@property BOOL puzzleNearBox;
@property int dx;
@property int dy;
@property CGPoint lastTap;

@property BOOL canTouch;
@property NSMutableArray *boxStorage;
@property NSMutableArray *fieldStorage;

@property Puzzle *firstPuzzle;
@property CGPoint fieldPos;
@property int puzzlesLeft;

@property int level;
@property int levels;

@property NSDictionary *root;

@property BOOL boxOpened;
@property BOOL fieldOpened;
@property BOOL menuOpened;
@property BOOL mainMenuOpened;

@property SKLabelNode *loading;

@property int lmx;
@property int lmy;
@property int ldx;
@property int ldy;

@property BOOL tipAnimation;

@property SKLabelNode *version;

@property SKLabelNode*test;

@end
