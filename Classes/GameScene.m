//
//  GameScene.m
//  Manx
//
//  Created by Amanda Cordes on 11/20/11.
//  Copyright 2011 Self. All rights reserved.
//

#import "GameScene.h"
#import "Block.h"


@implementation GameScene

@synthesize blockCount, numOfGridRows, numOfGridCols, offSet;

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
			  @"empty", 
			  @"blu",
			  @"red", 
			  @"grn", 
			  @"prp",
			  @"ylw", nil];
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
}
*/

-(NSString*) pickBlockColor
{
	#define NUM_OF_BLOCK_COLORS 5
	
	return [colors objectAtIndex:((arc4random() % NUM_OF_BLOCK_COLORS) + 1)];
}

-(Block*)createSpacerBlock:(Block*)block atGridPosition:(int)gp
{
    return [Block blockWithParentNode:blockLayer withColor:@"space" atPositionX:[block getPosition].x atPositionY:[block getPosition].y atGridPosition:gp withSize:1];
}

-(Block*)createNewBlockAtPositionX:(float)x positionY:(float)y withColor:(NSString*)c atGridPosition:(int)g withSize:(int)s
{
    return [Block blockWithParentNode:blockLayer withColor:c atPositionX:x atPositionY:y atGridPosition:g withSize:s];
}

-(void)removeBlockAndSetPostionToNull:(int)p
{
    [(Block*)[blocks objectAtIndex:p] remove];
    [blocks replaceObjectAtIndex:p withObject:[NSNull null]];
    
}

-(void)detectBlockFusion
{
    int count = [blocks count];
    
    for(int i = 0; i < count; i++)
    {
       if([[blocks objectAtIndex:i] isKindOfClass:[Block class]])
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
               NSString* color = [(Block*)[blocks objectAtIndex:i] getColor];
               
               //check block to the right
               if([[blocks objectAtIndex:(i+1)] isKindOfClass:[Block class]] && color == [(Block*)[blocks objectAtIndex:(i+1)] getColor])
               {
                   //check block to the top
                   if([[blocks objectAtIndex:(i+numOfGridCols)] isKindOfClass:[Block class]]  && color == [(Block*)[blocks objectAtIndex:(i+numOfGridCols)] getColor])
                   {
                       //check the block to the top right
                       if([[blocks objectAtIndex:(i+numOfGridCols+1)] isKindOfClass:[Block class]] && color == [(Block*)[blocks objectAtIndex:(i+numOfGridCols+1)] getColor])
                       {
                           CCLOG(@"2x2 Detected!! At %i, %i", col, row);
                           
                           Block* newBlock = [self createNewBlockAtPositionX:[(Block*)[blocks objectAtIndex:i] getPosition].x 
                                                                   positionY:[(Block*)[blocks objectAtIndex:i] getPosition].y 
                                                                   withColor:color 
                                                              atGridPosition:i
                                                                    withSize:2];
                           
                           [(Block*)[blocks objectAtIndex:i] remove];
                           [blocks replaceObjectAtIndex:i withObject:newBlock];
                           
                           //remove all other smaller blocks and set them to NULL in the blocks array so the order holds
                           /*
                           [self removeBlockAndSetPostionToNull:(i+1)];
                           [self removeBlockAndSetPostionToNull:(i+numOfGridCols)];
                           [self removeBlockAndSetPostionToNull:(i+numOfGridCols+1)];
                            */
                           [(Block*)[blocks objectAtIndex:(i+1)] swapToEmptyBlock];
                           [(Block*)[blocks objectAtIndex:(i+numOfGridCols)] swapToEmptyBlock];
                           [(Block*)[blocks objectAtIndex:(i+numOfGridCols+1)] swapToEmptyBlock];
                           
                       }
                   }
               }
           }
       }
    }
}

