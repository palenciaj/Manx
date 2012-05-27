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
    float score;
    int multiplier;
    
    int energyTotal;
    int myEnergy;
    
    int barWidth; //size of window should be calculated off png
    
    float bossAttack;
    float bossAttackFreq;
    float bossSuperAttack;
    float bossSuperAttackFreq;
    float attackCount;
    
    CCSprite* pauseButton;
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
@property float offSetX,offSetY;

+(id) scene;

@end
