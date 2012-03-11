//
//  Block.h
//  Manx
//
//  Created by Amanda Cordes on 11/20/11.
//  Copyright 2011 Self. All rights reserved.
//

#import "cocos2d.h"


@interface Block : NSObject
{
	CCSprite* mySprite;
	NSString* myColor;
	int mySize;
    int myGridPosition;
	
	CCNode* myParent;
}

+(id) blockWithParentNode:(CCNode*)parentNode withColor:(NSString*)color atPositionX:(float)x atPositionY:(float)y atGridPosition:(int)g withSize:(int)s;
-(id) initWithParentNode:(CCNode*)parentNode withColor:(NSString*)color atPositionX:(float)x atPositionY:(float)y atGridPosition:(int)g withSize:(int)s;

-(void)swapToDeadBlock;
-(void)swapToNormalBlock;
-(void)swapToEmptyBlock;

-(void)runAction:(NSMutableArray*)actions;

-(CGPoint)getPosition;
-(void)setPosition:(CGPoint)position;

-(NSString*)getColor;
-(void)setColor:(NSString*)color;

-(CCSprite*)getSprite;

-(CGRect)calcHitArea;

-(double)getWidth;

-(int)getSize;

-(int)getGridPosition;
-(void)setGridPosition:(int)g;

-(void)hide;

-(void)remove;

@end
