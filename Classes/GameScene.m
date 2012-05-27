//
//  GameScene.m
//  Manx
//
//  Created by Amanda Cordes on 11/20/11.
//  Copyright 2011 Self. All rights reserved.
//

#import "GameScene.h"
#import "Block.h"
#import "Outline.h"

#import "SimpleAudioEngine.h"


@implementation GameScene

@synthesize blockCount, numOfGridRows, numOfGridCols, offSetX, offSetY;

+(id) scene
{
	CCScene *scene = [CCScene node];
	CCLayer *layer = [GameScene node];
	[scene addChild:layer];
	return scene;
}

-(void) loadBlockColors
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	colors = [[NSArray alloc] initWithObjects:
			  @"nmy", 
			  @"red",
			  @"prp", 
			  @"grn", 
			  @"blu", nil];
}

/*
- (void) drawRect:(CGRect) rect
{
	CGPoint vertices[4]={
		ccp(rect.origin.x,rect.origin.y),
		ccp(rect.origin.x+rect.size.width,rect.origin.y),
		ccp(rect.origin.x+rect.size.width,rect.origin.y+rect.size.height),
		ccp(rect.origin.x,rect.origin.y+rect.size.height),
	};
	
	glColor4f(1.0, 1.0, 1.0, 1.0);
	glLineWidth(2.0f);
	ccDrawPoly(vertices, 4, YES);
}

-(void) draw
{
	
    for (Block *block in blocks) 
	{
		CGRect hitArea = [block calcHitArea];		
		[self drawRect:hitArea];
	}
    
    for (Outline* outline in outlines) 
	{
		CGRect hitArea = [outline calcHitArea];		
		[self drawRect:hitArea];
	}
}
*/

-(NSString*) pickBlockColor:(bool)b
{
	#define NUM_OF_BLOCK_COLORS 3
    
    //make 10% change of getting mult. block
    
    if(b)
    {
        if(((arc4random() % 100)) < 5)
        {
            return [colors objectAtIndex:0];
        }
        
        else 
        {
            return [colors objectAtIndex:((arc4random() % NUM_OF_BLOCK_COLORS) + 1)];
        }
    }
    
    return [colors objectAtIndex:((arc4random() % NUM_OF_BLOCK_COLORS) + 1)];
}

-(void)playBlockTouch
{
    [[SimpleAudioEngine sharedEngine] playEffect:@"Block_touch.caf"];
}

-(Block*)createNewBlockAtPositionX:(float)x positionY:(float)y withColor:(NSString*)c atGridPosition:(int)g withSize:(int)s
{
    return [Block blockWithParentNode:blockLayer withColor:c atPositionX:x atPositionY:y atGridPosition:g withSize:s];
}

-(BOOL)clusterStillExists:(Outline*)outline
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    BOOL cluster = YES;
    
    for(int i = 0 ; i < [[outline getBlocks] count]; i++)
    {
        if([[[outline getBlocks] objectAtIndex:i] hidden])
        {
            cluster = NO;
        }
        
        else 
        {
            int gridPos1 = [[[outline getBlocks] objectAtIndex:i] getGridPosition];
            int gridPos2 = [[[outline getBlockGridPos] objectAtIndex:i] intValue];
            
            if(gridPos1 != gridPos2)
            {
                cluster = NO;
            }
        }
    }
        
    if(!cluster)                                 
    {
        for(Block* block in [outline getBlocks])
        {
            [block setClusterStatus:NO];
        }
    }

    return cluster;
}