-(void)addNewBlockAtPositionX:(float)x positionY:(float)y withSize:(int)s
{
	//CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	/*
    Block* myBlock = [self createNewBlockAtPositionX:x 
                                           positionY:y 
                                           withColor:[self pickBlockColor] 
                                      atGridPosition:[blocks count] 
                                            withSize:s];
    */
    Block* myBlock = [self createNewBlockAtPositionX:x 
                                           positionY:y 
                                           withColor:[colors objectAtIndex:[[test objectAtIndex:[blocks count]] intValue]] 
                                      atGridPosition:[blocks count] 
                                            withSize:s];
	
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
	
	int blockWidth = [[CCSprite spriteWithFile:[[colors objectAtIndex:1] stringByAppendingString:@"1_block0.png"]] boundingBox].size.width;
    
    CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	offSet = (winSize.width - blockWidth * numOfGridCols) / 2;
	
	float x = offSet;
	float y = 0;
	
	for(int i = 0; i < numOfGridRows; i++)
	{
		x = offSet;
        //NSMutableArray* array = [[NSMutableArray alloc] init];
		
		for(int j = 0; j < numOfGridCols; j++)
		{
            //[array addObject:[self addNewBlockAtPositionX:x positionY:y withSize:1]];
			[self addNewBlockAtPositionX:x positionY:y withSize:1];
            
			x += blockWidth;
		}
        //[blocks addObject:array];
		y += blockWidth;
	}
    
    [self detectBlockFusion];
}

- (BOOL)checkIfSprite:(CCSprite*)s1 touches:(CCSprite*)s2
{
	//CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	if(s1.position.x == s2.position.x)
	{
		return((s1.position.y + s1.contentSize.height == s2.position.y) ||
			   (s1.position.y - s2.contentSize.height == s2.position.y));
	}
	else if(s1.position.x + s1.contentSize.width == s2.position.x)
	{
		return((s1.position.y + s1.contentSize.height == s2.position.y) ||
			   (s1.position.y - s2.contentSize.height == s2.position.y) ||
			   (s1.position.y == s2.position.y));
	}
	else if(s1.position.x - s2.contentSize.width == s2.position.x)
	{
		return((s1.position.y + s1.contentSize.height == s2.position.y) ||
			   (s1.position.y - s2.contentSize.height == s2.position.y) ||
			   (s1.position.y == s2.position.y));
	}
    
	return NO;
}

