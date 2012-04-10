//
//  Block.m
//  Manx
//
//  Created by Amanda Cordes on 11/20/11.
//  Copyright 2011 Self. All rights reserved.
//

#import "Block.h"


@implementation Block

+(id) blockWithParentNode:(CCNode*)parentNode withColor:(NSString*)color atPositionX:(float)x atPositionY:(float)y atGridPosition:(int)g withSize:(int)s
{	
	return [[self alloc] initWithParentNode:parentNode withColor:color atPositionX:x atPositionY:y atGridPosition:g withSize:s];
}

-(id) initWithParentNode:(CCNode*)parentNode withColor:(NSString*)color atPositionX:(float)x atPositionY:(float)y atGridPosition:(int)g withSize:(int)s
{
	if ((self = [super init]))
	{
		//CCLOG(@"%@: %@ Position: %f, %f GridPos: %i", NSStringFromSelector(_cmd), self, x, y, g);
		
		myParent = [[CCNode alloc] init];
		myParent = parentNode;
		
		myColor = [[NSString alloc] initWithString:color];
		mySize = s;
        myGridPosition = g;
        
        myActions = [[NSMutableArray alloc] init];
        
        mySprite = [CCSprite spriteWithFile:[myColor stringByAppendingString:[NSString stringWithFormat:@"%i_block0.png", mySize]]];
        
		
        //mySprite.anchorPoint = ccp(0,0);
		mySprite.position = ccp(x,y);
		[parentNode addChild:mySprite z:-2];
        
	}
	
	return self;
}

-(CGRect)calcHitArea
{
	//CCLOG(@"Calc Hit Area");
	
	float q = 10;
	
	float x = mySprite.position.x - (mySprite.contentSize.width/2) + q/2;
	float y = mySprite.position.y - (mySprite.contentSize.height/2) + q/2;
	
	return CGRectMake(x, y, 
					  [mySprite boundingBox].size.width - q, 
					  [mySprite boundingBox].size.height - q);
	
}

-(void)addAction:(CCAction*)action
{
    [myActions addObject:action];
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

-(void)runActions
{
	if([myActions count] > 0)
        [mySprite runAction: [CCSequence actions:[self getActionSequence: myActions],nil]];
    
    [myActions removeAllObjects];
}

-(void)swapToDeadBlock
{
	//CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

    [mySprite setTexture:[[CCTextureCache sharedTextureCache] addImage:[myColor stringByAppendingString:[NSString stringWithFormat:@"%i_dead_block0.png", mySize]]]];
    
}

-(void)swapToNormalBlock
{
	//CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	[mySprite setTexture:[[CCTextureCache sharedTextureCache] addImage:[myColor stringByAppendingString:[NSString stringWithFormat:@"%i_block0.png", mySize]]]];
}
/*
-(void)showScore:(int)score
{
    scoreLabel = [CCLabelBMFont labelWithString:[NSString stringWithFormat:@"+%i",score] fntFile:@"smallNumbers.fnt"];
    
    scoreLabel.position = CGPointMake(mySprite.position.x, mySprite.position.y + mySprite.contentSize.height/2);
    
    [myParent addChild:scoreLabel z:1];
}

-(void)removeScore
{
    [scoreLabel removeFromParentAndCleanup:YES];
}
*/

-(CCSprite*)getSprite
{
	return mySprite;
}

-(CGPoint)getPosition
{
    return mySprite.position;
}

-(void)setPosition:(CGPoint)position
{
	mySprite.position = position;
}

-(double)getWidth
{
	return [mySprite boundingBox].size.width;
}

-(int) getSize
{
	return mySize;
}

-(int)getGridPosition
{
    return myGridPosition;
}

-(void)setGridPosition:(int)g
{
    myGridPosition = g;
}

-(NSString*)getColor
{
	return myColor;
}

-(void)setColor:(NSString*)color
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

	myColor = color; //needs to be mutable?
	[mySprite setTexture:[[CCTextureCache sharedTextureCache] addImage:[myColor stringByAppendingString:[NSString stringWithFormat:@"%i_block0.png", mySize]]]];
}

-(void)hide
{
    mySprite.visible = NO;
}

-(void)remove
{
	//CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	[mySprite removeFromParentAndCleanup:YES];
}

-(NSString*) description
{
    return [NSString stringWithFormat:@"%@: %p, %@, %i, size:%i", [self class], self, myColor, myGridPosition, mySize];
}

- (void)dealloc 
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	[mySprite release];
	[myColor release];
	[myParent release];
	
	// Must manually remove this class as touch input receiver!
	//[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	
	[super dealloc];
}


@end
