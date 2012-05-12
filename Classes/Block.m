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
		//CCLOG(@"%@: %@ Position: %f, %f GridPos: %i, Color: %@", NSStringFromSelector(_cmd), self, x, y, g, color);
		
		myColor = [[NSString alloc] initWithString:color];
		mySize = s;
        myGridPosition = g;
        isPartOfCluster = NO;
        animateTag = 222;
        
        myActions = [[NSMutableArray alloc] init];
        
        spriteType = 1;
        fall = 0;
        
        if([myColor isEqualToString:@"grn"])
        {
            myFrames = 8;
        }
        
        else if([myColor isEqualToString:@"blu"])
        {
            myFrames = 15;
        }
        
        else if([myColor isEqualToString:@"prp"])
        {
            myFrames = 6;
        }
        
        else if([myColor isEqualToString:@"red"])
        {
            myFrames = 6;
        }
        
        else if([myColor isEqualToString:@"nmy"])
        {
            myFrames = 6;
        }
        
        else
        {
            myFrames = 1;
        }
        
        mySprite = [CCSprite spriteWithSpriteFrameName:[self normalTexture]];
        [self animate];

        //mySprite.anchorPoint = ccp(0,0);
		mySprite.position = ccp(x,y);
		[parentNode addChild:mySprite z:-2];
        
	}
	
	return self;
}

-(void)animate
{
    CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    
    NSMutableArray* frames = [NSMutableArray arrayWithCapacity:myFrames];
    
    int r = ((arc4random() % myFrames) + 1);
   
    
    for (int i = r; i <= myFrames +r; i++) 
    {
        NSString* file = [myColor stringByAppendingString:[NSString stringWithFormat:@"1_tile%i.png", (i%myFrames)+1]];
        
        //CCLOG(@"file: %@", file);
        
        CCSpriteFrame* frame = [frameCache spriteFrameByName:file];
        [frames addObject:frame];
    }
     
    
    CCAnimation* animation = [CCAnimation animationWithFrames:frames delay:.17];
    
    CCAnimate* animate = [CCAnimate actionWithAnimation:animation];
    CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
    repeat.tag = animateTag;
    [mySprite runAction:repeat];
    
}

-(NSString*)normalTexture
{
    return [myColor stringByAppendingString:[NSString stringWithFormat:@"1_tile%i.png", spriteType]];
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
    //fall ++;
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
    {
        [mySprite runAction: [CCSequence actions:[self getActionSequence: myActions],nil]];
        isPartOfCluster = NO;
    }
    
    
    
    [myActions removeAllObjects];
}

-(void)swapToDeadBlock
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    [mySprite stopActionByTag:animateTag];
    [mySprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"tile_%@_touch.png", myColor]]];
    //[mySprite setTexture:[[CCTextureCache sharedTextureCache] addImage:[myColor stringByAppendingString:@"_dead_tile.png"]]];
    
}

-(void)swapToNormalBlock
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    [self animate];
    
    /*
    if(isPartOfCluster)
    {
        [self animate];
    }
    else 
    {
        [mySprite stopActionByTag:animateTag];
        [mySprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[self normalTexture]]];
    }
	*/
    //[mySprite setTexture:[[CCTextureCache sharedTextureCache] addImage:[self normalTexture]]];
}

-(CCSprite*)getSprite
{
	return mySprite;
}

-(CGPoint)getPosition
{
    return mySprite.position;
}

-(BOOL)isPartOfCluster
{
    return isPartOfCluster;
}

-(void)setClusterStatus:(BOOL)c
{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    isPartOfCluster = c;
    
    if(isPartOfCluster)
    {
        [self animate];
    }
    else 
    {
        [mySprite stopActionByTag:animateTag];
        [mySprite setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[self normalTexture]]];
    }

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

-(BOOL)getClusterStatus
{
    return isPartOfCluster;
}

-(NSString*)getColor
{
	return myColor;
}

-(void)setColor:(NSString*)color
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);

	myColor = color; //needs to be mutable?
	[mySprite setTexture:[[CCTextureCache sharedTextureCache] addImage:[self normalTexture]]];
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
    return [NSString stringWithFormat:@"%@: %p, %@, %i, size:%i, %@", [self class], self, myColor, myGridPosition, mySize, isPartOfCluster ? @"YES" : @"NO"];
}

- (void)dealloc 
{
	CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
	
	[mySprite release];
	[myColor release];
	
	// Must manually remove this class as touch input receiver!
	//[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	
	[super dealloc];
}


@end