-(void)detectBlockClusters
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    int count = [blocks count];
    
    NSMutableArray* deadOutlines = [[NSMutableArray alloc] initWithCapacity:[outlines count]];
    
    for(Outline* outline in outlines)
    {
        if([outline getTouched] || ![self clusterStillExists:outline])
        {
            [outline remove];
            [deadOutlines addObject:outline];
        }
    }
    
    [outlines removeObjectsInArray:deadOutlines];
    
    for(int i = 0; i < count; i++)
    {
       if([[blocks objectAtIndex:i] isKindOfClass:[Block class]] && ![[blocks objectAtIndex:i] isPartOfCluster] && ![[[blocks objectAtIndex:i] getColor] isEqualToString:@"nmy"])
       {        
           // i % num of grid cols will give you COLUMN  it is in
           // i / num of grid cols will give you the ROW it is in
           
           //don't need to check last col or top row for 2x2
           int col = (i % numOfGridCols);
           int colCheck = (numOfGridCols - 1);
           int row = (i / numOfGridCols);
           int rowCheck = (numOfGridRows -1);
           
           
           if((col < colCheck) && (row < rowCheck))
           {
               Block* block = (Block*)[blocks objectAtIndex:i];
               
               NSString* color = [block getColor];
               
               NSMutableArray* blocksToCheck = [[NSMutableArray alloc] init];
               
               [blocksToCheck addObject:[blocks objectAtIndex:(i+1)]]; //check block to the right
               [blocksToCheck addObject:[blocks objectAtIndex:(i+numOfGridCols)]]; //check block to the top
               [blocksToCheck addObject:[blocks objectAtIndex:(i+numOfGridCols+1)]]; //check the block to the top right
               
               BOOL cluster = YES;
               
               for(Block* b in blocksToCheck)
               {
                   if(![color isEqualToString:[b getColor]] || [b isPartOfCluster])
                   {
                       cluster = NO;
                   }
               }
               
               if(cluster)
               {
                   double blockWidth = [(Block*)[blocks objectAtIndex:i] getWidth];
                   
                   CCLOG(@"2x2 Detected!! At %i, %i", col, row);
                   
                   [blocksToCheck addObject:block];
                   [block setClusterStatus:YES];
                   
                   float x = offSetX + (col + 1) * blockWidth;
                   float y = offSetY + (row + 1) * blockWidth;
                   Outline* outline2x2 = [Outline outlineWithParentNode:self atPositionX:x atPositionY:y withSize:2];
                   [outline2x2 setBlocks:blocksToCheck];
                   
                   for(Block* block in blocksToCheck)
                   {
                       [block setClusterStatus:YES];
                   }
                   
                   [outlines addObject:outline2x2];
               }
            
           }
       }
    }
}

-(void)addNewBlockAtPositionX:(float)x positionY:(float)y withSize:(int)s withSpike:(bool)b
{
	//CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	
    Block* myBlock = [self createNewBlockAtPositionX:x 
                                           positionY:y 
                                           withColor:[self pickBlockColor:b] 
                                      atGridPosition:[blocks count] 
                                            withSize:s];
    /*
    Block* myBlock = [self createNewBlockAtPositionX:x 
                                           positionY:y 
                                           withColor:[colors objectAtIndex:[[test objectAtIndex:[blocks count]] intValue]] 
                                      atGridPosition:[blocks count] 
                                            withSize:s];
	*/
	[blocks addObject:myBlock];
}

-(void)createAndDisplayGrid
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	touchedColor = @"none";
	blockCount = 0;
	[self removeChild:blockLayer cleanup:YES];
	blockLayer = [[CCLayer alloc] init];
	[self addChild:blockLayer z:-1];
	
	float blockWidth = [[CCSprite spriteWithSpriteFrameName:[[colors objectAtIndex:1] stringByAppendingString:@"1_tile1.png"]] boundingBox].size.width;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	offSetX = (winSize.width - blockWidth * numOfGridCols) / 2;
    offSetY = 30;
	
	float x = offSetX + blockWidth/2;
	float y = offSetY + blockWidth/2;
	
	for(int i = 0; i < numOfGridRows; i++)
	{
		x = offSetX + blockWidth/2;
		
		for(int j = 0; j < numOfGridCols; j++)
		{
			if(i == 0)
            {
                [self addNewBlockAtPositionX:x positionY:y withSize:1 withSpike:NO];
            }
            
            else 
            {
                [self addNewBlockAtPositionX:x positionY:y withSize:1 withSpike:YES];
            }
            
            
			x += blockWidth;
		}
        
		y += blockWidth;
	}
    
    //[self detectBlockClusters];
}

-(void)drawTraceLine:(NSString*)type postionX:(float)x postionY:(float)y rotation:(int)r
{
    CCSprite* line = [CCSprite spriteWithFile:[[@"trace_line_" stringByAppendingString:type] stringByAppendingString:@".png"]];
    line.rotation = r;
    line.position = ccp(x,y);
    
    [traceLine addObject:line];
    [self addChild:line z:4];
    
}

