//
//  GameScene.h
//  Manx
//
//  Created by Amanda Cordes on 11/20/11.
//  Copyright 2011 Self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface GameScene : CCNode <CCTargetedTouchDelegate>
{
	CCLayer* blockLayer;
	//CCLayer *controlsLayer;
	
	NSString *touchedColor;
	
	NSArray* colors;
	NSMutableArray* blocks;
	NSMutableArray* touchedBlocks;
    NSMutableArray* touchedBlockColumns;
    
    NSMutableArray* traceLine;
    NSMutableArray* outlines;
    
    int totalScore;
    int score;
    int multiplier;
    
    CCSprite* fightBarBg;
    CCSprite* energyBar;
    float energyBarMovement;
    
    BOOL touchHappening;
    
    CCLabelBMFont* totalScoreLabel;
    CCLabelBMFont* multiplierLabel;
    CCLabelBMFont* scoreLabel;
    
    NSArray* test;
    
    enum blockPosition
    {
        doesNotTouch = 0,
        topLeft = 1, 
        top = 2, 
        topRight = 3, 
        right = 4, 
        bottomRight = 5, 
        bottom = 6, 
        bottomLeft = 7, 
        left = 8
    };
}

@property int numOfGridRows;
@property int numOfGridCols;
@property int blockCount;
@property float offSet;

+(id) scene;

@end
