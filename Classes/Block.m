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
        
        if([color isEqualToString:@"space"])
        {
            mySprite = [CCSprite spriteWithFile:@"empty_block.png"];
        }
        else if([color isEqualToString:@"empty"])
        {
            CCLOG(@"empty");
        }
        else 
        {
             mySprite = [CCSprite spriteWithFile:[myColor stringByAppendingString:[NSString stringWithFormat:@"%i_block0.png", mySize]]];
        }
		
        mySprite.anchorPoint = ccp(0,0);
		mySprite.position = ccp(x,y);
		[parentNode addChild:mySprite z:-1];
        
	}
	
	return self;
}

-(CGRect)calcHitArea
{
	//CCLOG(@"Calc Hit Area");
	
	float q = 9;
	
	float x = mySprite.position.x + q/2;
	float y = mySprite.position.y + q/2;
	
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
	if(mySize == 1)
    [mySprite setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"dead_%@%i_block0.png", myColor, mySize]]];
    
    else {
         [mySprite setTexture:[[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"dead%i_block0.png", mySize]]];
    }

}

-(void)swapToNormalBlock
{
	//CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	[mySprite setTexture:[[CCTextureCache sharedTextureCache] addImage:[myColor stringByAppendingString:[NSString stringWithFormat:@"%i_block0.png", mySize]]]];
}

-(void)swapToEmptyBlock
{
    mySize = 1;
    myColor = @"empty";
    
    //[mySprite removeFromParentAndCleanup:YES];
    [mySprite setTexture:[[CCTextureCache sharedTextureCache] addImage:@"empty_block.png"]];
}

-(void)swapToSpacerBlock
{
    mySize = 1;
    myColor = @"space";

    [mySprite setTexture:[[CCTextureCache sharedTextureCache] addImage:@"empty_block.png"]];
}

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