-(int)checkIfBlock:(Block*)b1 touches:(Block*)b2
{    
    double halfBlockWidth = [b1 getWidth]/2;
    
    float x = [b1 getPosition].x;
    float y = [b1 getPosition].y;
    
    if([b1 getGridPosition] + numOfGridCols - 1 == [b2 getGridPosition])
    {
        [self drawTraceLine:@"angle" postionX:(x - halfBlockWidth) postionY:(y + halfBlockWidth) rotation:(90)];
        return topLeft;
    }
    
    else if([b1 getGridPosition] + numOfGridCols == [b2 getGridPosition])
    {
        [self drawTraceLine:@"ver" postionX:x postionY:(y + halfBlockWidth) rotation:0];
        return top;
    }
    
    else if([b1 getGridPosition] + numOfGridCols + 1 == [b2 getGridPosition])
    {
        [self drawTraceLine:@"angle" postionX:(x + halfBlockWidth) postionY:(y + halfBlockWidth) rotation:0];
        return topRight;
    }
    
    else if([b1 getGridPosition] + 1 == [b2 getGridPosition])
    {
        [self drawTraceLine:@"hor" postionX:(x + halfBlockWidth) postionY:y rotation:0];
        return right;
    }
    
    else if([b1 getGridPosition] - numOfGridCols + 1 == [b2 getGridPosition])
    {
        [self drawTraceLine:@"angle" postionX:(x + halfBlockWidth) postionY:(y - halfBlockWidth) rotation:(90)];
        return bottomRight;
    
    }
    else if([b1 getGridPosition] - numOfGridCols == [b2 getGridPosition])
    {
        [self drawTraceLine:@"ver" postionX:x postionY:(y - halfBlockWidth) rotation:0];
        return bottom;
    }
    
    else if([b1 getGridPosition] - numOfGridCols - 1 == [b2 getGridPosition])
    {
        [self drawTraceLine:@"angle" postionX:(x - halfBlockWidth) postionY:(y - halfBlockWidth) rotation:(0)];
        return bottomLeft;
    }
    
    else if([b1 getGridPosition] - 1 == [b2 getGridPosition])
    {
        [self drawTraceLine:@"hor" postionX:(x - halfBlockWidth) postionY:y rotation:0];
        return left;
    }
       
    else 
    {
        return doesNotTouch;
    }
       
}

-(void)addBlockToColCount:(Block*)b
{
    int col = [b getGridPosition] % numOfGridCols;
    
    for(int i = 0; i < [b getSize]; i++)
    {
        [touchedBlockColumns replaceObjectAtIndex:(col + i) 
                                       withObject:[NSNumber numberWithInt:[[touchedBlockColumns objectAtIndex:(col + i)] intValue] + [b getSize]]];
    }
    //CCLOG(@"%@",touchedBlockColumns);
}
-(void)removeBlockFromColCount:(Block*)b
{
    int col = [b getGridPosition] % numOfGridCols;
    
    for(int i = 0; i < [b getSize]; i++)
    {
        [touchedBlockColumns replaceObjectAtIndex:(col + i) 
                                       withObject:[NSNumber numberWithInt:[[touchedBlockColumns objectAtIndex:(col + i)] intValue] - [b getSize]]];
    }
    //CCLOG(@"%@",touchedBlockColumns);
}

-(void)showScore:(CGPoint)touchLocation 
{
    if(multiplier == 0)
    {
        score = blockCount * 5;
    }
    
    else 
    {
        score = blockCount * 10 * multiplier;
    }
    
    [scoreLabel setString:[NSString stringWithFormat:@"+%.0f", score]];
    
    scoreLabel.position = ccp(touchLocation.x, touchLocation.y + 50);
    scoreLabel.visible = YES;
}

-(void)outlineTouched:(Outline*)outline
{
    CCLOG(@"%@: %@. %@", NSStringFromSelector(_cmd), self, [outline getBlocks]);
    touchedBlocks = [outline getBlocks];
    [outline hide];
    [outline setTouched:YES];
    [self getRidOfTiles];
}