-(BOOL)checkIfBlock:(Block*)b1 touches:(Block*)b2
{    

    for(int i = 1; i<= [b2 getSize]; i++)
    {
        //top left
        if([b1 getGridPosition] + ([b1 getSize] * numOfGridCols) - i == [b2 getGridPosition])
            return YES;
        
        //bottom right
        if([b1 getGridPosition] - (numOfGridCols * i) + [b1 getSize] == [b2 getGridPosition])
            return YES;
        
        //bottom left
        for(int j = 1; j <= [b2 getSize]; j++)
        {
            if([b1 getGridPosition] - (numOfGridCols * i) - j == [b2 getGridPosition])
                return YES;
        }
        
    }
    
    for(int i = 0; i <= [b1 getSize]; i++)
    {
        //right side (not corners)
        if([b1 getGridPosition] + (numOfGridCols * i) + [b1 getSize] == [b2 getGridPosition])
            return YES;
        
        //top (not left corner)
        if([b1 getGridPosition] + (numOfGridCols * [b1 getSize]) + i == [b2 getGridPosition])
            return YES;
        
        //left side (not corners)
        if([b1 getGridPosition] + (numOfGridCols * i) - [b2 getSize] == [b2 getGridPosition])
            return YES;
        
        //bottom (not corners)
        if([b1 getGridPosition] - ([b2 getSize] * numOfGridCols) + i == [b2 getGridPosition])
            return YES;
    }
    
    return NO;
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

- (void)selectSpriteForTouch:(CGPoint)touchLocation 
{
    //CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	//check if backtracking
	if(([touchedBlocks count] > 1) && 
	   CGRectContainsPoint([(Block*)[touchedBlocks objectAtIndex:[touchedBlocks count]-2] calcHitArea],touchLocation))
	{
        [(Block*)[touchedBlocks lastObject] swapToNormalBlock];
        [self removeBlockFromColCount:(Block*)[touchedBlocks lastObject]];
        [touchedBlocks removeLastObject];
		blockCount--;
		
		return;
	}
	
	for (Block* block in blocks) 
	{
		if([block isKindOfClass:[Block class]] && ![touchedBlocks containsObject:block] && !([[block getColor] isEqualToString:@"empty"]) )
        {
            if([touchedColor isEqualToString:@"none"] && CGRectContainsPoint([block calcHitArea], touchLocation))
            {
                touchedColor = [block getColor];
                CCLOG(@"touched: %@", block);
            }
            
            if ([touchedColor isEqualToString:[block getColor]] && CGRectContainsPoint([block calcHitArea], touchLocation)) 
            {            
                if([touchedBlocks count] > 0)
                {
                    //CCLOG(@"Next Sprite");
                    
                    //if([self checkIfSprite:[(Block*)[touchedBlocks lastObject] getSprite] touches:[block getSprite]])
                    if([self checkIfBlock:[touchedBlocks lastObject] touches:block])
                    {
                        //CCLOG(@"Sprites Touch");
                        [block swapToDeadBlock];
                        [touchedBlocks addObject:block];
                        [self addBlockToColCount:block];
                        blockCount++;
                    }
                    else 
                    {
                        //CCLOG(@"Sprites Do Not Touch");
                        break;
                    }
                }
                
                else 
                {
                    //CCLOG(@"First Sprite");
                    [block swapToDeadBlock];
                    [touchedBlocks addObject:block];
                    [self addBlockToColCount:block];
                    blockCount++;
                }
                
                break;
            }
        }
    }
}

-(void)makeBlocksFall
{
    int blockWidth = [[CCSprite spriteWithFile:[[colors objectAtIndex:1] stringByAppendingString:@"1_block0.png"]] boundingBox].size.width;
    
    // create array size of # of columns and full of 0s
    NSMutableArray* fallCountByColumn = [[NSMutableArray alloc] initWithCapacity:numOfGridCols];
    NSMutableArray* fallCountByColumnTotal = [[NSMutableArray alloc] initWithCapacity:numOfGridCols];
    NSMutableArray* holes = [[NSMutableArray alloc] initWithCapacity:numOfGridCols];
    NSMutableArray* fallCountByColumnWithHoles = [[NSMutableArray alloc] initWithCapacity:numOfGridCols];
    
    NSMutableArray* spaces = [[NSMutableArray alloc] init];

    [fallCountByColumnTotal removeAllObjects];
    [holes removeAllObjects];
    
    for(int i = 0; i < numOfGridCols; i++)
    {
        [fallCountByColumnTotal addObject:[NSNumber numberWithInt:0]];
        [holes addObject:[NSNumber numberWithInt:0]];

    }
    
    NSMutableArray*  movedBlocks = [[NSMutableArray alloc] init];
    
    //NSMutableArray* actions = [[NSMutableArray alloc] init];
    
    //iterate through each row
    for(int row = 0; row < numOfGridRows; row++)
    {
        
        //reset so all values are 0
        [fallCountByColumn removeAllObjects];
        [fallCountByColumnWithHoles removeAllObjects];
        for(int i = 0; i < numOfGridCols; i++)
        {
            [fallCountByColumn addObject:[NSNumber numberWithInt:0]];
            [fallCountByColumnWithHoles addObject:[NSNumber numberWithInt:0]];
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
        
        //add in any empty spaces that exist
        for(int i = (row * numOfGridCols); i < ((row + 1) * numOfGridCols); i++)
        {
            Block* block = [blocks objectAtIndex:i];
            
            if([[block getColor] isEqualToString:@"space"])
            {
                int currentValue = [[fallCountByColumn objectAtIndex:([block getGridPosition] % numOfGridCols)] intValue];
                
                [fallCountByColumn replaceObjectAtIndex:([block getGridPosition] % numOfGridCols) withObject:[NSNumber numberWithInt:(currentValue + [block getSize])]];
            }
        } 
        
        //add existing holes to fallCount and reset holes
        for(int i = 0; i < [fallCountByColumn count]; i++)
        {
            [fallCountByColumnWithHoles replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:[[fallCountByColumn objectAtIndex:i] intValue] + [[holes objectAtIndex:i] intValue]]];
            
            [holes replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:0]];
        }
        
        //iterate through all blocks above the current row
        for(int b = ((row + 1) * numOfGridCols); b < [blocks count]; b++)
        {
            Block* block = [blocks objectAtIndex:b];
            
            //if([block isKindOfClass:[Block class]]  && !([[block getColor] isEqualToString:@"empty"]) && ![touchedBlocks containsObject:block])
            if([block isKindOfClass:[Block class]] && !([[block getColor] isEqualToString:@"empty"]) && !([[block getColor] isEqualToString:@"space"]) && ![touchedBlocks containsObject:block])
            {
                int col = ([block getGridPosition] % numOfGridCols);
                
                int fallAmount = [[fallCountByColumn objectAtIndex:col] intValue];
                
                //if block is bigger than 1x1 need to see how far it is possible for it to fall and adjust array for all blocks above the larger block
                if([block getSize] > 1)
                {
                    //for blocks bigger than 1x1 need to consider hole that have been made
                    fallAmount = [[fallCountByColumnWithHoles objectAtIndex:col] intValue];
                    
                    
                    //for each colum the block spans see what the smallest value in fallCountByColumnWithHoles is
                    if(fallAmount != 0) // don't need to check if already at smallest possiblie (0)
                    {
                        for(int i = 1; i < [block getSize]; i++)
                        {
                            if([[fallCountByColumnWithHoles objectAtIndex:(col + i)] intValue] < fallAmount)
                            {
                                fallAmount = [[fallCountByColumnWithHoles objectAtIndex:(col + i)] intValue];
                            }
                        }
                    }
                    
                    //once smallest amount is found keep track of where "holes" are created and change all values for columns that the block spans to the smallest value
                    
                    for(int i = 0; i < [block getSize]; i++)
                    {
                        int holeSpace = [[fallCountByColumnWithHoles objectAtIndex:(col+i)] intValue] - fallAmount + [[holes objectAtIndex:(col+i)] intValue];
                        
                        //these are holes that still have the potential to be filled
                        if(([block getGridPosition]/numOfGridCols) > (row+1))
                        {
                             [holes replaceObjectAtIndex:(col+i) withObject:[NSNumber numberWithInt:holeSpace]];
                        }
                        
                        //this would be a permanent hole after this drop
                        else 
                        {
                            if(holeSpace > 0)
                            {
                                int gridPostion = [block getGridPosition] + i - numOfGridCols;
                                
                                [spaces addObject:[NSNumber numberWithInt:gridPostion]];
                            }
                        }
                        
                       
                        [fallCountByColumnWithHoles replaceObjectAtIndex:(col+i) withObject:[NSNumber numberWithInt:fallAmount]];
                        [fallCountByColumn replaceObjectAtIndex:(col+i) withObject:[NSNumber numberWithInt:fallAmount]];

                    }
                }
                
                //make the block and corresponding "empty" blocks fall if it needs to
                if(fallAmount != 0)
                {
                    NSMutableArray* falling = [[NSMutableArray alloc] init];
                    
                    [falling addObject:block];
                    
                    // if 2x2 or bigger make all "empty" surrounding blocks fall with
                    for(int i = 1; i < [block getSize]; i++)
                    {
                        [falling addObject:[blocks objectAtIndex:[block getGridPosition] + i]];
                        [falling addObject:[blocks objectAtIndex:[block getGridPosition] + (numOfGridCols * i)]];
                        [falling addObject:[blocks objectAtIndex:[block getGridPosition]+ (numOfGridCols * i) + i]];
                    }
                    
                    CCLOG(@"Row: %i, Falling: %@", row, falling);
                    
                    for(Block* fallingBlock in falling)
                    {
                        for(int i = 0; i < fallAmount; i++)
                        {
                            //block will move 1 block width at a time so speed is consistant
                            [fallingBlock addAction:[CCMoveBy actionWithDuration:.09 
                                                                 position:ccp(0,-1 * blockWidth)]];
                            
                            CCLOG(@"Added action to %@", block);
                            
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
            float x = offSet + (i * blockWidth);
            float y = (numOfGridRows + j) * blockWidth;
            int gp = (((numOfGridRows + j) * numOfGridCols) + i) - (numOfGridCols * [[fallCountByColumnTotal objectAtIndex:i] intValue]);
            
            
            //add to appropriate grid position
            [movedBlocks addObject:[self createNewBlockAtPositionX:x 
                                                         positionY:y 
                                                         withColor:[self pickBlockColor]
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
    
    id callFunc = [CCCallFunc actionWithTarget:self selector:@selector(detectBlockFusion)];

    //run all fall animations
    /*
    for(Block* block in movedBlocks)
    {
        [blocks replaceObjectAtIndex:[block getGridPosition] withObject:block];
        [block addAction:callFunc];
        [block runActions];
    }
    */
    for(int i = 0; i < [movedBlocks count]; i++)
    {
        Block* block = [movedBlocks objectAtIndex:i];
        
        [blocks replaceObjectAtIndex:[block getGridPosition] withObject:block];
        
        if(i == [movedBlocks count] - 1)
        [block addAction:callFunc];
        
        [block runActions];
    }
    
    for(NSNumber* n in spaces)
    {
        int i = [n intValue];
        
        //check this becuase in some cases "empty" blocks can get added incorrectly
        if([(Block*)[blocks objectAtIndex:i] getGridPosition] != i)
        {
            [blocks replaceObjectAtIndex:i withObject:[self createSpacerBlock:[blocks objectAtIndex:i] atGridPosition:i]];
        }
    }
    
    [spaces removeAllObjects];
    [movedBlocks removeAllObjects];
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
}
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{	
	if(blockCount == 0)
	{
		CCLOG(@"blockCount is 0!!");
		
		return;
	}
	
	if(blockCount >= 3)
	{
        for (Block* block in touchedBlocks) 
		{
            [block hide];			
		}
		[self makeBlocksFall];
        
        for (Block* block in touchedBlocks) 
		{
			[block swapToSpacerBlock];			
		}
	}
	
	else 
	{
        for (Block* block in touchedBlocks) 
		{
			[block swapToNormalBlock];
		}
	}

	[touchedBlocks removeAllObjects];
    
    [touchedBlockColumns removeAllObjects];
    for(int j = 0; j < numOfGridCols; j++)
    {
        [touchedBlockColumns addObject:[NSNumber numberWithInt:0]];
    }
	
    touchedColor = @"none";
	blockCount = 0;
    
    CCLOG(@"Number of blocks:%i", [blocks count]);
    //[self detectBlockFusion];
}

-(void)loadTestArray
{
    test = [[NSArray alloc] initWithObjects:
            [NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:4],[NSNumber numberWithInt:4],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:2],[NSNumber numberWithInt:3],[NSNumber numberWithInt:4],[NSNumber numberWithInt:4],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:1],[NSNumber numberWithInt:1],[NSNumber numberWithInt:3],[NSNumber numberWithInt:1],[NSNumber numberWithInt:3],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:1],[NSNumber numberWithInt:1],[NSNumber numberWithInt:1],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:3],[NSNumber numberWithInt:4],[NSNumber numberWithInt:3],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:4],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:3],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:4],[NSNumber numberWithInt:4], nil];;
}

-(id) init
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	if((self = [super init]))
	{
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		numOfGridRows = 9;
		numOfGridCols = 7;
		
		//init layers
		blockLayer = [[CCLayer alloc] init];
		
		[self addChild:blockLayer z:-1];
		
        /*
		[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        CCSprite *background = [CCSprite spriteWithFile:@"background.png"];
        background.anchorPoint = ccp(0,0);
        [self addChild:background z:-2];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
		CCLOG(@"background loaded");
         */
        
		[self loadTestArray];
		
        [self loadBlockColors];
		touchedColor = @"none";
		blockCount = 0;
		//touchHappening = NO;
		
		//top menu
		CCSprite *topBar = [CCSprite spriteWithFile:@"top_bar.png"];
		topBar.position = ccp(winSize.width/2, winSize.height - (topBar.contentSize.height / 2));
		[self addChild:topBar];
		
		CCMenuItem *pauseButton = [CCMenuItemImage
								   itemFromNormalImage:@"pause_button.png" selectedImage:@"pause_button.png"
								   target:self selector:@selector(pauseButtonTapped:)];
		
		pauseButton.position = ccp(winSize.width - pauseButton.contentSize.width/2, 
								   winSize.height - pauseButton.contentSize.height/2);
		
		
		CCMenu *button = [CCMenu menuWithItems:pauseButton, nil];
		button.position = CGPointZero;
		[self addChild:button];
		
		
		//[button release];
		//end top menu
		
		blocks = [[NSMutableArray alloc] initWithCapacity:(numOfGridCols*numOfGridRows)];
		touchedBlocks = [[NSMutableArray alloc] init];
        touchedBlockColumns = [[NSMutableArray alloc] init];
        
        for(int j = 0; j < numOfGridCols; j++)
        {
            [touchedBlockColumns addObject:[NSNumber numberWithInt:0]];
        }
		
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
		
		[self createAndDisplayGrid];
	}
	return self;
}

- (void)pauseButtonTapped:(id)sender 
{
	
	for (Block* block in blocks) 
	{
		if([block isKindOfClass:[Block class]] && !([[block getColor] isEqualToString:@"empty"]))
            [block remove];
	}
	
	[blocks removeAllObjects];
	
	[self createAndDisplayGrid];
}


-(void) dealloc
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	[blocks release];
	//[deadBlocks release];
	[colors release];
	[touchedBlocks release];
	
	[super dealloc];
}
@end
