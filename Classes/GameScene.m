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

//using x, y position
/*
-(void) addNewBlocksAtTop
{
	NSMutableDictionary* newBlocks = [[NSMutableDictionary alloc] init];
	
	int blockWidth = [[CCSprite spriteWithFile:[[colors objectAtIndex:1] stringByAppendingString:@"1_block0.png"]] boundingBox].size.width;
	
	for(Block* removedBlock in touchedBlocks)
	{
		int yPosition = 0;
		
		if([newBlocks objectForKey:[NSNumber numberWithFloat:[removedBlock getPosition].x]])
		{
			yPosition = [[newBlocks objectForKey:[NSNumber numberWithFloat:[removedBlock getPosition].x]] intValue];
		}
		
		float y = (blockWidth * (numOfGridRows + 1 + yPosition) - blockWidth);
		
		[newBlocks setObject:[NSNumber numberWithInt:(yPosition + 1)]
					  forKey:[NSNumber numberWithFloat:[removedBlock getPosition].x]];
		
		
        //[self createNewBlockAtPositionX:[removedBlock getPosition].x positionY:y withColor:[self pickBlockColor] atGridPosition:[removedBlock getGridPosition] withSize:1];
        [self addNewBlockAtPositionX:[removedBlock getPosition].x positionY:y withSize:1];
		
	}
	[newBlocks release];
}
 */


-(NSMutableArray*) addNewBlocksAtTop2
{
	
	int blockWidth = [[CCSprite spriteWithFile:[[colors objectAtIndex:1] stringByAppendingString:@"1_block0.png"]] boundingBox].size.width;
	
    //NSMutableArray* columnCount = [[NSMutableArray alloc] initWithArray:touchedBlockColumns];
    NSMutableArray* newBlocks = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [touchedBlockColumns count]; i++)
    {
        for(int j = 0; j < [[touchedBlockColumns objectAtIndex:i] intValue]; j++)
        {
            float x = offSet + (i * blockWidth);
            float y = (numOfGridRows + j) * blockWidth;
            int gp = ((numOfGridRows + j) * numOfGridCols) + i; //will be updated as it falls
            
            //this might need to happen when blocoks fall
            //int blocksIndex = gp - (numOfGridRows * [[touchedBlockColumns objectAtIndex:i] intValue]);
            
            [newBlocks addObject:[self createNewBlockAtPositionX:x 
                                                       positionY:y 
                                                       withColor:[self pickBlockColor] 
                                                  atGridPosition:gp 
                                                        withSize:1]];
        }
    }
    
    return newBlocks;
}

-(void)makeBlocksFall
{
	CCLOG(@"Make Sprites Fall");
	
	NSMutableArray *actions = [[NSMutableArray alloc] init];
	
	for(Block* block in blocks)
	{
		if([block isKindOfClass:[Block class]])
        {
            for(Block* removedBlock in touchedBlocks)
            {
                if(([block getPosition].x == [removedBlock getPosition].x) && ([block getPosition].y > [removedBlock getPosition].y))
                {
                    CCLOG(@"block in touchedBlocks");
                    [actions addObject:[CCMoveBy actionWithDuration:.09 
                                                           position:ccp(0,-1 * [removedBlock getWidth])]];
                    
                    //update postion for each row it falls
                    [block setGridPosition:([block getGridPosition] - numOfGridCols)];
                }
            }
            
            if([actions count] > 0)
            {
                [block runAction:actions];
                //[sprite runAction: [CCSequence actions:[self getActionSequence: actions],nil]];
                [actions removeAllObjects];
            }
        }
	}
	
	//[actions release];
}

-(void)makeBlocksFall2:(NSMutableArray*) newBlocks
{
	CCLOG(@"Make Sprites Fall");
	
	NSMutableArray *actions = [[NSMutableArray alloc] init];
    NSMutableArray *movedBlocks = [[NSMutableArray alloc] init];
    
    int blockWidth = [[CCSprite spriteWithFile:[[colors objectAtIndex:1] stringByAppendingString:@"1_block0.png"]] boundingBox].size.width;
	
	CCLOG(@"blocks count begin: %i", [blocks count]);
    for(Block* block in blocks)
	{
		if([block isKindOfClass:[Block class]] && !([[block getColor] isEqualToString:@"empty"]))
        {
            for(Block* removedBlock in touchedBlocks)
            {
                for(int i = 0; i < [removedBlock getSize]; i++)
                {
                    if(([block getPosition].x == ([removedBlock getPosition].x + (i * blockWidth))) && ([block getPosition].y > [removedBlock getPosition].y))
                    {
                        //CCLOG(@"block in touchedBlocks");
                        [actions addObject:[CCMoveBy actionWithDuration:.09 
                                                               position:ccp(0,-1 * [removedBlock getWidth])]];
                    
                        //update postion for each row it falls
                        [block setGridPosition:([block getGridPosition] - (numOfGridCols * [removedBlock getSize]))];
                        
                        [movedBlocks addObject:block];
                        
                    }
                }
            }
            
            if([actions count] > 0)
            {
                [block runAction:actions];
                //[sprite runAction: [CCSequence actions:[self getActionSequence: actions],nil]];
                [actions removeAllObjects];
            }
            
        }
	}
    
    for(Block* block in movedBlocks)
    {
        [blocks replaceObjectAtIndex:[block getGridPosition] withObject:block];
    }
    
    for(Block* block in newBlocks)
    {
        for(int i = 0; i < [[touchedBlockColumns objectAtIndex:([block getGridPosition] % numOfGridCols)] intValue]; i++)
        {
            [actions addObject:[CCMoveBy actionWithDuration:.09 
                                                   position:ccp(0,-1 * blockWidth)]];
            
            //update postion for each row it falls
            [block setGridPosition:([block getGridPosition] - numOfGridCols)];
        }
        
        if([actions count] > 0)
        {
            [block runAction:actions];
            //[sprite runAction: [CCSequence actions:[self getActionSequence: actions],nil]];
            [actions removeAllObjects];
        }
        
        [blocks replaceObjectAtIndex:[block getGridPosition] withObject:block];
    }
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
		[self makeBlocksFall2:[self addNewBlocksAtTop2]];
        
        for (Block* block in touchedBlocks) 
		{
			[block remove];			
		}
        //[blocks removeObjectsInArray:touchedBlocks];
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
            [NSNumber numberWithInt:1],[NSNumber numberWithInt:1],[NSNumber numberWithInt:1],[NSNumber numberWithInt:1],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:1],[NSNumber numberWithInt:1],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:2],[NSNumber numberWithInt:3],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4],[NSNumber numberWithInt:5],[NSNumber numberWithInt:4], nil];
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