- (void)selectSpriteForTouch:(CGPoint)touchLocation 
{
    //CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    //check if touching outline (only if haven't touched any blocks yet)
    BOOL outlineTouched = NO;
    
    
    if(blockCount == 0)
    {
        for(Outline* outline in outlines)
        {
            if(CGRectContainsPoint([outline calcHitArea], touchLocation))
            {
                CCLOG(@"outline touched");
                outlineTouched = YES;
                [self outlineTouched:outline];
            }
        }
    }
	
    if(!outlineTouched) 
    {
        //check if backtracking
        if(([touchedBlocks count] > 1) && CGRectContainsPoint([(Block*)[touchedBlocks objectAtIndex:[touchedBlocks count]-2] calcHitArea],touchLocation))
        {
            if([[(Block*)[touchedBlocks lastObject] getColor] isEqualToString:@"mul"])
            {
                multiplier -= 5;
                [multiplierLabel setString:[NSString stringWithFormat:@"x%i", multiplier]];
            }
            else 
            {
                blockCount--;
                if(blockCount == 0)
                {
                    touchedColor = @"none";
                }
            }
            
            [(Block*)[touchedBlocks lastObject] swapToNormalBlock];
            [self removeBlockFromColCount:(Block*)[touchedBlocks lastObject]];
            [touchedBlocks removeLastObject];
            
            [(CCSprite*)[traceLine lastObject] removeFromParentAndCleanup:YES];
            [traceLine removeLastObject];
            
            if(blockCount < 3)
            {
                scoreLabel.visible = NO;
            }
            
            return;
        }
        
        for (Block* block in blocks) 
        {
            if([block isKindOfClass:[Block class]] && ![[block getColor] isEqualToString:@"nmy"] && CGRectContainsPoint([block calcHitArea], touchLocation) && ![touchedBlocks containsObject:block])
            {
                if([[block getColor] isEqualToString:@"mul"])
                {
                    multiplier += 5;
                    [multiplierLabel setString:[NSString stringWithFormat:@"x%i", multiplier]];
                    
                }
                
                else if([touchedColor isEqualToString:@"none"])
                {
                    touchedColor = [block getColor];
                    CCLOG(@"touched: %@", block);
                }
                
                if ([touchedColor isEqualToString:[block getColor]] || [[block getColor] isEqualToString:@"mul"]) 
                {            
                    if([touchedBlocks count] > 0)
                    {
                        if([self checkIfBlock:[touchedBlocks lastObject] touches:block] != doesNotTouch)
                        {
                            if(![[block getColor] isEqualToString:@"mul"])
                            {
                                blockCount++;
                                //CCLOG(@"Block count %i", blockCount);
                            }
                            
                            [block swapToDeadBlock];
                            [self playBlockTouch];
                            [touchedBlocks addObject:block];
                            [self addBlockToColCount:block];
                            
                        }
                        else 
                        {
                            //CCLOG(@"Sprites Do Not Touch");
                            break;
                        }
                    }
                    
                    else 
                    {
                        if(![[block getColor] isEqualToString:@"mul"])
                        {
                            blockCount++;
                            CCLOG(@"Block count %i", blockCount);
                        }
                        
                        [block swapToDeadBlock];
                        [self playBlockTouch];
                        [touchedBlocks addObject:block];
                        [self addBlockToColCount:block];
                    }
                    
                    break;
                }
            }
        }
        
    }
	
}

