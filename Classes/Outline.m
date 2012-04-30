//
//  Outline.m
//  Manx
//
//  Created by Amanda Cordes on 4/20/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "Outline.h"

@implementation Outline

+(id) outlineWithParentNode:(CCNode*)parentNode atPositionX:(float)x atPositionY:(float)y withSize:(int)s
{	
	return [[self alloc] initWithParentNode:parentNode atPositionX:x atPositionY:y withSize:s];
}

-(id) initWithParentNode:(CCNode*)parentNode atPositionX:(float)x atPositionY:(float)y withSize:(int)s
{
	if ((self = [super init]))
	{
		mySize = s;
        
        myBlocks = [[NSMutableArray alloc] init];
        
        mySprite = [CCSprite spriteWithFile:[NSString stringWithFormat:@"outline%i.png", mySize]];
        
		mySprite.position = ccp(x,y);
		
        [parentNode addChild:mySprite z:-1];
        
	}
	
	return self;
}

-(void)setBLocks:(NSMutableArray*)array
{
    myBlocks = array;
}

-(NSMutableArray*)getBlocks
{
    return myBlocks;
}

-(CGRect)calcHitArea
{
	//CCLOG(@"Calc Hit Area");
	
	float q = .44;
    
    float width = mySprite.contentSize.width * q;
	
	float x = mySprite.position.x - width/2;
	float y = mySprite.position.y - width/2;
	
	return CGRectMake(x, y, width, width);
	
}


-(void)remove
{
	//CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	[mySprite removeFromParentAndCleanup:YES];
    [myBlocks removeAllObjects];
}

- (void)dealloc 
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
	//[mySprite release];
    [mySprite removeFromParentAndCleanup:YES];
    [myBlocks removeAllObjects];
    [myBlocks release];
	
	// Must manually remove this class as touch input receiver!
	//[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	
	[super dealloc];
}


@end
