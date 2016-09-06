//
//  MyScene.m
//  Puzzle2
//
//  Created by Dmitry on 10/17/13.
//  Copyright (c) 2013 LinO_dska. All rights reserved.
//

#import "MyScene.h"
#import "Button.h"
#import "Puzzle.h"
#import "LinX.h"
#import "Animations.m"
#import "Attachment.h"

@implementation MyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        [self firstLoad];
        [self mainMenu];
    }
    return self;
}

-(void)mainMenu {
    self.mainMenuOpened = YES;
    [self activateButton:self.menuButton];
    self.menuButton.view.position = CGPointMake(NEXTLEVELMPX, 0);
    [self moveButton:self.menuButton to:CGPointMake(NEXTLEVELMPX, NEXTLEVELMPY) for:0.4f];
}

-(void)startLevel:(int)level {
    if(self.puzzles.count || self.fieldStorage.count || self.boxStorage.count) {
        self.loading.text = @"ERROR";
        self.loading.fontColor = [SKColor redColor];
        return;
    }
    [self initPuzzles:level];
    [self activateButton:self.restartButton];
    [self activateButton:self.menuButton];
    [self activateButton:self.tip];
    self.restartButton.view.position = CGPointMake(RESTARTFPX, RESTARTFPY-50);
    self.menuButton.view.position = CGPointMake(MENUFPX, MENUFPY-50);
    [self moveButton:self.menuButton to:MENUFP for:0.4f];
    [self moveButton:self.restartButton to:RESTARTFP for:0.4f];
    [self moveButton:self.tip to:CGPointMake(TIPX, TIPY) for:0.4f];
    if(!self.fieldOpened) {
        self.fieldOpened = YES;
        [self showBox];
    }
}

-(void)restart {
    float t = 0.5f;
    [self clearPuzzles:t];
    [self runAction:[SKAction waitForDuration:t+0.1f] completion:^{
        for(Puzzle*puzzle in self.puzzles) {
            [self fall:puzzle];
        }
        [self activateButton:self.restartButton];
        [self activateButton:self.menuButton];
        [self moveButton:self.restartButton to:RESTARTFP for:.3f];
        [self moveButton:self.menuButton to:MENUFP for:.3f];
    }];
}


-(void)fall:(Puzzle*)puzzle {
    float time = 1.0f;
    float waitTime = (float)rdm(0,100)/100.0f;
    
    puzzle.view.xScale = PMS;
    puzzle.view.yScale = PMS;
    puzzle.view.position = CGPointMake(self.box.rect.origin.x+70+rdm(0, 60),1000);
    SKAction *move = [SKAction moveToY:self.box.rect.origin.y+100 duration:time];
    SKAction *rotation = [SKAction rotateToAngle:M_PI/180*rdm(0, 360) duration:time shortestUnitArc:YES];
    self.canTouch = NO;
    [puzzle.view runAction:[SKAction waitForDuration:waitTime] completion:^{
        [puzzle.view runAction:move];
        [puzzle.view runAction:rotation completion:^{
            self.canTouch = YES;
        }];
    }];
    
    [self.boxStorage addObject:puzzle];
    puzzle.onField = NO;
}

-(void)levelCompleted {
    self.completed = YES;
    int border = 50;
    CGPoint completedPos = CGPointMake(self.size.width/2, self.size.height/2+border);
    CGPoint nextPos = CGPointMake(self.size.width/2-border, self.size.height/2);
    CGPoint menuPos = CGPointMake(self.size.width/2, self.size.height/2);
    CGPoint restartPos = CGPointMake(self.size.width/2+border, self.size.height/2);
    float a1 = 0.4f;
    float a2 = 0.3f;
    float a3 = 0.5f;
    float a4 = 0.6f;
    [self.completedLabel runAction:[SKAction moveTo:completedPos duration:a1]];
    [self.nextLevelButton.view runAction:[SKAction waitForDuration:a1+0.1f] completion:^{
        [self moveButton:self.nextLevelButton to:nextPos for:a2];
    }];
    [self.menuButton.view runAction:[SKAction waitForDuration:a3+0.1f] completion:^{
        [self moveButton:self.menuButton to:menuPos for:a2];
    }];
    [self.restartButton.view runAction:[SKAction waitForDuration:a4+0.1f] completion:^{
        [self moveButton:self.restartButton to:restartPos for:a2];
        
    }];
    
    [self addChild:self.completedLabel];
    [self activateButton:self.nextLevelButton];
    [self activateButton:self.menuButton];
    [self activateButton:self.restartButton];
}