-(void)makeBlocksFall
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    int blockWidth = [[CCSprite spriteWithSpriteFrameName:[[colors objectAtIndex:1] stringByAppendingString:@"1_tile1.png"]] boundingBox].size.width;
    
    // create array size of # of columns and full of 0s
    NSMutableArray* fallCountByColumn = [[NSMutableArray alloc] initWithCapacity:numOfGridCols];
    NSMutableArray* fallCountByColumnTotal = [[NSMutableArray alloc] initWithCapacity:numOfGridCols];

    [fallCountByColumnTotal removeAllObjects];
    //[holes removeAllObjects];
    
    for(int i = 0; i < numOfGridCols; i++)
    {
        [fallCountByColumnTotal addObject:[NSNumber numberWithInt:0]];
        //[holes addObject:[NSNumber numberWithInt:0]];

    }
    
    NSMutableArray*  movedBlocks = [[NSMutableArray alloc] init];
    
    //NSMutableArray* actions = [[NSMutableArray alloc] init];
    
    //iterate through each row
    for(int row = 0; row < numOfGridRows; row++)
    {
        
        //reset so all values are 0
        [fallCountByColumn removeAllObjects];
        //[fallCountByColumnWithHoles removeAllObjects];
        for(int i = 0; i < numOfGridCols; i++)
        {
            [fallCountByColumn addObject:[NSNumber numberWithInt:0]];
            //[fallCountByColumnWithHoles addObject:[NSNumber numberWithInt:0]];
        }
        
        //count per column the number of blocks (size of removed block) above blocks could potentially fall
        for(Block* removedBlock in touchedBlocks)
        {
            if(([removedBlock getGridPosition] / numOfGridCols) == row)
            {
                for(int i = 0; i < [removedBlock getSize]; i++)
                {
                    int currentValue = [[fallCountByColumn objectAtIndex:(([removedBlock getGridPosition] % numOfGridCols) + i)] intValue];
                    
                    [fallCountByColumn replaceObjectAtIndex:(([removedBlock getGridPosition] % numOfGridCols) + i) withObject:[NSNumber numberWithInt:(currentValue + [removedBlock getSize])]];
                }
            }
        }
        
        //iterate through all blocks above the current row
        for(int b = ((row + 1) * numOfGridCols); b < [blocks count]; b++)
        {
            Block* block = [blocks objectAtIndex:b];
            
            if([block isKindOfClass:[Block class]] && ![touchedBlocks containsObject:block])
            {
                int col = ([block getGridPosition] % numOfGridCols);
                
                int fallAmount = [[fallCountByColumn objectAtIndex:col] intValue];
                
                //make the block and corresponding "empty" blocks fall if it needs to
                if(fallAmount != 0)
                {
                    NSMutableArray* falling = [[NSMutableArray alloc] init];
                    
                    [falling addObject:block];
                    
                    for(Block* fallingBlock in falling)
                    {
                        for(int i = 0; i < fallAmount; i++)
                        {
                            //block will move 1 block width at a time so speed is consistant
                            [fallingBlock addAction:[CCMoveBy actionWithDuration:.09 
                                                                 position:ccp(0,-1 * blockWidth)]];
                            
                            //update grid postion
                            [fallingBlock setGridPosition:([fallingBlock getGridPosition] - numOfGridCols)];
                        }
                        if(![movedBlocks containsObject:fallingBlock])
                        {
                            [movedBlocks addObject:fallingBlock];
                        }
                    }
                }
            }
        }
        
        for(int q = 0; q < [fallCountByColumn count]; q++)
        {
            [fallCountByColumnTotal replaceObjectAtIndex:q 
                                              withObject:[NSNumber numberWithInt:([[fallCountByColumnTotal objectAtIndex:q] intValue] + [[fallCountByColumn objectAtIndex:q] intValue])]];
        }
    }
    
    //for each value in fallCountByColumnTotal add blocks and have them fall
    for(int i = 0; i < [fallCountByColumnTotal count]; i++)
    {
        for(int j = 0; j < [[fallCountByColumnTotal objectAtIndex:i] intValue]; j++)
        {
            //calculate needed values, gp is the block's final position
            float x = offSetX + (i * blockWidth) + blockWidth/2;
            float y = offSetY + (numOfGridRows + j) * blockWidth + blockWidth/2;
            int gp = (((numOfGridRows + j) * numOfGridCols) + i) - (numOfGridCols * [[fallCountByColumnTotal objectAtIndex:i] intValue]);
            
            
            //add to appropriate grid position
            [movedBlocks addObject:[self createNewBlockAtPositionX:x 
                                                         positionY:y 
                                                         withColor:[self pickBlockColor:YES]
                                                    atGridPosition:gp 
                                                          withSize:1]];
            
            //add the fall animation, no need to update grid postion in blocks becuase it is already set 
            for(int f = 0; f < [[fallCountByColumnTotal objectAtIndex:i] intValue]; f++)
            {
                //block will move 1 block width at a time so speed is consistant
                [(Block*)[movedBlocks lastObject] addAction:[CCMoveBy actionWithDuration:.09 
                                                                                position:ccp(0,-1 * blockWidth)]];
                
            }
        }
    }
    
    //run all fall animations
    for(Block* block in movedBlocks)
    {
        [blocks replaceObjectAtIndex:[block getGridPosition] withObject:block];
        [block runActions];
    }

    [movedBlocks removeAllObjects];
    
    [self touchEndedCleanUp];
}


- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event 
{    
    CCLOG(@"Touch Began");
	
	touchedColor = @"none";
	blockCount = 0;
    
	CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
	CCLOG(@"touch location x:%f y:%f", touchLocation.x, touchLocation.y);
    [self selectSpriteForTouch:touchLocation];      
    return TRUE;    
}
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    [self selectSpriteForTouch:touchLocation]; 
    if(blockCount >= 3)
    {
        [self showScore:touchLocation];
    }
}

-(CCFiniteTimeAction*) getActionSequence: (NSArray *) actions
{
	CCFiniteTimeAction *seq = nil;
	for (CCFiniteTimeAction *anAction in actions)
	{
		if (!seq)
		{
			seq = anAction;
		}
		else
		{
			seq = [CCSequence actionOne:seq two:anAction];
		}
	}
	return seq;
}

-(void)removeSpikeTilesAtBottom
{
    BOOL spikes = YES;
    
    while(spikes)
    {
        for(int i = 0; i < numOfGridCols; i++)
        {
            if([[(Block*)[blocks objectAtIndex:i] getColor] isEqualToString:@"nmy"])
            {
                [[blocks objectAtIndex:i] hide];
                [touchedBlocks addObject:[blocks objectAtIndex:i]];
            }
            
            else 
            {
                spikes = NO;
            }
        }
        
        if([touchedBlocks count] > 0)
        {
            [self getRidOfTiles];
        }

    }
}


-(void)hideBlock:(id)sender data:(Block*)b
{
    [b hide];
}

-(void)touchEndedCleanUp
{
    //[self detectBlockClusters];
    
    [touchedBlocks removeAllObjects];
    
    [touchedBlockColumns removeAllObjects];
    for(int j = 0; j < numOfGridCols; j++)
    {
        [touchedBlockColumns addObject:[NSNumber numberWithInt:0]];
    }
	
    touchedColor = @"none";
	blockCount = 0;
    score = 0;
    multiplier = 0;
    
    [multiplierLabel setString:@"x"];

    
    CCLOG(@"Number of blocks:%i", [blocks count]);
}

-(void)getRidOfTiles
{
    NSMutableArray* hideActions = [[NSMutableArray alloc] init];
    
    for (Block* block in touchedBlocks) 
    {
        //[block hide];
        [hideActions addObject:[CCCallFuncND actionWithTarget:self selector:@selector(hideBlock:data:) data:(Block*)block]];
        //[hideActions addObject:[CCDelayTime actionWithDuration:.05]];
    }
    [hideActions addObject:[CCCallFuncN actionWithTarget:self selector:@selector(makeBlocksFall)]];
    [hideActions addObject:[CCDelayTime actionWithDuration:.7]];
    [hideActions addObject:[CCCallFuncN actionWithTarget:self selector:@selector(removeSpikeTilesAtBottom)]];
    
    [self runAction: [CCSequence actions:[self getActionSequence: hideActions],nil]];

}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{	
    scoreLabel.visible = NO;
    
    if([traceLine count] > 0)
    {
        for(CCSprite* line in traceLine)
        {
            [line removeFromParentAndCleanup:YES];
        }
        
        [traceLine removeAllObjects];
    }
	
	if(blockCount >= 3)
	{
        totalScore = totalScore + score;
        [totalScoreLabel setString:[NSString stringWithFormat:@"%i", totalScore]];
        [self heroAttack];
        [self getRidOfTiles];
        
    }
	
	else 
	{
        for (Block* block in touchedBlocks) 
		{
			[block swapToNormalBlock];
		}
        
        [self touchEndedCleanUp];
	}
}

