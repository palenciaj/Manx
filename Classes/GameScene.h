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
    
    int score;
    
    CCLabelBMFont* scoreLabel;
    
    NSArray* test;
}

@property int numOfGridRows;
@property int numOfGridCols;
@property int blockCount;
@property float offSet;

+(id) scene;

@end
