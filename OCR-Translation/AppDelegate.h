//
//  AppDelegate.h
//  infojobOCR
//
//  Created by Paolo Tagliani on 08/06/12.
//  Copyright (c) 2012 26775. All rights reserved.
//

//
//  OCR-Translation
//  Modified on 05/06/16 by Brooke Kelsey and Gibson Cook
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic) UIStoryboard* storyboard;
@property (nonatomic) UIViewController *currViewController;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) UIWindow *window;

@end