-(void)nextLevel {
    float time = 0.5f;
    int b = 0;
    if(self.puzzles) {
        b++;
        [self clearPuzzles:time];
    }
    if(!b) {
        time = 0;
    }
    [self runAction:[SKAction waitForDuration:time] completion:^{
        self.level++;
        if(self.level-1 >= self.levels) {
            self.level = 0;
        }
        [self startLevel:self.level];
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(self.canTouch) {
        for (UITouch *touch in touches) {
            CGPoint location = [touch locationInNode:self];
            self.lastTap = location;
            if(!self.completed) {
                if(self.boxOpened) {
                    for(Puzzle*puzzle in self.boxStorage) {
                        CGPoint p = [touch locationInNode:puzzle.view];
                        p.x *= PFS;
                        p.y *= PFS;
                        if([puzzle tapOn:p]) {
                            [self moveFromBox:puzzle];
                            self.dx = location.x - puzzle.view.position.x;
                            self.dy = location.y - puzzle.view.position.y;
                            self.puzzleClicked = puzzle;
                            break;
                        }
                    }
                    [self closeBox];
                }
                else {
                    if(CGRectContainsPoint(self.box.rect, location) && self.box.active) {
                        self.buttonClicked = self.box;
                        self.buttonClicked.tapIn = YES;
                        [self addChild:self.buttonClicked.viewDown];
                    }
                    else {
                        //puzzles
                        for(Puzzle*puzzle in self.fieldStorage) {
                            CGPoint p = [touch locationInNode:puzzle.view];
                            p.x *= PFS;
                            p.y *= PFS;
                            if([puzzle tapOn:p]) {
                                //[self moveToBox:puzzle];
                                self.dx = location.x - puzzle.view.position.x;
                                self.dy = location.y - puzzle.view.position.y;
                                self.puzzleClicked = puzzle;
                                [self grab:puzzle];
                                break;
                            }
                        }
                    }
                }
            }
            
                if(self.nextLevelButton.active && findDistanse(location, self.nextLevelButton.view.position) < self.nextLevelButton.size) {
                    self.buttonClicked = self.nextLevelButton;
                    self.buttonClicked.tapIn = YES;
                    [self addChild:self.nextLevelButton.viewDown];
                }
                else if(self.menuButton.active && findDistanse(location, self.menuButton.view.position) < self.menuButton.size) {
                    self.buttonClicked = self.menuButton;
                    self.buttonClicked.tapIn = YES;
                    [self addChild:self.buttonClicked.viewDown];
                }
                else if(self.restartButton.active && findDistanse(location, self.restartButton.view.position) < self.restartButton.size) {
                    self.buttonClicked = self.restartButton;
                    self.buttonClicked.tapIn = YES;
                    [self addChild:self.buttonClicked.viewDown];
                }
                else if(self.tip.active && findDistanse(location, self.tip.view.position) < self.tip.size) {
                    [self showTip];
                    self.buttonClicked = self.tip;
                    self.buttonClicked.tapIn = YES;
                    [self addChild:self.buttonClicked.viewDown];
                }
        }
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        float dx = location.x - self.lastTap.x;
        float dy = location.y - self.lastTap.y;
        self.lastTap = location;
        if(self.buttonClicked) {
            if(self.buttonClicked.rounded) {
                float distance = findDistanse(location, self.buttonClicked.view.position);
                if(self.buttonClicked.tapIn) {
                    if(distance>self.buttonClicked.size) {
                        if(self.buttonClicked == self.tip) [self hideTip];
                        self.buttonClicked.tapIn = NO;
                        [self.buttonClicked.viewDown removeFromParent];
                    }
                }
                else {
                    if(distance<self.buttonClicked.size) {
                        if(self.buttonClicked == self.tip) [self showTip];
                        self.buttonClicked.tapIn = YES;
                        [self addChild:self.buttonClicked.viewDown];
                    }
                }
            }
            else {
                BOOL on = CGRectContainsPoint(self.buttonClicked.rect, location);
                if(self.buttonClicked.tapIn) {
                    if(!on) {
                        self.buttonClicked.tapIn = NO;
                        [self.buttonClicked.viewDown removeFromParent];
                    }
                }
                else {
                    if(on) {
                        self.buttonClicked.tapIn = YES;
                        [self addChild:self.buttonClicked.viewDown];
                    }
                }
            }
        }
        else if(self.puzzleClicked) {
            if(self.grabbed.count) {
                for(Puzzle*puzzle in self.grabbed) {
                    CGPoint p = puzzle.view.position;
                    p.x += dx;
                    p.y += dy;
                    puzzle.view.position = p;
                }
            }
            else {
                CGPoint p = self.puzzleClicked.view.position;
                p.x += dx;
                p.y += dy;
                self.puzzleClicked.view.position = p;
                
            }
            
            CGRect r = self.puzzleClicked.rect;
            r.origin.x = self.puzzleClicked.view.position.x - r.size.width/2;
            r.origin.y = self.puzzleClicked.view.position.y - r.size.height/2;
            BOOL puzzleNearBox = CGRectIntersectsRect(self.box.rect, r);
            if(self.puzzleNearBox) {
                if(!puzzleNearBox) {
                    self.puzzleNearBox = NO;
                    [self.box.viewDown removeFromParent];
                }
            }
            else {
                if(puzzleNearBox) {
                    self.puzzleNearBox = YES;
                    [self addChild:self.box.viewDown];
                }
            }
        }
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        
        if(self.menuOpened) {
            int maxx = self.lmx -1;
            int maxy = self.lmy -1;
            int x = (location.x-self.ldx)/(MLS+MLB);
            int y = maxy+1 - (location.y-self.ldy)/(MLS+MLB);
            if(x>=0 && x<=maxx && y>=0 && y<=maxy) {
                int level = x+(maxx+1)*y;
                [self selectLevel:level];
            }
        }
        if(self.buttonClicked) {[self clickButton:self.buttonClicked];}

        if(!self.completed) {
            if(self.buttonClicked) {
                if(self.buttonClicked == self.box && self.buttonClicked.tapIn) {
                    self.buttonClicked.tapIn = NO;
                    [self.buttonClicked.viewDown removeFromParent];
                    [self openBox];
                }
            }
            else if(self.puzzleClicked) {
                if(self.puzzleNearBox) {
                    [self moveToBox:self.puzzleClicked];
                    [self.box.viewDown removeFromParent];
                }
                else {
                    [self checkForAttachment:self.puzzleClicked];
                    for(Puzzle*p in self.grabbed) {
                        if(p!= self.puzzleClicked) {
                            [self checkForAttachment:p];
                        }
                        p.grabbed = NO;
                    }
                    [self.grabbed removeAllObjects];
                    
                    BOOL first = self.puzzleClicked == self.firstPuzzle;
                    if(first) {
                        self.fieldPos = self.firstPuzzle.view.position;
                    }
                    if(self.fieldStorage.count==self.puzzles.count) {
                        int attached = [self attachedCount:self.puzzleClicked];
                        for(Puzzle*puzzle in self.grabbed) {
                            puzzle.grabbed = NO;
                        }
                        [self.grabbed removeAllObjects];
                        if(attached == self.puzzles.count) {
                            [self levelCompleted];
                        }
                    }
                }
            }
        }
        else {
            
        }
        self.buttonClicked = nil;
        self.puzzleClicked = nil;
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    self.test.text = [NSString stringWithFormat:@"boxOpened[%d] fieldOpened[%d] menuOpened[%d] mainMenuOpened[%d]",self.boxOpened,self.fieldOpened,self.menuOpened,self.mainMenuOpened];
}

-(void)moveToBox:(Puzzle*)puzzle {
    puzzle.onField = NO;
    float time = .3f;
    [self.boxStorage addObject:puzzle];
    [self.fieldStorage removeObject:puzzle];
    
    SKAction *move = [SKAction moveTo:CGPointMake(self.box.rect.origin.x+70+rdm(0, 60),self.box.rect.origin.y+100) duration:time];
    SKAction *resize = [SKAction scaleXTo:PMS y:PMS duration:time];
    SKAction *rotation = [SKAction rotateToAngle:M_PI/180*rdm(0, 360) duration:time shortestUnitArc:YES];
    [puzzle.view runAction:move];
    [puzzle.view runAction:resize];
    [puzzle.view runAction:rotation];
}

-(void)moveFromBox:(Puzzle*)puzzle {
    puzzle.view.zPosition = 0;
    puzzle.onField = YES;
    [self.boxStorage removeObject:puzzle];
    [self.fieldStorage addObject:puzzle];
    float time = .1f;
    SKAction *resize = [SKAction scaleXTo:PFS y:PFS duration:time];
    SKAction *invisibru = [SKAction fadeAlphaTo:1 duration:time];
    [puzzle.view runAction:resize];
    [puzzle.view runAction:invisibru];
}

-(void)initPuzzles:(int)level {
    self.canTouch = NO;
    NSArray *levels = [self.root objectForKey:@"Levels"];
    NSArray *gameLevel = [levels objectAtIndex:level];
    for(int i=0;i<gameLevel.count;i++) {
        NSDictionary *a = [gameLevel objectAtIndex:i];
        int x = [[a objectForKey:@"x"]intValue];
        int y = [[a objectForKey:@"y"]intValue];
        int width = [[a objectForKey:@"width"]intValue];
        int height = [[a objectForKey:@"height"]intValue];
        NSString*imagePath = [NSString stringWithFormat:@"l0p%d.png",i]; /*/////////////// CHANGED ///////////////*/
        //UIImage*image = [UIImage imageNamed:imagePath];
        SKTexture *texture = [SKTexture textureWithImageNamed:imagePath];
        Puzzle*puzzle = [Puzzle new];
        puzzle.view = [SKSpriteNode spriteNodeWithTexture:texture];
        NSArray*hb = [a objectForKey:@"hitbox"];
        
        if(hb) {
            puzzle.hitbox = CGPathCreateMutable();
            for(int i=0;i<hb.count;i++) {
                int x = [[[hb objectAtIndex:i] objectAtIndex:0]intValue];
                int y = [[[hb objectAtIndex:i] objectAtIndex:1]intValue];
                if(i==0) {
                    CGPathMoveToPoint(puzzle.hitbox, nil, x, y);
                }
                else {
                    CGPathAddLineToPoint(puzzle.hitbox, nil, x, y);
                }
            }
        }
        
        puzzle.attachment = [NSMutableArray new];
        
        //puzzle.view.size = CGSizeMake(width,height);
        /*
        puzzle.view.xScale = 0.1;
        puzzle.view.yScale = 0.1;
        puzzle.view.position = CGPointMake(x+width/2+200,self.size.width-y-height/2);
         */
        float waitTime = (float)rdm(0,100)/100.0f;
        
        float time = 1.0f;
        puzzle.view.xScale = PMS;
        puzzle.view.yScale = PMS;
        puzzle.view.position = CGPointMake(self.box.rect.origin.x+70+rdm(0, 60),1000);
        SKAction *move = [SKAction moveToY:self.box.rect.origin.y+100 duration:time];
        SKAction *rotation = [SKAction rotateToAngle:M_PI/180*rdm(0, 360) duration:time shortestUnitArc:YES];
        [puzzle.view runAction:[SKAction waitForDuration:waitTime] completion:^{
            [puzzle.view runAction:move];
            [puzzle.view runAction:rotation];
        }];
        
        [self.boxStorage addObject:puzzle];
        puzzle.onField = NO;
        [self.puzzles addObject:puzzle];
        
        CGRect rightPlace;
        rightPlace.origin.x = x+width/2 - RP;
        rightPlace.origin.y = -y-height/2-RP;
        rightPlace.size.width = RP*2 ;
        rightPlace.size.height = RP*2;
        if(i>0) {
            rightPlace.origin.x -= self.firstPuzzle.view.size.width/2.0f*5 + 1;
            rightPlace.origin.y += self.firstPuzzle.view.size.height/2.0f*5 - 1;
        }
        puzzle.rightPlace = rightPlace;
        
        puzzle.rect = CGRectMake(-width/2,-height/2,width,height);
        //puzzle.boxedView = [SKSpriteNode spriteNodeWithImageNamed:imagePath];
        [self addChild:puzzle.view];
        if(i==0) {
            self.firstPuzzle = puzzle;
        }
        //[self moveToBox:puzzle];
        NSLog(@"Loaded %d%@",(int)((float)(i+1)/(float)gameLevel.count*100.0f),@"%");
    }
    for(int i=0;i<self.puzzles.count;i++) {
        Puzzle*puzzle = [self.puzzles objectAtIndex:i];
        NSArray *at = [[gameLevel objectAtIndex:i] objectForKey:@"attachments"];
        puzzle.attachment = [NSMutableArray new];
        if(at) {
            for(NSArray *atd in at) {
                int x = [[atd objectAtIndex:0]intValue];
                int y = [[atd objectAtIndex:1]intValue];
                int p = [[atd objectAtIndex:2]intValue];
                Attachment*att = [Attachment new];
                att.puzzle = [self.puzzles objectAtIndex:p];
                att.center = CGPointMake(x,y);
                att.hitbox = CGRectMake(att.center.x-AHS, att.center.y-AHS, AHS*2, AHS*2);
                [puzzle.attachment addObject:att];
            }
        }
    }
    for(int i=0;i<50;i++) {
        int i1 = rdm(0, self.puzzles.count);
        int i2 = rdm(0, self.puzzles.count);
        [self changePuzzlesInBox:i1 :i2];
    }
    [self runAction:[SKAction waitForDuration:2.0f] completion:^{
        self.canTouch = YES;
    }];
    [self.loading runAction:[SKAction moveToY:0 duration:0.5f] completion:^{
        [self.loading removeFromParent];
    }];
}

-(void)initLevelCompleted {
    int border = 50;
    float scale = 0.8f;
    self.completedLabel = [SKSpriteNode spriteNodeWithImageNamed:@"Completed.png"];
    self.completedLabel.position = CGPointMake(self.size.width/2, 850);
    self.completedLabel.xScale = scale;
    self.completedLabel.yScale = scale;
    self.completedLabel.zPosition = 3;
    
    self.nextLevelButton = [Button new];
    self.nextLevelButton.view = [SKSpriteNode spriteNodeWithImageNamed:@"NextLevelButton.png"];
    self.nextLevelButton.view.position = CGPointMake(self.size.width/2-border, 50);
    self.nextLevelButton.view.xScale = scale;
    self.nextLevelButton.view.yScale = scale;
    self.nextLevelButton.viewDown = [SKSpriteNode spriteNodeWithImageNamed:@"NextLevelButtonDown.png"];
    self.nextLevelButton.viewDown.position = CGPointMake(self.size.width/2-border, self.size.height/2);
    self.nextLevelButton.viewDown.xScale = scale;
    self.nextLevelButton.viewDown.yScale = scale;
    self.nextLevelButton.size = self.nextLevelButton.view.size.width/2;
    self.nextLevelButton.rounded = YES;
    self.nextLevelButton.view.zPosition = 3;
    self.nextLevelButton.viewDown.zPosition = 3;
    
    self.menuButton = [Button new];
    self.menuButton.view = [SKSpriteNode spriteNodeWithImageNamed:@"MenuButton.png"];
    self.menuButton.view.position = CGPointMake(self.size.width/2, 50);
    self.menuButton.view.xScale = scale;
    self.menuButton.view.yScale = scale;
    self.menuButton.viewDown = [SKSpriteNode spriteNodeWithImageNamed:@"MenuButtonDown.png"];
    self.menuButton.viewDown.position = CGPointMake(self.size.width/2, self.size.height/2);
    self.menuButton.viewDown.xScale = scale;
    self.menuButton.viewDown.yScale = scale;
    self.menuButton.size = self.menuButton.view.size.width/2;
    self.menuButton.rounded = YES;
    self.menuButton.view.zPosition = 3;
    self.menuButton.viewDown.zPosition = 3;
    
    self.restartButton = [Button new];
    self.restartButton.view = [SKSpriteNode spriteNodeWithImageNamed:@"RestartButton.png"];
    self.restartButton.view.position = CGPointMake(self.size.width/2+border, 50);
    self.restartButton.view.xScale = scale;
    self.restartButton.view.yScale = scale;
    self.restartButton.viewDown = [SKSpriteNode spriteNodeWithImageNamed:@"RestartButtonDown.png"];
    self.restartButton.viewDown.position = CGPointMake(self.size.width/2+border, self.size.height/2);
    self.restartButton.viewDown.xScale = scale;
    self.restartButton.viewDown.yScale = scale;
    self.restartButton.size = self.restartButton.view.size.width/2;
    self.restartButton.rounded = YES;
    self.restartButton.view.zPosition = 3;
    self.restartButton.viewDown.zPosition = 3;
    
    self.tip = [Button new];
    self.tip.view = [SKSpriteNode spriteNodeWithImageNamed:@"TipButton.png"];
    self.tip.view.position = CGPointMake(TIPX,TIPY);
    self.tip.view.xScale = scale;
    self.tip.view.yScale = scale;
    self.tip.viewDown = [SKSpriteNode spriteNodeWithImageNamed:@"TipButtonDown.png"];
    self.tip.viewDown.position = CGPointMake(TIPX,TIPY);
    self.tip.viewDown.xScale = scale;
    self.tip.viewDown.yScale = scale;
    self.tip.size = self.restartButton.view.size.width/2;
    self.tip.rounded = YES;
    self.tip.view.zPosition = 3;
    self.tip.viewDown.zPosition = 3;
}


-(void)firstLoad {
    
    self.test = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Bold"];
    self.test.fontSize = 24;
    self.test.position = CGPointMake(self.size.width/2,self.size.height-50);
    //[self addChild:self.test];
    self.test.text = @"test";
    
    self.version = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Bold"];
    self.version.text = VERSION;
    self.version.position = CGPointMake(14, 0);
    self.version.fontSize = 12;
    [self addChild:self.version];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"/Levels/Property" ofType:@"plist"];
    self.root = [NSDictionary dictionaryWithContentsOfFile:path];
    NSArray *levels = [self.root objectForKey:@"Levels"];
    self.levels = levels.count;
    self.level = -1;
    self.levelPreviews = [NSMutableArray new];
    
    int x = 3;
    int y = 2;
    
    int lw = MLB*(x-1) + MLS * x;
    int lh = MLB*(y-1) + MLS * y;
    
    int ldx = (self.size.width - lw)/2;
    int ldy = (self.size.height - lh)/2;
    self.ldx = ldx;
    self.ldy = ldy;
    self.lmx = x;
    self.lmy = y;
    ldx += MLS/2;
    ldy += MLS/2;
    
    for(int i=0;i<x;i++) {
        for(int j=0;j<y;j++) {
            NSString *path = [NSString stringWithFormat:@"l0s"];
            SKTexture*texture = [SKTexture textureWithImageNamed:path];
            SKSpriteNode*preview = [SKSpriteNode spriteNodeWithTexture:texture size:CGSizeMake(MLS, MLS)];
            [self.levelPreviews addObject:preview];
        }
    }
    self.loading = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-Bold"];
    self.loading.text = @"Loading";
    self.loading.fontSize = 24;
    self.grabbed = [NSMutableArray new];
    self.puzzles = [NSMutableArray new];
    self.fieldStorage = [NSMutableArray new];
    self.boxStorage = [NSMutableArray new];
    self.completed = NO;
    self.backgroundColor = LIGHTCOLOR;
    self.canTouch = YES;
    self.box = [Button new];
    self.box.view = [SKSpriteNode spriteNodeWithImageNamed:@"Box.png"];
    self.box.view.position = CGPointMake(BOXX, BOXY-200);
    self.box.viewDown = [SKSpriteNode spriteNodeWithImageNamed:@"BoxDown.png"];
    self.box.viewDown.position = CGPointMake(BOXX,BOXY);
    self.box.view.zPosition = 2;
    self.box.viewDown.zPosition = 2;
    CGRect boxRect;
    boxRect.origin = self.box.viewDown.position;
    boxRect.origin.x -= self.box.viewDown.size.width/2;
    boxRect.origin.y -= self.box.viewDown.size.height/2;
    boxRect.size = self.box.viewDown.size;
    self.box.rect = boxRect;
    
    [self initLevelCompleted];
    
    self.effect = [SKShapeNode new];
    self.effect.path = CGPathCreateWithRect(CGRectMake(0, 0, 1024, 800), nil);
    self.effect.strokeColor = [SKColor clearColor];
    self.effect.fillColor = [SKColor blackColor];
}

-(void)attach:(Attachment*)a1 and:(Attachment*)a2 {
    a1.attached = YES;
    a2.attached = YES;
}

-(int)attachedCount:(Puzzle*)puzzle {
    puzzle.grabbed = YES;
    [self.grabbed addObject:puzzle];
    int n = 1;
    for(Attachment*a in puzzle.attachment) {
        if(a.puzzle.onField && !a.puzzle.grabbed && a.attached) {
            n += [self attachedCount:a.puzzle];
        }
    }
    return n;
}

-(void)grab:(Puzzle*)puzzle {
    puzzle.grabbed = YES;
    [self.grabbed addObject:puzzle];
    for(Attachment*a in puzzle.attachment) {
        if(a.puzzle.onField && !a.puzzle.grabbed && a.attached) {
            [self grab:a.puzzle];
            
        }
    }
}

-(void)openBox {
    self.boxOpened = YES;
    [self addChild:self.effect];
    self.effect.alpha = 0;
    self.canTouch = NO;
    [self.effect runAction:[SKAction fadeAlphaTo:0.8f duration:0.2f] completion:^{
        self.canTouch = YES;
    }];
    int x = 0;
    int y = 0;
    float time = .3f;
    for(Puzzle*puzzle in self.boxStorage) {
        x++;
        if(x>5) {
            x=1;
            y++;
        }
        puzzle.view.zPosition = 2;
        SKAction *invisibru = [SKAction fadeAlphaTo:.5f duration:time];
        SKAction *move = [SKAction moveTo:CGPointMake(200*x-70,650-200*y) duration:time];
        SKAction *resize = [SKAction scaleXTo:PBS y:PBS duration:time];
        SKAction *rotation = [SKAction rotateToAngle:0 duration:time shortestUnitArc:YES];
        [puzzle.view runAction:invisibru];
        [puzzle.view runAction:move];
        [puzzle.view runAction:resize];
        [puzzle.view runAction:rotation];
    }
}

-(void)closeBox {
    self.boxOpened = NO;
    self.canTouch = NO;
    [self.effect runAction:[SKAction fadeAlphaTo:0 duration:0.2f] completion:^{
        [self.effect removeFromParent];
        self.canTouch = YES;
    }];
    float time = .3f;
    for(Puzzle*puzzle in self.boxStorage) {
        puzzle.view.zPosition = 0;
        SKAction *invisibru = [SKAction fadeAlphaTo:1 duration:time];
        SKAction *move = [SKAction moveTo:CGPointMake(self.box.rect.origin.x+70+rdm(0, 60),self.box.rect.origin.y+100) duration:time];
        SKAction *resize = [SKAction scaleXTo:PMS y:PMS duration:time];
        SKAction *rotation = [SKAction rotateToAngle:M_PI/180*rdm(0, 360) duration:time shortestUnitArc:YES];
        [puzzle.view runAction:invisibru];
        [puzzle.view runAction:move];
        [puzzle.view runAction:resize];
        [puzzle.view runAction:rotation];
    }
}
-(void)activateButton:(Button*)button {
    if(!button.active) {
        [self addChild:button.view];
        button.active = YES;
    }
}

-(void)deactivateButton:(Button*)button {
    if(button.active) {
        [button.view removeFromParent];
        button.active = NO;
    }
}

-(void)hideBox {
    if(self.box.active) {
        [self.box.view runAction:[SKAction moveTo:CGPointMake(BOXX, BOXY-200) duration:0.3f]];
        [self deactivateButton:self.box];
    }
}

-(void)showBox {
    if(!self.box.active) {
        [self.box.view runAction:[SKAction moveTo:CGPointMake(BOXX, BOXY) duration:0.3f]];
        [self activateButton:self.box];
    }
}

-(void)moveButton:(Button*)button to:(CGPoint)point for:(float)time {
    [button.view runAction:[SKAction moveTo:point duration:time] completion:^{
        button.viewDown.position = button.view.position;
    }];
}

-(void)closeField:(float)time {
    if(self.fieldOpened) {
        self.fieldOpened = NO;
        [self hideBox];
    }
}

-(void)showTipButton {
    if(!self.tip.active) {
        [self activateButton:self.tip];
        self.tip.view.position = CGPointMake(TIPX, TIPY);
    }
}

-(void)hideTip {
    
    self.tipAnimation = YES;
    float time = .3f;
    for(Puzzle*puzzle in self.fieldStorage) {
        if(puzzle != self.firstPuzzle) {
            [puzzle.view removeAllActions];
            SKAction *move = [SKAction moveTo:puzzle.pos duration:time];
            [puzzle.view runAction:move withKey:@"tip"];
        }
    }
    for(Puzzle*puzzle in self.boxStorage) {
        [puzzle.view removeAllActions];
        SKAction *move = [SKAction moveTo:CGPointMake(self.box.rect.origin.x+70+rdm(0, 60),self.box.rect.origin.y+100) duration:time];
        SKAction *resize = [SKAction scaleXTo:PMS y:PMS duration:time];
        SKAction *rotation = [SKAction rotateToAngle:M_PI/180*rdm(0, 360) duration:time shortestUnitArc:YES];
        [puzzle.view runAction:move];
        [puzzle.view runAction:resize];
        [puzzle.view runAction:rotation];
    }
    
}

-(void)showTip {
    float time = 0.3f;
    if(!self.firstPuzzle.onField) {
        self.fieldPos = CGPointMake(400, 500);
    }
    for(Puzzle*puzzle in self.fieldStorage) {
        if(puzzle != self.firstPuzzle) {
            if([puzzle.view actionForKey:@"tip"]==nil) {
                self.tipAnimation = NO;
            }
            [puzzle.view removeAllActions];
            if(!self.tipAnimation) {puzzle.pos = puzzle.view.position;}
            else {NSLog(@"CANT DO");}
            CGPoint rightPlace;
            rightPlace.x = puzzle.rightPlace.origin.x+RP+self.fieldPos.x+1;
            rightPlace.y = puzzle.rightPlace.origin.y+RP+self.fieldPos.y+1;
            SKAction *move = [SKAction moveTo:rightPlace duration:time];
            [puzzle.view runAction:move];
        }
        
    }
    for(Puzzle*puzzle in self.boxStorage) {
        if(puzzle != self.firstPuzzle) {
            [puzzle.view removeAllActions];
            puzzle.pos = puzzle.view.position;
            CGPoint rightPlace;
            rightPlace.x = puzzle.rightPlace.origin.x+RP+self.fieldPos.x+2;
            rightPlace.y = puzzle.rightPlace.origin.y+RP+self.fieldPos.y+1;
            //SKAction *invisibru = [SKAction fadeAlphaTo:.5f duration:time];
            SKAction *move = [SKAction moveTo:rightPlace duration:time];
            SKAction *resize = [SKAction scaleXTo:PFS y:PFS duration:time];
            SKAction *rotation = [SKAction rotateToAngle:0 duration:time shortestUnitArc:YES];
            //[puzzle.view runAction:invisibru];
            [puzzle.view runAction:move];
            [puzzle.view runAction:resize];
            [puzzle.view runAction:rotation];
        }
        else {
            [puzzle.view removeAllActions];
            puzzle.pos = puzzle.view.position;
            SKAction *move = [SKAction moveTo:self.fieldPos duration:time];
            SKAction *resize = [SKAction scaleXTo:PFS y:PFS duration:time];
            SKAction *rotation = [SKAction rotateToAngle:0 duration:time shortestUnitArc:YES];
            [puzzle.view runAction:move];
            [puzzle.view runAction:resize];
            [puzzle.view runAction:rotation];
        }
    }
}

-(void)clearPuzzles:(float)time {
    if(self.fieldStorage.count+self.boxStorage.count) {
        for(Puzzle*puzzle in self.fieldStorage) {
            [puzzle.view removeAllActions];
            [puzzle.view runAction:[SKAction moveBy:CGVectorMake(1200, 0) duration:time] completion:^{
                [puzzle.view removeFromParent];
            }];
        }
        for(Puzzle*puzzle in self.boxStorage) {
            [puzzle.view removeAllActions];
            [puzzle.view runAction:[SKAction moveBy:CGVectorMake(0, -50) duration:time] completion:^{
                [puzzle.view removeFromParent];
            }];
        }
        [self.puzzles removeAllObjects];
        [self.fieldStorage removeAllObjects];
        [self.boxStorage removeAllObjects];
    }
}

-(void)closeCompleted:(float)time {
    if(self.completed) {
        self.completed = NO;
        self.canTouch = NO;
        SKAction *buttonAction = [SKAction moveToY:-50 duration:time];
        SKAction *labelAction = [SKAction moveToY:self.size.height+50 duration:time];
        self.canTouch = NO;
        [self.completedLabel runAction:labelAction completion:^{
            [self.completedLabel removeFromParent];
            self.canTouch = YES;
        }];
        [self.nextLevelButton.view runAction:buttonAction completion:^{
            [self deactivateButton:self.nextLevelButton];
        }];
        [self.menuButton.view runAction:buttonAction completion:^{
            [self deactivateButton:self.menuButton];
        }];
        [self.restartButton.view runAction:buttonAction completion:^{
            [self deactivateButton:self.restartButton];
        }];
    }
}
-(void)selectLevel:(int)level {
    float s = self.size.width;
    float t = 1.0f;
    SKSpriteNode *sprite = [self.levelPreviews objectAtIndex:level];
    for(int i=0;i<self.levels-1;i++) {
        if(i!=level) {
            SKSpriteNode *otherShit = [self.levelPreviews objectAtIndex:i];
            int direction = 1;
            if(otherShit.position.x < sprite.position.x) {
                direction=-1;
            }
            SKAction *gtfo = [SKAction moveBy:CGVectorMake(s*direction, 0) duration:t];
            [otherShit runAction:gtfo];
        }
    }
    float v = s/t;
    float time = mod(sprite.position.x - self.size.width/2) / v;
    SKAction *move = [SKAction moveToX:self.size.width/2 duration:time];
    [sprite runAction:move];
    [self runAction:[SKAction waitForDuration:t] completion:^{
        SKAction *up = [SKAction moveByX:0 y:self.size.height duration:0.5f];
        SKAction *uup = [SKAction moveToY:self.size.height/2 duration:mod(self.loading.position.x - self.size.height/2) / (self.size.height/0.5f)];
        [self addChild:self.loading];
        self.loading.position = CGPointMake(self.size.width/2,-50);
        [self.loading runAction:uup];
        [sprite runAction:up completion:^{
            [self closeMenu];
            if(self.puzzles.count) {
                [self clearPuzzles:0.5f];
                [self runAction:[SKAction waitForDuration:0.6f] completion:^{
                    [self startLevel:level];
                }];
            } else { [self startLevel:level]; }
        }];
    }];
}

-(void)openMenu {
    self.menuOpened = YES;
    int x = 0;
    int y = 0;
    int n = 0;
    float dt = 0.1f;
    for(SKSpriteNode *preview in self.levelPreviews) {
        [self runAction:[SKAction waitForDuration:dt*n] completion:^{
            preview.position = CGPointMake(MLS/2 + self.ldx+(MLS+MLB)*x, - (MLS/2 + self.ldy+(MLS+MLB)*y));
            [self addChild:preview];
            [preview runAction:[SKAction moveByX:0 y:self.size.height duration:0.3f]];
        }];
        x++;
        n++;
        if(x==self.lmx) {
            x=0;
            y++;
        }
    }
}

-(void)checkForAttachment:(Puzzle*)puzzle {
    for(Attachment*a in puzzle.attachment) {
        if(!a.attached && a.puzzle.onField) {
            CGPoint pos = CGPointMake(a.puzzle.view.position.x - puzzle.view.position.x,a.puzzle.view.position.y - puzzle.view.position.y);
            if(CGRectContainsPoint(a.hitbox, pos)) {
                for(Attachment *a2 in a.puzzle.attachment) {
                    if(a2.puzzle == puzzle) {
                        [self attach:a and:a2];
                    }
                }
            }
        }
    }
}

-(void)changePuzzlesInBox:(int)i1 :(int)i2 {
    Puzzle*p1 = [self.boxStorage objectAtIndex:i1];
    Puzzle*p2 = [self.boxStorage objectAtIndex:i2];
    [self.boxStorage replaceObjectAtIndex:i1 withObject:p2];
    [self.boxStorage replaceObjectAtIndex:i2 withObject:p1];
}

-(void)closeMenu {
    for(SKSpriteNode*preview in self.levelPreviews) {
        [preview removeFromParent];
    }
    self.menuOpened = NO;
}

-(void)clickButton:(Button*)button {
    if(self.buttonClicked == self.nextLevelButton && self.buttonClicked.tapIn) {
        if(self.buttonClicked.tapIn) {
            self.buttonClicked.tapIn = NO;
            [self.buttonClicked.viewDown removeFromParent];
            
            float time = 0.3f;
            SKAction *buttonAction = [SKAction moveToY:0 duration:time];
            [self closeCompleted:time];
            [self.nextLevelButton.view removeAllActions];
            [self.nextLevelButton.view runAction:buttonAction completion:^{
                [self showTipButton];
                [self deactivateButton:self.nextLevelButton];
                [self nextLevel];
            }];
        }
    }
    else if(self.buttonClicked == self.menuButton && self.buttonClicked.tapIn) {
        if(self.buttonClicked.tapIn) {
            self.buttonClicked.tapIn = NO;
            [self.buttonClicked.viewDown removeFromParent];
            float time = 0.3f;
            SKAction *buttonAction = [SKAction moveToY:-50 duration:time];
            [self.buttonClicked.view runAction:buttonAction completion:^{
                [self openMenu];
                [self deactivateButton:self.buttonClicked];
            }];
            
        }
    }
    else if(self.buttonClicked == self.restartButton && self.buttonClicked.tapIn) {
        if(self.buttonClicked.tapIn) {
            self.buttonClicked.tapIn = NO;
            [self.buttonClicked.viewDown removeFromParent];
            if(self.completed) {
                float time = 0.3f;
                [self closeCompleted:time];
                [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(restart) userInfo:nil repeats:NO];
            }
            else [self restart];
        }
    }
    else if(self.buttonClicked == self.tip && self.tip.tapIn) {
        if(self.tip.tapIn) {
            self.tip.tapIn = NO;
            [self hideTip];
            [self.tip.viewDown removeFromParent];
            
        }
    }
}

@end