-(void)heroAttack
{
    myEnergy += score;
    
    float energyMovement = score / energyTotal * barWidth;
    
    energyBar.position = ccp(energyBar.position.x + energyMovement, energyBar.position.y);
    
    if(myEnergy >= energyTotal)
    {
        [self gameEnded:YES];
    }
    
}

-(void)loadTestArray
{
    test = [[NSArray alloc] initWithObjects:
            [NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:2],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:2],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:0],[NSNumber numberWithInt:1],[NSNumber numberWithInt:1],[NSNumber numberWithInt:2],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:0],[NSNumber numberWithInt:1],[NSNumber numberWithInt:3],[NSNumber numberWithInt:1],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:0],[NSNumber numberWithInt:2],[NSNumber numberWithInt:2],[NSNumber numberWithInt:2],[NSNumber numberWithInt:2],[NSNumber numberWithInt:2],[NSNumber numberWithInt:2],[NSNumber numberWithInt:0],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3], nil];
}

-(void)gameEnded:(BOOL)win
{
    [self unscheduleAllSelectors];
    
    NSString* s;
    
    if(win)
    {
        s = @"won";
    }
    
    else 
    {
        s = @"lost";
    }
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    NSString* image = [[@"you" stringByAppendingString:s] stringByAppendingString:@".png"];
    
    CCMenuItem* restart = [CCMenuItemImage itemFromNormalImage:image selectedImage:image target:self selector:@selector(restart:)];
    
    restart.position = ccp(winSize.width/2, winSize.height/2);
    
    CCMenu* menu = [CCMenu menuWithItems:restart, nil];
    menu.position = CGPointZero;
    [self addChild:menu z:10 tag:1];
}

-(void)scheduleUpdateMethod 
{
    [self schedule:@selector(bossAttack:) interval:bossAttackFreq]; 
}

-(void)bossHit:(float)attack
{
    myEnergy -= attack;
    
    float energyMovement = attack / energyTotal * barWidth;
    
    energyBar.position = ccp(energyBar.position.x - energyMovement, energyBar.position.y);
}

-(void)bossAttack:(ccTime)delta 
{
    if(attackCount == bossSuperAttackFreq)
    {
        [self bossHit:bossSuperAttack];
        attackCount = 0;
    }
    
    else 
    {
        [self bossHit:bossAttack];
         attackCount++;
    }
    
    if(myEnergy < 0)
    {
        [self gameEnded:NO];
    }
}

-(void)initBossAttack
{
    barWidth = 145;
    
    
    bossAttack = 10;
    bossAttackFreq = 3;
    bossSuperAttack = 20;
    bossSuperAttackFreq = 3;
    attackCount = 0;
}

-(void)initEnergyBar
{
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache]; 
    
    [frameCache addSpriteFramesWithFile:@"UI_Forest.plist"];

    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    energyTotal = 1000;
    myEnergy = 500;
    
    
    CCSprite* energyBarBG;
    energyBarBG = [CCSprite spriteWithSpriteFrameName:@"playscreen_bar_greyBG.png"];
    energyBarBG.position = ccp(winSize.width/2, winSize.height - (energyBarBG.contentSize.height / 2));
    [self addChild:energyBarBG z:1];
    
    CCSprite* topBar;
    topBar = [CCSprite spriteWithSpriteFrameName:@"playscreen_topbarBG_forest.png"];
    topBar.position = ccp(winSize.width/2, winSize.height - (energyBarBG.contentSize.height / 2));
    [self addChild:topBar z:3];
    
    CCSprite* bottomBar;
    bottomBar = [CCSprite spriteWithSpriteFrameName:@"playscreen_btm_forest.png"];
    bottomBar.position = ccp(winSize.width/2, (bottomBar.contentSize.height / 2));
    [self addChild:bottomBar z:-3];
    
    energyBar = [CCSprite spriteWithSpriteFrameName:@"playscreen_bar_HP.png"];
    energyBar.position = ccp(winSize.width/2 - energyBar.contentSize.width/2, winSize.height - (energyBar.contentSize.height / 2));
    [self addChild: energyBar z:2];
    
    pauseButton = [CCSprite spriteWithSpriteFrameName:@"pause_button.png"];
    pauseButton.position = ccp(winSize.width - pauseButton.contentSize.width/2, 
                               winSize.height - pauseButton.contentSize.height/2);
    
    
    /*
     energyBar = [CCSprite spriteWithFile:@"fight_bar_energy.png"];
     energyBar.position = ccp(fightBarBg.position.x, fightBarBg.position.y - energyBar.contentSize.height/2 + 5);
     [self addChild:energyBar z:1];
     
     energyBarMovement = 0;
     
     CCSprite* multiIndicator = [CCSprite spriteWithFile:@"multi_indicator.png"];
     multiIndicator.position = fightBarBg.position;
     [self addChild:multiIndicator z:3];
     
     multiplierLabel = [CCLabelBMFont labelWithString:@"x" fntFile:@"smallNumbers.fnt"];
     multiplierLabel.position = ccp(multiIndicator.position.x, multiIndicator.position.y - multiplierLabel.contentSize.height/4);
     [self addChild:multiplierLabel z:4];
     
    
    totalScoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"Score.fnt"];
    totalScoreLabel.position = ccp(winSize.width/2, energyBarBG.position.y + totalScoreLabel.contentSize.height/2);
    [self addChild:totalScoreLabel z:3];
     */
}

