//
//  ManxAppDelegate.h
//  Manx
//
//  Created by Amanda Cordes on 11/20/11.
//  Copyright Self 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface ManxAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
