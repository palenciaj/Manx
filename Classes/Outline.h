//
//  Outline.h
//  Manx
//
//  Created by Amanda Cordes on 4/20/12.
//  Copyright (c) 2012 Self. All rights reserved.
//

#import "cocos2d.h"

@interface Outline : NSObject
{
    CCSprite* mySprite;
    int mySize;
    
    BOOL touched;
    
    NSMutableArray* myBlockGridPos;
    NSMutableArray* myBlocks;
}

+(id) outlineWithParentNode:(CCNode*)parentNode atPositionX:(float)x atPositionY:(float)y withSize:(int)s;
-(id) initWithParentNode:(CCNode*)parentNode atPositionX:(float)x atPositionY:(float)y  withSize:(int)s;

-(void)setTouched:(BOOL)b;
-(BOOL)getTouched;

-(void)hide;

-(NSMutableArray*)getBlocks;
-(void)setBlocks:(NSMutableArray*)array;
-(NSMutableArray*)getBlockGridPos;
-(CGRect)calcHitArea;

-(void)remove;


@end