-(id)init
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	if((self = [super init]))
	{		
		numOfGridRows = 8;
		numOfGridCols = 7;
        
		//init layers
		blockLayer = [[CCLayer alloc] init];
		
		[self addChild:blockLayer z:-1];
		
        
		[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"playscreen_bg_forest.png"];
        background.anchorPoint = ccp(0,0);
        [self addChild:background z:-10];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
		CCLOG(@"background loaded");
        
        [self initBossAttack];
        [self initEnergyBar];
        
        /*
        CCLayerColor* colorLayer = [CCLayerColor layerWithColor:ccc4(255, 255, 255, 255)];
        [self addChild:colorLayer z:-100];
         */
        
		[self loadTestArray];
		
        [self loadBlockColors];
		touchedColor = @"none";
		blockCount = 0;
		totalScore = 0;
        score = 0;
        multiplier = 0;
        
        scoreLabel = [CCLabelBMFont labelWithString:@"0" fntFile:@"TraceScore.fnt"];
        scoreLabel.visible = NO;
        [self  addChild:scoreLabel z:10];
		
		blocks = [[NSMutableArray alloc] initWithCapacity:(numOfGridCols*numOfGridRows)];
		touchedBlocks = [[NSMutableArray alloc] init];
        touchedBlockColumns = [[NSMutableArray alloc] init];
        
        traceLine = [[NSMutableArray alloc] init];
        outlines = [[NSMutableArray alloc] init];
        
        for(int j = 0; j < numOfGridCols; j++)
        {
            [touchedBlockColumns addObject:[NSNumber numberWithInt:0]];
        }
		
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"Block_touch.caf"];
        
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
		
        CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache]; 
        [frameCache addSpriteFramesWithFile:@"Tiles.plist"];
		[self createAndDisplayGrid];
        [self scheduleUpdateMethod];
	}
	return self;
}

- (void)restart:(id)sender 
{
	totalScore = 0;
    myEnergy = 500;
    [totalScoreLabel setString:[NSString stringWithFormat:@"%i", totalScore]];

    for (Block* block in blocks) 
	{
		if([block isKindOfClass:[Block class]] && !([[block getColor] isEqualToString:@"empty"]))
            [block remove];
	}
	
    for(Outline* outline in outlines)
    {
        [outline remove];
    }
    
	[blocks removeAllObjects];
    [outlines removeAllObjects];
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    
    energyBar.position = ccp(winSize.width/2 - energyBar.contentSize.width/2, winSize.height - (energyBar.contentSize.height / 2));

    [self removeChildByTag:1 cleanup:YES];
	
	[self createAndDisplayGrid];
    [self scheduleUpdateMethod];
}


-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	[blocks release];
	[colors release];
	[touchedBlocks release];
    
    [scoreLabel release];
    [totalScoreLabel release];
	
	[super dealloc];
}
@end
