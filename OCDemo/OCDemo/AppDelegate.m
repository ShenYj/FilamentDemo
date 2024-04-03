//
//  AppDelegate.m
//  OCDemo
//
//  Created by EZen on 2022/3/18.
//

#import "AppDelegate.h"
#import "ViewController.h"

// _##R##_##G##_##B
#define COLOR_METHOD_IMP(R, G, B) + (UIColor *)OC_RGB { return [UIColor colorWithRed:R / 255.0 green:G / 255.0 blue:B / 255.0 alpha: 1]; }

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[ViewController alloc] init]];
    [self.window makeKeyAndVisible];
    
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"沙盒路径; %@", path);
    
    return YES;
}


@end
